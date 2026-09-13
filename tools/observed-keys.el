;;; observed-keys.el --- Capture the configuration's effective keys -*- lexical-binding: t; -*-

;; A library, not a test and not an entry point: loading it defines functions
;; and does nothing else.  `tests/gui-run.el' loads it inside the graphical test
;; instance and calls `uwumacs-observed-keys-write', which is how the committed
;; report under `var/uwumacs-audit/' (git-ignored) is regenerated:
;;
;;   pwsh tools/run-gui-tests.ps1 -Suite audit
;;
;; It runs against a configuration that is ALREADY loaded; it does not bootstrap
;; one.  It is display agnostic -- every value it records that depends on the
;; display is written next to `emacs.display_graphic_p' so a reader can see which
;; session it describes -- but the committed report must come from a GRAPHICAL
;; session: `nerd-icons-corfu-formatter' is registered only when
;; `starter-ui-icons-available-p' is true, and that predicate requires
;; `display-graphic-p'.  A batch capture of `corfu-margin-formatters' describes a
;; session the user never has.
;;
;; Anything that cannot be observed in the current session is emitted with
;; `observable: false' and a `reason', never omitted.
;;
;; Keymap entries are sorted before serializing.  `map-keymap' order is not
;; stable across builds, and an unsorted dump makes consecutive audits
;; undiffable.

(require 'cl-lib)
(require 'seq)
(require 'subr-x)

(defconst uwumacs-observed-keys-schema "uwumacs.observed-keys/1")

(defvar uwumacs-observed-keys--errors nil)
(defvar uwumacs-observed-keys--notes nil)

(defun uwumacs-observed-keys--error (format &rest arguments)
  (push (apply #'format format arguments) uwumacs-observed-keys--errors))

(defun uwumacs-observed-keys--note (format &rest arguments)
  (push (apply #'format format arguments) uwumacs-observed-keys--notes))

(defun uwumacs-observed-keys--vector (list) (vconcat list))

(defun uwumacs-observed-keys--bool (value) (if value t :false))


;;;; Describing bindings

(defvar uwumacs-observed-keys--known-maps
  '(project-prefix-map lem+leader-map meow-normal-state-keymap
    meow-motion-state-keymap meow-insert-state-keymap meow-keymap
    goto-map search-map ctl-x-map help-map)
  "Keymap variables worth naming by hand in the report.")

(defun uwumacs-observed-keys--name-keymap (keymap)
  "Return the variable name of KEYMAP when it can be recognised."
  (or (car (seq-filter (lambda (symbol)
                         (and (boundp symbol) (eq (symbol-value symbol) keymap)))
                       uwumacs-observed-keys--known-maps))
      (let (found)
        (mapatoms (lambda (symbol)
                    (and (boundp symbol)
                         (string-match-p "map\\'" (symbol-name symbol))
                         (eq (symbol-value symbol) keymap)
                         (push symbol found))))
        ;; `mapatoms' order is not stable, and several aliases can name the same
        ;; keymap.  Pick the first by name so consecutive audits diff cleanly.
        (car (sort found (lambda (a b) (string< (symbol-name a) (symbol-name b))))))))

(defun uwumacs-observed-keys--describe (binding)
  "Describe BINDING as a stable string."
  (cond
   ((null binding) "nil")
   ((and (symbolp binding) (not (keymapp binding))) (symbol-name binding))
   ((keymapp binding)
    (let ((name (uwumacs-observed-keys--name-keymap
                 (if (symbolp binding) (symbol-value binding) binding))))
      (if name (format "#<keymap %s>" name) "#<keymap anonymous>")))
   ((functionp binding) "#<function>")
   (t (format "%S" binding))))

(defun uwumacs-observed-keys--kind (binding)
  (cond ((null binding) "unbound")
        ((and (symbolp binding) (keymapp binding)) "prefix-symbol")
        ((keymapp binding) "keymap")
        ((symbolp binding) "command")
        (t "other")))

