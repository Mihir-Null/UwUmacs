;;; uwumacs-registry.el --- Lazy integration lifetimes -*- lexical-binding: t; -*-
;; Generated from literate/41-uwumacs-core.org; edit the Org source, then tangle.

;;; Code:
(require 'cl-lib)
(require 'seq)
(require 'subr-x)
(require 'uwumacs-state)

(declare-function meow--switch-state "meow-core" (state))
(defvar uwumacs--registry nil "Alist of IDs to descriptor and lifetime records.")
(defvar uwumacs--registry-busy nil)
(defvar uwumacs--registry-mode nil
  "Global mode value preserved while a registry callback is running.")
(defvar uwumacs--registry-buffers nil)
(defvar uwumacs--registry-diagnostic nil)
(defvar-local uwumacs--initial-context nil)
(defvar uwumacs-after-integration-hook nil
  "Functions called with an ID after setup, before committing refreshed maps.
Use the public user maps for overrides.  A signalling hook fails that lifetime.
Registry mutations and global activation changes are rejected inside callbacks;
`uwumacs-refresh' is coalesced into the outer transaction's final map build.")

(defun uwumacs--registry-assert-idle (operation)
  "Reject OPERATION before it can recursively mutate a registry callback."
  (when uwumacs--registry-busy
    (error "Cannot %S during a UwUmacs registry callback" operation)))

(defun uwumacs--descriptor (id)
  "Return ID's descriptor from the currently staged registry."
  (plist-get (alist-get id uwumacs--registry) :spec))

(defun uwumacs--validate-descriptor (id spec)
  "Validate ID and the exact public descriptor SPEC without loading anything."
  (unless (and id (symbolp id) (not (keywordp id)))
    (error "Invalid integration ID: %S" id))
  (unless (and (proper-list-p spec) (zerop (% (length spec) 2)))
    (error "%S descriptor must be a property list" id))
  (let (seen)
    (cl-loop for (key value) on spec by #'cddr do
             (unless (and (memq key '(:features :modes :requires :leader-bindings
                                      :local-bindings :state-bindings :initial-state
                                      :setup :capability))
                          (not (memq key seen)))
               (error "%S unknown or repeated descriptor field %S" id key))
             (push key seen)
             (pcase key
               ((or :features :modes :requires)
                (unless (and (proper-list-p value)
                             (cl-every (lambda (item) (and item (symbolp item)
                                                         (not (keywordp item)))) value))
                  (error "%S invalid %S: %S" id key value)))
               (:initial-state
                (unless (memq value '(nil normal motion insert))
                  (error "%S invalid initial state %S" id value)))
               ((or :setup :capability)
                (unless (or (null value)
                            (and (functionp value) (zerop (car (func-arity value)))))
                  (error "%S %S must accept zero arguments" id key)))
               (_
                (unless (proper-list-p value) (error "%S invalid bindings" id))
                (dolist (binding value)
                  (unless (and (proper-list-p binding) (= (length binding) 3))
                    (error "%S invalid binding %S" id binding))
                  (let* ((statep (eq key :state-bindings))
                         (sequence (nth (if statep 1 0) binding))
                         (command (nth (if statep 2 1) binding)))
                    (uwumacs--validated-key-events id sequence)
                    (unless (and command (or (symbolp command) (commandp command)))
                      (error "%S invalid command %S" id command))
                    (unless (if statep (memq (car binding) '(normal motion))
                              (stringp (nth 2 binding)))
                      (error "%S invalid binding %S" id binding))))))))
  ;; Catch self-conflicting maps even before the descriptor is selected.
  (dolist (key '(:leader-bindings :local-bindings))
    (uwumacs--build-map-candidate
     (list (list :owner id :bindings (plist-get spec key)))))
  (dolist (state '(normal motion))
    (uwumacs--build-map-candidate
     (list (list :owner id :bindings
                 (cl-loop for (kind key command) in (plist-get spec :state-bindings)
                          when (eq kind state) collect (list key command ""))))))
  spec)

(defun uwumacs--registry-order ()
  "Return registered IDs in dependency order, rejecting cycles."
  (let (done visiting order)
    (cl-labels ((visit (id)
                  (when (memq id visiting)
                    (error "UwUmacs dependency cycle: %S" (cons id visiting)))
                  (unless (memq id done)
                    (push id visiting)
                    (dolist (dependency (plist-get (uwumacs--descriptor id) :requires))
                      (when (assq dependency uwumacs--registry) (visit dependency)))
                    (setq visiting (delq id visiting))
                    (push id done) (push id order))))
      (dolist (id (append uwumacs-integrations (mapcar #'car uwumacs--registry)))
        (when (assq id uwumacs--registry) (visit id))))
    (nreverse order)))

(defun uwumacs--mode-priority (spec)
  "Return SPEC's nearest major-mode specificity here, or nil when unmatched."
  (let ((modes (plist-get spec :modes)) (lineage (derived-mode-all-parents major-mode)))
    (if (null modes) 0
      (cl-loop for mode in modes
               for tail = (memq mode lineage)
               when tail maximize (length tail) into priority
               finally return priority))))

(defun uwumacs--integration-buffer (spec)
  "Return a live buffer matching SPEC without entering or loading a mode."
  (if (null (plist-get spec :modes)) (current-buffer)
    (cl-find-if (lambda (buffer)
                  (with-current-buffer buffer (uwumacs--mode-priority spec)))
                (buffer-list))))

(defun uwumacs--callable-command-p (command)
  "Return non-nil for an interactive COMMAND with an available autoload target."
  (and (commandp command)
       (let ((definition (if (symbolp command) (indirect-function command) command)))
         (or (not (autoloadp definition))
             (and (stringp (nth 1 definition)) (locate-library (nth 1 definition)))))))

(defun uwumacs--missing-commands (spec)
  "Return unavailable command symbols in SPEC without invoking autoloads."
  (delete-dups
   (cl-loop for key in '(:leader-bindings :local-bindings :state-bindings)
            append (cl-loop for binding in (plist-get spec key)
                            for command = (nth (if (eq key :state-bindings) 2 1) binding)
                            unless (uwumacs--callable-command-p command) collect command))))

(defun uwumacs--readiness (id)
  "Return ID's (STATUS . REASON) from selected dependencies and capabilities."
  (let* ((entry (alist-get id uwumacs--registry)) (spec (plist-get entry :spec))
         (requirements (plist-get spec :requires))
         (missing (cl-find-if (lambda (dep) (or (not (memq dep uwumacs-integrations))
                                               (not (assq dep uwumacs--registry)))) requirements))
         (blocked (cl-find-if (lambda (dep) (not (eq 'ready (plist-get (alist-get dep uwumacs--registry) :status)))) requirements))
         (features (plist-get spec :features))
         (absent (cl-find-if (lambda (feature) (not (or (featurep feature)
                                                       (locate-library (symbol-name feature))))) features)))
    (cond
     ((or (not uwumacs-mode) (not (memq id uwumacs-integrations))) '(disabled))
     ((eq (plist-get entry :status) 'failed) (cons 'failed (plist-get entry :reason)))
     (missing (cons 'unavailable (format "Required integration %S is unselected or unregistered" missing)))
     (blocked (cons (if (memq (plist-get (alist-get blocked uwumacs--registry) :status) '(failed unavailable disabled)) 'unavailable 'pending)
                    (format "Waiting for required integration %S (%s)" blocked (plist-get (alist-get blocked uwumacs--registry) :status))))
     (absent (cons 'unavailable (format "Missing feature library %S" absent)))
     (t
      (condition-case err
          (let ((capability (if-let* ((check (plist-get spec :capability))) (funcall check) t)))
            (cond
             ((stringp capability) (cons 'unavailable capability))
             ((not (eq capability t)) (cons 'failed "Capability must return t or an explanation string"))
             ((not (cl-every #'featurep features)) (cons 'pending (format "Waiting for features %S" (seq-remove #'featurep features))))
             ((uwumacs--missing-commands spec) (cons 'pending (format "Commands not callable: %S" (uwumacs--missing-commands spec))))
             ((and (not (plist-get entry :started)) (not (uwumacs--integration-buffer spec)))
              (cons 'pending (format "Waiting for mode context %S" (plist-get spec :modes))))
             (t '(ready))))
        (error (cons 'failed (error-message-string err))))))))

(defun uwumacs--registry-sources ()
  "Return pure, non-loading native sources for this buffer.
Leader entry points are global at priority zero.  Only local/state sources
use the nearest matching mode's specificity; pending commands must be callable."
  (let (leader local states)
    (dolist (id uwumacs-integrations)
      (let* ((entry (alist-get id uwumacs--registry)) (spec (plist-get entry :spec))
             (status (plist-get entry :status)) (priority (uwumacs--mode-priority spec)))
        (when (memq status '(pending ready))
          (push (list :owner id :priority 0 :bindings
                      (seq-filter (lambda (binding) (uwumacs--callable-command-p (nth 1 binding)))
                                  (plist-get spec :leader-bindings))) leader))
        (when (and (eq status 'ready) priority)
          (push (list :owner id :priority priority :bindings (plist-get spec :local-bindings)) local)
          (dolist (state '(normal motion))
            (push (list :owner id :priority priority :bindings
                        (cl-loop for (kind key command) in (plist-get spec :state-bindings)
                                 when (eq kind state) collect (list key command "")))
                  (alist-get state states))))))
    (list :leader-sources (nreverse leader) :localleader-sources (nreverse local)
          :state-sources states)))

(defun uwumacs--registry-candidates ()
  "Prepare all live buffers against the staged registry before any commit."
  (dolist (buffer uwumacs--registry-buffers)
    (with-current-buffer buffer (uwumacs--initial-winner)))
  (uwumacs--prepare-buffers uwumacs--registry-buffers uwumacs-leader-key uwumacs-localleader-key
                           uwumacs-leader-alt-key))

(defun uwumacs--retire-integration (entry)
  "Retire ENTRY's cleanup once; return an error string if cleanup signals."
  (let ((cleanup (plist-get entry :cleanup)))
    (setf (plist-get entry :cleanup) nil (plist-get entry :started) nil)
    (when cleanup
      (condition-case err (progn (funcall cleanup) nil)
        (error (error-message-string err))))))

(defun uwumacs--registry-transaction (next selected &optional buffer)
  "Validate NEXT registry and SELECTED IDs, then commit lifetimes and maps.
BUFFER narrows a refresh only if global readiness has not changed.
Pre-setup validation preserves the last valid registry/maps on conflict.  A
setup or override failure retires its produced cleanup, records failed and
excludes the failed contribution.  Arbitrary user/setup mutations are owned
by their author; no complete old vendor or user map is restored."
  (let ((old uwumacs--registry) (uwumacs--registry-buffers (buffer-list)) result candidates started)
    (let ((uwumacs--registry next) (uwumacs-integrations selected)
          (uwumacs--registry-busy t) (uwumacs--registry-mode uwumacs-mode)
          (uwumacs--refreshing t))
      (let ((order (uwumacs--registry-order)))
        (dolist (id order)
          (let ((readiness (uwumacs--readiness id)) (entry (alist-get id uwumacs--registry)))
            (setf (plist-get entry :status) (car readiness)
                  (plist-get entry :reason) (cdr readiness))))
        (when (and buffer (equal next old))
          (setq uwumacs--registry-buffers (list buffer)))
        ;; Nothing observable has been replaced if validation signals here.
        (condition-case err
            (setq candidates (when uwumacs-mode (uwumacs--registry-candidates)))
          (error
           (setq uwumacs--registry-diagnostic (error-message-string err))
           (signal (car err) (cdr err))))
        ;; Retire dependants first when a dependency's lifetime is replaced.
        (let (retired)
          (dolist (id order)
            (let ((previous (alist-get id old)) (entry (alist-get id next)))
              (when (or (not (equal (plist-get previous :spec) (plist-get entry :spec)))
                        (not (eq (plist-get entry :status) 'ready))
                        (seq-intersection retired (plist-get (plist-get entry :spec) :requires)))
                (push id retired))))
          (dolist (id (reverse order))
            (when (memq id retired)
              (let ((previous (alist-get id old)) (entry (alist-get id next)))
                (when-let* ((failure (uwumacs--retire-integration previous)))
                  (setf (plist-get entry :status) 'failed
                        (plist-get entry :reason) failure))
                (setf (plist-get entry :cleanup) nil
                      (plist-get entry :started) nil)))))
        (dolist (id order)
          (let* ((entry (alist-get id next)) (spec (plist-get entry :spec))
                 (readiness (uwumacs--readiness id)))
            (setf (plist-get entry :status) (car readiness)
                  (plist-get entry :reason) (cdr readiness))
            (when (and (eq (car readiness) 'ready) (not (plist-get entry :started)))
              (condition-case err
                  (with-current-buffer (or (uwumacs--integration-buffer spec) (current-buffer))
                    (let ((cleanup (when-let* ((setup (plist-get spec :setup))) (funcall setup))))
                      (unless (or (null cleanup)
                                  (and (functionp cleanup) (zerop (car (func-arity cleanup)))))
                        (error "Setup %S did not return a zero-argument cleanup" id))
                      (setf (plist-get entry :cleanup) cleanup (plist-get entry :started) t)
                      (push id started))
                    (run-hook-with-args 'uwumacs-after-integration-hook id)
                    ;; Hooks may change user maps or public base definitions.
                    (setq candidates (uwumacs--registry-candidates)))
                (error
                 (let ((failure (error-message-string err))
                       (cleanup-error (uwumacs--retire-integration entry)))
                   (setf (plist-get entry :status) 'failed
                         (plist-get entry :reason) (if cleanup-error
                                                     (concat failure "; cleanup: " cleanup-error) failure))))))))
        ;; Failed setup/dependencies must never install their staged maps.
        (condition-case err
            (setq candidates (when uwumacs-mode (uwumacs--registry-candidates)))
          (error
           (setq candidates nil uwumacs--registry-diagnostic (error-message-string err))
           ;; A later hook can invalidate an earlier newly prepared lifetime.
           ;; None of those uncommitted lifetimes may claim readiness.
           (dolist (id started)
             (let* ((entry (alist-get id next))
                    (cleanup-error (uwumacs--retire-integration entry)))
               (setf (plist-get entry :status) 'failed
                     (plist-get entry :reason)
                     (concat "Map commit failed: " uwumacs--registry-diagnostic
                             (when cleanup-error (concat "; cleanup: " cleanup-error))))))))
        (setq result uwumacs--registry)))
    (setq uwumacs--registry result uwumacs-integrations selected)
    (when candidates (uwumacs--commit-buffers candidates))
    (when uwumacs-mode
      (dolist (target uwumacs--registry-buffers)
        (when (buffer-live-p target)
          (with-current-buffer target (uwumacs--registry-context-entry)))))))

(defun uwumacs-register-integration (id &rest spec)
  "Validate and register ID with exact descriptor SPEC; return ID.
An equal descriptor is inert.  No package is loaded or installed."
  (uwumacs--registry-assert-idle 'register-integration)
  (uwumacs--validate-descriptor id spec)
  (unless (and (assq id uwumacs--registry) (equal spec (uwumacs--descriptor id)))
    (let ((next (copy-tree uwumacs--registry)))
      (setf (alist-get id next) (list :spec (copy-tree spec) :status 'disabled
                                     :reason nil :started nil :cleanup nil))
      (uwumacs--registry-transaction next (copy-sequence uwumacs-integrations))))
  id)

(defun uwumacs-enable-integration (id)
  "Select registered ID without silently selecting unselected requirements.
Return its readiness status.  Call while `uwumacs-mode' is enabled to activate."
  (uwumacs--registry-assert-idle 'enable-integration)
  (unless (assq id uwumacs--registry) (error "Unregistered integration %S" id))
  (uwumacs--registry-transaction
   (copy-tree uwumacs--registry)
   (if (memq id uwumacs-integrations) (copy-sequence uwumacs-integrations)
     (append uwumacs-integrations (list id))))
  (plist-get (alist-get id uwumacs--registry) :status))

(defun uwumacs-disable-integration (id)
  "Deselect ID and remove its effects, refusing selected dependants."
  (uwumacs--registry-assert-idle 'disable-integration)
  (let ((dependants (seq-filter (lambda (other) (memq id (plist-get (uwumacs--descriptor other) :requires))) uwumacs-integrations)))
    (when dependants (error "Cannot disable %S; selected dependants: %S" id dependants)))
  (uwumacs--registry-transaction (copy-tree uwumacs--registry) (remq id uwumacs-integrations))
  'disabled)

(defun uwumacs--registry-refresh (&optional buffer)
  "Reconsider readiness and rebuild BUFFER, or all if global readiness changed."
  (unless uwumacs--registry-busy
    (uwumacs--registry-transaction (copy-tree uwumacs--registry) (copy-sequence uwumacs-integrations) buffer)))

(defun uwumacs--initial-winner ()
  "Return this buffer's most specific initial-state owner; reject ambiguity."
  (let (winner (highest -1))
    (dolist (id uwumacs-integrations)
      (let* ((entry (alist-get id uwumacs--registry)) (spec (plist-get entry :spec))
             (priority (uwumacs--mode-priority spec)))
        (when (and (eq (plist-get entry :status) 'ready) priority
                   (plist-get spec :initial-state))
          (when (= priority highest)
            (error "UwUmacs initial-state conflict between %S and %S" (car winner) id))
          (when (> priority highest)
            (setq winner (cons id spec) highest priority)))))
    winner))

(defun uwumacs--registry-context-entry ()
  "Apply initial-state policy once upon entering a matching Meow context."
  (when (and uwumacs-mode (not uwumacs--registry-busy) (bound-and-true-p meow-mode)
             (uwumacs--ordinary-buffer-p))
    (let ((winner (uwumacs--initial-winner)))
      (unless (equal winner uwumacs--initial-context)
        (setq uwumacs--initial-context winner)
        (when winner
          (let ((uwumacs--registry-busy t) (uwumacs--registry-mode uwumacs-mode))
            (meow--switch-state (plist-get (cdr winner) :initial-state))))))))

(defun uwumacs--registry-after-load (&rest _)
  "Reconsider lazy readiness after a library load without forcing any load."
  (when (and uwumacs-mode (not uwumacs--registry-busy) (not uwumacs--refreshing))
    (condition-case err (uwumacs--registry-refresh)
      (error (setq uwumacs--registry-diagnostic (error-message-string err))))))

(defun uwumacs--registry-start ()
  "Install the registry's provider and delayed observation once."
  (unless uwumacs-map-context-function
    (setq uwumacs-map-context-function #'uwumacs--registry-sources))
  (add-hook 'after-load-functions #'uwumacs--registry-after-load))

(defun uwumacs--registry-stop ()
  "Retire active lifetimes and observation, retaining explicit selection."
  (remove-hook 'after-load-functions #'uwumacs--registry-after-load)
  (when (eq uwumacs-map-context-function #'uwumacs--registry-sources)
    (setq uwumacs-map-context-function nil))
  (let ((uwumacs--registry-busy t) (uwumacs--registry-mode uwumacs-mode))
    (dolist (id (reverse (uwumacs--registry-order)))
      (let* ((entry (alist-get id uwumacs--registry))
             (failure (uwumacs--retire-integration entry)))
        (setf (plist-get entry :status) (if failure 'failed 'disabled)
              (plist-get entry :reason) failure))))
  (dolist (buffer (buffer-list))
    (with-current-buffer buffer (setq uwumacs--initial-context nil))))

(defun uwumacs-doctor ()
  "Report integration readiness and last binding conflict without repairing."
  (interactive)
  (with-help-window "*UwUmacs Doctor*"
    (princ "UwUmacs integration readiness\n\n")
    (dolist (entry uwumacs--registry)
      (princ (format "%S: %s%s\n" (car entry) (plist-get (cdr entry) :status)
                     (if-let* ((reason (plist-get (cdr entry) :reason)))
                         (concat " â€” " reason) ""))))
    (dolist (id uwumacs-integrations)
      (unless (assq id uwumacs--registry) (princ (format "%S: unavailable â€” unregistered selection\n" id))))
    (when uwumacs--registry-diagnostic
      (princ (concat "\nLast map conflict: " uwumacs--registry-diagnostic "\n")))))

(provide 'uwumacs-registry)
;;; uwumacs-registry.el ends here