(defun uwumacs-observed-keys--literal-p (description)
  "Return non-nil when DESCRIPTION names a key a plain keyboard can type.
The decisive test is the key DESCRIPTION, not `event-modifiers': the latter
reports `shift' for every uppercase character and `control' for TAB, RET and
ESC, which would mislabel six plain keys in `project-prefix-map' alone."
  (and description (not (string-match-p "\\`\\(C\\|M\\|s\\|H\\|A\\)-" description))))

(defun uwumacs-observed-keys--entries (keymap)
  "Return KEYMAP's own bindings as plists, sorted by key description."
  (let (entries)
    (when (keymapp keymap)
      (map-keymap
       (lambda (event definition)
         (unless (eq event 'keymap)
           (let* ((key (or (ignore-errors (key-description (vector event)))
                           (format "%S" event)))
                  (modifiers (and (integerp event) (event-modifiers event))))
             (push (list :key key
                         :event (format "%S" event)
                         :binding (uwumacs-observed-keys--describe definition)
                         :kind (uwumacs-observed-keys--kind definition)
                         :event_modifiers
                         (uwumacs-observed-keys--vector
                          (mapcar #'symbol-name modifiers))
                         :literal (uwumacs-observed-keys--bool
                                   (uwumacs-observed-keys--literal-p key)))
                   entries))))
       keymap))
    (sort (nreverse entries)
          (lambda (a b) (string< (plist-get a :key) (plist-get b :key))))))

(defun uwumacs-observed-keys--live (keymap key)
  "Return KEY's binding in KEYMAP, or nil when it is unbound or too long."
  (let ((binding (ignore-errors (lookup-key keymap (kbd key)))))
    (and binding (not (numberp binding)) binding)))


;;;; Meow keypad reachability (simulated, not typed)

(defun uwumacs-observed-keys--leader-keymap ()
  (and (fboundp 'meow--get-leader-keymap) (meow--get-leader-keymap)))

(defun uwumacs-observed-keys--walk (keymap prefix depth)
  "Walk KEYMAP recording which literal keys Meow's keypad cannot reach.
With this configuration's keypad prefixes all nil, the first key after SPC is
looked up literally and every later key is sent as C-<key> first, so at depth 2
or more a bound C-K steals the plain K.  Returns a cons of the number of nodes
visited and the list of damaged leaves."
  (let ((visited 0) (damaged nil))
    (dolist (entry (uwumacs-observed-keys--entries keymap))
      (let* ((key (plist-get entry :key))
             (literal (eq (plist-get entry :literal) t))
             (definition (uwumacs-observed-keys--live keymap key))
             (sequence (if (string-empty-p prefix) key (concat prefix " " key)))
             (control (and literal (= 1 (length key)) (>= depth 1)
                           (uwumacs-observed-keys--live keymap (concat "C-" key))))
             (shadowed (and control (not (eq control definition)))))
        (setq visited (1+ visited))
        (unless (and literal (not shadowed))
          (push (list :typed (if literal (concat "SPC " sequence) :null)
                      :map_key sequence
                      :depth (1+ depth)
                      :literal (uwumacs-observed-keys--bool literal)
                      :binding (plist-get entry :binding)
                      :keypad_resolves_to (if shadowed
                                              (uwumacs-observed-keys--describe control)
                                            :null)
                      :reason
                      (cond
                       ((not literal)
                        "needs a modifier no keypad prefix can produce (start, literal, meta and ctrl-meta prefixes are all nil)")
                       (t (format "shadowed: the keypad sends C-%s first, which is bound to %s"
                                  key (uwumacs-observed-keys--describe control)))))
                damaged))
        (when (and (keymapp definition) (< depth 3))
          (let ((child (uwumacs-observed-keys--walk definition sequence (1+ depth))))
            (setq visited (+ visited (car child))
                  damaged (append (cdr child) damaged))))))
    (cons visited
          (sort damaged (lambda (a b) (string< (plist-get a :map_key)
                                               (plist-get b :map_key)))))))

(defun uwumacs-observed-keys--probe (keys)
  "Drive Meow's own keypad lookup for SPC followed by KEYS, a list of strings."
  (let ((meow--keypad-keys nil)
        (meow--keypad-base-keymap nil)
        (meow--use-literal nil) (meow--use-meta nil) (meow--use-both nil)
        (trace nil) (result nil))
    (catch 'done
      (dolist (key keys)
        (if (null meow--keypad-keys)
            (progn (setq meow--keypad-base-keymap (uwumacs-observed-keys--leader-keymap))
                   (push (cons 'literal key) meow--keypad-keys))
          (push (cons 'control key) meow--keypad-keys))
        (let* ((formatted (meow--keypad-format-keys nil))
               (command (meow--keypad-lookup-key (kbd formatted))))
          (when (and (or (null command) (numberp command))
                     (eq 'control (caar meow--keypad-keys)))
            (setcar meow--keypad-keys (cons 'literal (cdar meow--keypad-keys)))
            (setq formatted (meow--keypad-format-keys nil)
                  command (meow--keypad-lookup-key (kbd formatted))))
          (push (format "%s => %s" formatted
                        (uwumacs-observed-keys--describe command))
                trace)
          (cond ((keymapp command) nil)
                ((commandp command t)
                 (setq result (uwumacs-observed-keys--describe command))
                 (throw 'done nil))
                (t (throw 'done nil))))))
    (list :typed (concat "SPC " (string-join keys " "))
          :resolved (or result :null)
          :trace (uwumacs-observed-keys--vector (nreverse trace)))))


;;;; Buffer fixtures

(defun uwumacs-observed-keys--enter-state (state)
  "Enter Meow STATE in the current buffer, unconditionally.
Switching through a different state first is required: `meow--switch-state'
short-circuits when the requested state is already `meow--current-state', and a
stray `(meow-STATE-mode 1)' leaves that variable set while the state keymap is
off.  (`tests/uwumacs-test-helper.el' carries the same idiom for test fixtures;
this file must not depend on the test tree.)"
  (unless (bound-and-true-p meow-mode) (meow-mode 1))
  (let ((via (if (eq state 'insert) 'motion 'insert)))
    (meow--switch-state via)
    (meow--switch-state state))
  (unless (funcall (intern (format "meow-%s-mode-p" state)))
    (uwumacs-observed-keys--error "Could not enter Meow %s state in %s"
                                  state (buffer-name)))
  state)

(defun uwumacs-observed-keys--sample (label buffer &optional state)
  "Capture the effective leader situation of BUFFER under LABEL."
  (with-current-buffer buffer
    (unless (bound-and-true-p meow-mode) (ignore-errors (meow-mode 1)))
    (when state (uwumacs-observed-keys--enter-state state))
    (let* ((current (bound-and-true-p meow--current-state))
           (space (key-binding (kbd "SPC")))
           (leader (uwumacs-observed-keys--leader-keymap)))
      (list :label label
            :observable t
            :buffer (buffer-name)
            :major_mode (format "%S" major-mode)
            :forced (uwumacs-observed-keys--bool state)
            :meow_state (format "%S" current)
            :state_mode_live (uwumacs-observed-keys--bool
                              (and current
                                   (funcall (intern (format "meow-%s-mode-p" current)))))
            :spc_binding (uwumacs-observed-keys--describe space)
            :spc_kind (uwumacs-observed-keys--kind space)
            :leader_reachable (uwumacs-observed-keys--bool
                               (memq space '(meow-keypad meow-keypad-start)))
            :leader_keymap (uwumacs-observed-keys--describe leader)
            :leader_is_lem_leader (uwumacs-observed-keys--bool
                                   (eq leader (and (boundp 'lem+leader-map)
                                                   lem+leader-map)))
            :active_map_count (length (current-active-maps))
            :where_is_meow_keypad
            (uwumacs-observed-keys--vector
             (mapcar #'key-description
                     (where-is-internal 'meow-keypad (current-active-maps))))))))

(defun uwumacs-observed-keys--minibuffer-sample ()
  "Observe the leader inside a live minibuffer, or say why it was not observed.
A minibuffer cannot be entered under --batch at all; in a graphical session it
is entered here and dismissed from a timer, the same shape
`tests/key-hints-gui-tests.el' already uses."
  (let ((hook (uwumacs-observed-keys--vector
               (mapcar (lambda (f) (format "%S" f)) minibuffer-setup-hook))))
    (if (or noninteractive (not (display-graphic-p)))
        (list :label "minibuffer" :observable :false
              :reason "no minibuffer can be entered without an interactive display"
              :minibuffer_setup_hook hook)
      (let (sample timer)
        (condition-case error
            (unwind-protect
                (condition-case nil
                    (minibuffer-with-setup-hook
                        (lambda ()
                          (setq timer
                                (run-with-timer
                                 0.2 nil
                                 (lambda ()
                                   (unwind-protect
                                       (setq sample
                                             (with-current-buffer
                                                 (window-buffer (active-minibuffer-window))
                                               (list (uwumacs-observed-keys--describe
                                                      (key-binding (kbd "SPC")))
                                                     (format "%S" (bound-and-true-p
                                                                   meow--current-state))
                                                     (length (current-active-maps)))))
                                     (setq unread-command-events (list ?\C-g)))))))
                      (read-string "uwumacs audit: "))
                  (quit nil))
              (when timer (cancel-timer timer)))
          (error (uwumacs-observed-keys--note "minibuffer probe failed: %S" error)))
        (if sample
            (list :label "minibuffer" :observable t
                  :buffer "*Minibuf*"
                  :major_mode "minibuffer-mode"
                  :spc_binding (nth 0 sample)
                  :meow_state (nth 1 sample)
                  :leader_reachable (uwumacs-observed-keys--bool
                                     (member (nth 0 sample)
                                             '("meow-keypad" "meow-keypad-start")))
                  :active_map_count (nth 2 sample)
                  :minibuffer_setup_hook hook)
          (list :label "minibuffer" :observable :false
                :reason "the minibuffer probe did not complete in this session"
                :minibuffer_setup_hook hook))))))


;;;; Cheat-sheet cross-check

(defun uwumacs-observed-keys--cheatsheet (file)
  "Cross-check the leader rows of FILE against the live leader map and keypad.
`tests/verify-config.el' already asserts each row resolves in `lem+leader-map';
this records the stricter fact of what typing the advertised sequence does."
  (if (not (and file (file-readable-p file) (boundp 'lem+leader-map)))
      (list :observable :false :reason "keybindings.org or lem+leader-map unavailable")
    (let (rows)
      (with-temp-buffer
        (insert-file-contents file)
        (goto-char (point-min))
        (while (re-search-forward
                "^| \\(SPC [^|]+?\\) +|[^|]+| \\([a-z][a-z0-9-]+\\) +|" nil t)
          (let* ((key (string-trim (match-string 1)))
                 (documented (intern (match-string 2)))
                 (tail (substring key 4))
                 (bound (uwumacs-observed-keys--live lem+leader-map tail))
                 (probe (uwumacs-observed-keys--probe (split-string tail " " t))))
            (push (list :key key
                        :documented (symbol-name documented)
                        :leader_map_binding (uwumacs-observed-keys--describe bound)
                        :leader_map_matches (uwumacs-observed-keys--bool
                                             (eq bound documented))
                        :command_bound (uwumacs-observed-keys--bool
                                        (fboundp documented))
                        :keypad_resolves_to (plist-get probe :resolved)
                        :keypad_matches (uwumacs-observed-keys--bool
                                         (equal (plist-get probe :resolved)
                                                (symbol-name documented))))
                  rows))))
      (list :observable t
            :source file
            :method "the row regexp tests/verify-config.el uses, plus a keypad simulation"
            :rows (uwumacs-observed-keys--vector
                   (sort (nreverse rows)
                         (lambda (a b) (string< (plist-get a :key)
                                                (plist-get b :key)))))))))


;;;; The report

(defun uwumacs-observed-keys-report ()
  "Return the observed-key report for the running configuration, as a plist."
  (let ((uwumacs-observed-keys--errors nil)
        (uwumacs-observed-keys--notes nil)
        (buffers nil) (unreachable nil) (walked 0)
        (directory (make-temp-file "uwumacs-observed-" t)))
    (unwind-protect
        (let* ((fixture (expand-file-name "fixture.el" directory))
               (index (and (boundp 'lem-emacs-dir)
                           (expand-file-name "literate/index.org" lem-emacs-dir)))
               (coding-system-for-write 'utf-8-unix))
          (write-region ";;; fixture.el -*- lexical-binding: t; -*-\n(ignore)\n"
                        nil fixture nil 'silent)
          (unless (featurep 'meow)
            (uwumacs-observed-keys--error "meow is not loaded; the capture is empty"))
          (when (featurep 'meow)
            (let ((elisp (find-file-noselect fixture))
                  (org (and index (file-readable-p index) (find-file-noselect index)))
                  (dired (dired-noselect directory))
                  (special (get-buffer-create "*uwumacs-observed-special*")))
              (with-current-buffer special (special-mode))
              (push (uwumacs-observed-keys--sample "normal/file-elisp" elisp 'normal) buffers)
              (when org
                (push (uwumacs-observed-keys--sample "normal/file-org" org 'normal) buffers))
              (push (uwumacs-observed-keys--sample "auto/dired" dired) buffers)
              (push (uwumacs-observed-keys--sample "auto/special-mode" special) buffers)
              (push (uwumacs-observed-keys--sample "motion/special-mode" special 'motion) buffers)
              (push (uwumacs-observed-keys--sample "insert/file-elisp" elisp 'insert) buffers)
              (push (uwumacs-observed-keys--minibuffer-sample) buffers)
              (with-current-buffer elisp
                (uwumacs-observed-keys--enter-state 'normal)
                (set-buffer-modified-p nil))
              (kill-buffer dired)
              (kill-buffer special)
              (kill-buffer elisp)))
          (when (boundp 'lem+leader-map)
            (let ((walk (uwumacs-observed-keys--walk lem+leader-map "" 0)))
              (setq walked (car walk) unreachable (cdr walk))))
          (list
           :schema uwumacs-observed-keys-schema
           :generated (format-time-string "%FT%T%z")
           :emacs (list :version emacs-version
                        :system (symbol-name system-type)
                        :batch (uwumacs-observed-keys--bool noninteractive)
                        :window_system (format "%S" window-system)
                        :display_graphic_p (uwumacs-observed-keys--bool (display-graphic-p)))
           :capture
           (list :method (if (display-graphic-p)
                             "graphical --init-directory startup in an isolated root"
                           "non-graphical session")
                 :emacs_version emacs-version
                 :source_root (or (bound-and-true-p lem-emacs-dir) "unknown")
                 ;; The commit the capture came from, and whether that commit
                 ;; actually describes the code that ran.  A report generated
                 ;; from a dirty worktree names a commit that cannot reproduce
                 ;; it, so say so rather than implying provenance.
                 :source_commit (or (getenv "EMACS_DOTS_SOURCE_COMMIT") "unknown")
                 :source_worktree_dirty
                 (pcase (getenv "EMACS_DOTS_SOURCE_DIRTY")
                   ("true" t) ("false" :false) (_ :null))
                 :package_dir (or (getenv "EMACS_DOTS_TEST_PACKAGES") package-user-dir)
                 :packages_activated (length package-activated-list)
                 :display (if (display-graphic-p) "graphic" "non-graphic"))
           :buffers (uwumacs-observed-keys--vector (nreverse buffers))
           :leader
           (if (boundp 'lem+leader-map)
               (list :map "lem+leader-map"
                     :is_meow_leader (uwumacs-observed-keys--bool
                                      (eq (uwumacs-observed-keys--leader-keymap)
                                          lem+leader-map))
                     :keypad_prefixes
                     (list :start_keys (format "%S" (bound-and-true-p meow-keypad-start-keys))
                           :literal_prefix (format "%S" (bound-and-true-p meow-keypad-literal-prefix))
                           :meta_prefix (format "%S" (bound-and-true-p meow-keypad-meta-prefix))
                           :ctrl_meta_prefix (format "%S" (bound-and-true-p meow-keypad-ctrl-meta-prefix))
                           :leader_transparent (format "%S" (bound-and-true-p meow-keypad-leader-transparent)))
                     :entries (uwumacs-observed-keys--vector
                               (uwumacs-observed-keys--entries lem+leader-map)))
             (list :observable :false :reason "lem+leader-map is unbound"))
           :keypad_reachability
           (list :evidence "simulated: meow--keypad-format-keys and meow--keypad-lookup-key were called directly, not typed at a keyboard"
                 :model "keypad prefixes are all nil, so the first key after SPC is literal and every later key is sent as C-<key> first"
                 :nodes_walked walked
                 :unreachable (uwumacs-observed-keys--vector unreachable)
                 :probes (uwumacs-observed-keys--vector
                          (mapcar #'uwumacs-observed-keys--probe
                                  '(("f" "f") ("s" "l") ("l") ("l" "d") ("TAB")
                                    ("p") ("p" "b") ("p" "x") ("p" "x" "s")
                                    ("p" "f") ("p" "p")))))
           :spc_l
           (if (boundp 'lem+leader-map)
               (let ((binding (uwumacs-observed-keys--live lem+leader-map "l")))
                 (list :key "SPC l"
                       :binding (uwumacs-observed-keys--describe binding)
                       :kind (uwumacs-observed-keys--kind binding)
                       :is_starter_lsp_keys (uwumacs-observed-keys--bool
                                             (and (boundp 'starter+lsp-keys)
                                                  (eq binding (symbol-value 'starter+lsp-keys))))
                       :is_vertico_repeat (uwumacs-observed-keys--bool
                                           (eq binding 'vertico-repeat))
                       :submenu (uwumacs-observed-keys--vector
                                 (and (keymapp binding)
                                      (uwumacs-observed-keys--entries binding)))
                       :vertico_repeat_reachable_at
                       (uwumacs-observed-keys--vector
                        (mapcar #'key-description
                                (where-is-internal 'vertico-repeat (list lem+leader-map))))))
             (list :observable :false :reason "lem+leader-map is unbound"))
           :project_prefix_map
           (if (boundp 'project-prefix-map)
               (let ((entries (uwumacs-observed-keys--entries project-prefix-map)))
                 (list :map "project-prefix-map"
                       :leader_key "SPC p"
                       :count (length entries)
                       :literal_count (length (seq-filter
                                               (lambda (e) (eq (plist-get e :literal) t))
                                               entries))
                       :modified_count (length (seq-filter
                                                (lambda (e) (not (eq (plist-get e :literal) t)))
                                                entries))
                       :entries
                       (uwumacs-observed-keys--vector
                        (mapcar
                         (lambda (entry)
                           (let* ((key (plist-get entry :key))
                                  (literal (eq (plist-get entry :literal) t))
                                  (control (and literal (= 1 (length key))
                                                (uwumacs-observed-keys--live
                                                 project-prefix-map (concat "C-" key)))))
                             (append entry
                                     (list :shadowed_by_control
                                           (if control
                                               (uwumacs-observed-keys--describe control)
                                             :false)
                                           :typed_as
                                           (cond ((not literal)
                                                  (format "unreachable: no plain key types %s" key))
                                                 (control
                                                  (format "SPC p %s resolves C-%s first" key key))
                                                 (t (format "SPC p %s" key)))))))
                         entries))
                       :nested
                       (uwumacs-observed-keys--vector
                        (mapcar (lambda (entry)
                                  (let ((key (plist-get entry :key)))
                                    (list :prefix key
                                          :entries (uwumacs-observed-keys--vector
                                                    (uwumacs-observed-keys--entries
                                                     (uwumacs-observed-keys--live
                                                      project-prefix-map key))))))
                                (seq-filter (lambda (e)
                                              (member (plist-get e :kind)
                                                      '("keymap" "prefix-symbol")))
                                            entries)))))
             (list :observable :false :reason "project-prefix-map is unbound"))
           :corfu
           (list :feature_corfu (uwumacs-observed-keys--bool (featurep 'corfu))
                 :feature_kind_icon (uwumacs-observed-keys--bool (featurep 'kind-icon))
                 :feature_nerd_icons_corfu (uwumacs-observed-keys--bool
                                            (featurep 'nerd-icons-corfu))
                 :global_corfu_mode (uwumacs-observed-keys--bool
                                     (bound-and-true-p global-corfu-mode))
                 :starter_ui_icons (format "%S" (bound-and-true-p starter-ui-icons))
                 :icons_available_p (uwumacs-observed-keys--bool
                                     (and (fboundp 'starter-ui-icons-available-p)
                                          (starter-ui-icons-available-p)))
                 :display_graphic_p (uwumacs-observed-keys--bool (display-graphic-p))
                 :margin_formatters
                 (uwumacs-observed-keys--vector
                  (mapcar (lambda (f) (format "%S" f))
                          (and (boundp 'corfu-margin-formatters) corfu-margin-formatters)))
                 :effective (format "%S" (car (and (boundp 'corfu-margin-formatters)
                                                   corfu-margin-formatters)))
                 :consumed_by "run-hook-with-args-until-success in corfu--affixate: only the first element renders")
           :cheatsheet
           (uwumacs-observed-keys--cheatsheet
            (and (boundp 'lem-user-dir)
                 (expand-file-name "keybindings.org" (symbol-value 'lem-user-dir))))
           :notes (uwumacs-observed-keys--vector (nreverse uwumacs-observed-keys--notes))
           :errors (uwumacs-observed-keys--vector (nreverse uwumacs-observed-keys--errors))))
      (when (file-directory-p directory)
        (dolist (file (directory-files-recursively directory "" t))
          (ignore-errors (set-file-modes file #o700)))
        (ignore-errors (delete-directory directory t))))))

(defun uwumacs-observed-keys-write (destination)
  "Write the observed-key report to DESTINATION as pretty JSON.
Returns the report's error list, empty on a clean capture."
  (let* ((report (uwumacs-observed-keys-report))
         (coding-system-for-write 'utf-8-unix))
    (make-directory (file-name-directory destination) t)
    (with-temp-file destination
      (insert (json-serialize report :null-object :null :false-object :false))
      (json-pretty-print-buffer)
      (goto-char (point-max))
      (unless (bolp) (insert "\n")))
    (append (plist-get report :errors) nil)))

(provide 'uwumacs-observed-keys)
