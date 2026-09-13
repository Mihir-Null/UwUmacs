;;; uwumacs-maps.el --- Native map construction for UwUmacs -*- lexical-binding: t; -*-
;; Generated from literate/41-uwumacs-core.org; edit the Org source, then tangle.

;;; Code:

(require 'cl-lib)
(require 'seq)
(require 'subr-x)

(declare-function uwumacs--prepare-buffers "uwumacs-state" (buffers leader localleader alternate))
(declare-function uwumacs--commit-buffers "uwumacs-state" (candidates))

(defconst uwumacs--prefix-default-values
  '((uwumacs-leader-key . "SPC")
    (uwumacs-localleader-key . "m")
    (uwumacs-leader-alt-key . "C-c C-SPC"))
  "Defaults used while Customize initializes the interdependent prefixes.")

(defun uwumacs--prefix-value (symbol)
  "Return SYMBOL's current default value, or its UwUmacs bootstrap default."
  (if (boundp symbol)
      (default-value symbol)
    (alist-get symbol uwumacs--prefix-default-values)))

(defun uwumacs--validated-key-events (symbol value)
  "Return parsed events for SYMBOL's key string VALUE, or signal an error."
  (unless (and (stringp value) (not (string-empty-p value)))
    (error "%s must be a non-empty key string" symbol))
  (condition-case nil
      (progn
        (unless (key-valid-p value)
          (error "%s is not a valid key string: %S" symbol value))
        (vconcat (key-parse value)))
    (error (error "%s is not a valid key string: %S" symbol value))))

(defun uwumacs--events-prefix-p (left right)
  "Return non-nil when event vector LEFT is a prefix of RIGHT."
  (and (<= (length left) (length right))
       (equal left (seq-take right (length left)))))

(defun uwumacs--validate-prefix-values (leader localleader alternate)
  "Validate LEADER, LOCALLEADER and ALTERNATE as an unambiguous prefix set."
  (let ((leader-events
         (uwumacs--validated-key-events 'uwumacs-leader-key leader))
        (_localleader-events
         (uwumacs--validated-key-events 'uwumacs-localleader-key localleader))
        (alternate-events
         (uwumacs--validated-key-events 'uwumacs-leader-alt-key alternate)))
    (when (or (uwumacs--events-prefix-p leader-events alternate-events)
              (uwumacs--events-prefix-p alternate-events leader-events))
      (error "uwumacs-leader-key and uwumacs-leader-alt-key overlap: %S, %S"
             leader alternate)))
  t)

(defun uwumacs--set-prefix-option (symbol value)
  "Validate and set prefix customization SYMBOL to VALUE transactionally."
  (let ((leader (if (eq symbol 'uwumacs-leader-key)
                    value
                  (uwumacs--prefix-value 'uwumacs-leader-key)))
        (localleader (if (eq symbol 'uwumacs-localleader-key)
                         value
                       (uwumacs--prefix-value 'uwumacs-localleader-key)))
        (alternate (if (eq symbol 'uwumacs-leader-alt-key)
                       value
                     (uwumacs--prefix-value 'uwumacs-leader-alt-key))))
    (uwumacs--validate-prefix-values leader localleader alternate)
    (let ((candidates
           (when (fboundp 'uwumacs--prepare-buffers)
             (uwumacs--prepare-buffers
              (if (bound-and-true-p uwumacs-mode) (buffer-list) (list (current-buffer)))
              leader localleader alternate))))
      (set-default symbol value)
      (when (and candidates (bound-and-true-p uwumacs-mode))
        (uwumacs--commit-buffers candidates)))))

(defcustom uwumacs-leader-key "SPC"
  "Literal leader key used in eligible Normal and Motion buffers."
  :type 'string
  :set #'uwumacs--set-prefix-option
  :group 'uwumacs)

(defcustom uwumacs-localleader-key "m"
  "Suffix below `uwumacs-leader-key' used for buffer-local commands."
  :type 'string
  :set #'uwumacs--set-prefix-option
  :group 'uwumacs)

(defcustom uwumacs-leader-alt-key "C-c C-SPC"
  "Modified leader available in ordinary editing buffers, including Insert."
  :type 'string
  :set #'uwumacs--set-prefix-option
  :group 'uwumacs)

(defcustom uwumacs-integrations nil
  "Ordered integration IDs selected by the host.
Core does not select or install packages by default."
  :type '(repeat symbol)
  :group 'uwumacs)

(defvar uwumacs-leader-map (make-sparse-keymap)
  "Public base leader map, initially built from validated definitions.
Call `uwumacs-refresh' after native edits to reconcile ownership and priorities.")

(defvar uwumacs-user-leader-map (make-sparse-keymap)
  "Public user override map composed above `uwumacs-leader-map'.
A nil binding falls through to lower maps; `undefined' explicitly blocks one.")

(defvar uwumacs-user-state-maps nil
  "Alist from the state symbols `normal' and `motion' to user keymaps.")

(defvar uwumacs--leader-sources nil
  "Validated foundational sources, retained for contextual collision checks.")

(defvar uwumacs--leader-metadata nil
  "Alist from native key-event vectors to owner/label plists for the active map.")

(defun uwumacs--binding-key-events (key owner)
  "Return parsed KEY events, naming OWNER when validation fails."
  (condition-case nil
      (progn
        (cond
         ;; Native vectors are internal map-reconciliation input, not a new
         ;; public integration descriptor syntax.
         ((and (vectorp key) (> (length key) 0)) (copy-sequence key))
         ((and (stringp key) (not (string-empty-p key)) (key-valid-p key))
          (vconcat (key-parse key)))
         (t (error "invalid"))))
    (error (error "UwUmacs owner %S has an invalid key: %S" owner key))))

(defun uwumacs--binding-metadata (key &rest metadata-argument)
  "Return owner/label metadata for KEY.
Use the active table when METADATA-ARGUMENT is omitted; an explicit nil means
an empty candidate table.  KEY is compared by native event identity."
  (let ((metadata (if metadata-argument
                      (car metadata-argument)
                    uwumacs--leader-metadata)))
    (cdr (assoc (uwumacs--binding-key-events key 'metadata-query) metadata))))

(defun uwumacs--effective-leader-map ()
  "Return a native map with user bindings above the validated base map."
  (make-composed-keymap (list uwumacs-user-leader-map uwumacs-leader-map)))

(defun uwumacs--binding-conflict (events seen)
  "Return the entry in SEEN whose events overlap EVENTS, if any."
  (cl-find-if
   (lambda (entry)
     (let ((other (plist-get entry :events)))
       (or (uwumacs--events-prefix-p events other)
           (uwumacs--events-prefix-p other events))))
   seen))

(defun uwumacs--ensure-prefixes (map events)
  "Create the missing native prefix maps below MAP for EVENTS."
  (cl-loop for depth from 1 below (length events)
           for prefix = (seq-take events depth)
           for key = (key-description prefix)
           for definition = (lookup-key map prefix)
           do (cond
               ((null definition)
                (define-key map prefix (make-sparse-keymap)))
               ((not (keymapp definition))
                (error "Cannot build native prefix %s over %S" key definition)))))

(defun uwumacs--validate-source (source)
  "Validate one non-user binding SOURCE and return it."
  (let ((owner (plist-get source :owner))
        (priority (or (plist-get source :priority) 0))
        (bindings (plist-get source :bindings)))
    (unless (symbolp owner)
      (error "UwUmacs map source owner must be a symbol: %S" owner))
    (unless (integerp priority)
      (error "UwUmacs owner %S has a non-integer priority: %S" owner priority))
    (unless (listp bindings)
      (error "UwUmacs owner %S bindings must be a list" owner))
    (dolist (binding bindings)
      (pcase binding
        (`(,key ,definition ,label)
         (uwumacs--binding-key-events key owner)
         (unless (and definition (stringp label))
           (error "UwUmacs owner %S has an invalid binding: %S" owner binding)))
        (_ (error "UwUmacs owner %S has an invalid binding: %S" owner binding))))
    source))

(defun uwumacs--build-priority-layer (priority sources)
  "Build PRIORITY's native map and metadata from SOURCES.
Return a cons whose car is the map and whose cdr is its metadata alist."
  (let ((map (make-sparse-keymap))
        seen
        metadata)
    (dolist (source sources)
      (when (= priority (or (plist-get source :priority) 0))
        (let ((owner (plist-get source :owner)))
          (dolist (binding (plist-get source :bindings))
            (pcase-let ((`(,key ,definition ,label) binding))
              (let* ((events (uwumacs--binding-key-events key owner))
                     (conflict (uwumacs--binding-conflict events seen)))
                (when conflict
                  (error
                   "UwUmacs map conflict at priority %d: %S (%s) conflicts with %S (%s)"
                   priority owner key (plist-get conflict :owner)
                   (plist-get conflict :key)))
                (push (list :events events :key key :owner owner) seen)
                (uwumacs--ensure-prefixes map events)
                (define-key map events definition)
                (push (cons events (list :owner owner :label label)) metadata)))))))
    (cons map (nreverse metadata))))

(defun uwumacs--build-map-candidate (sources)
  "Build and return a validated map candidate from non-user SOURCES.

Each source is `(:owner OWNER :priority INTEGER :bindings BINDINGS)', where
BINDINGS contains `(KEY DEFINITION LABEL)' entries.  Higher priorities compose
above lower ones.  The returned plist has `:map' and `:metadata' entries and
does not mutate active UwUmacs state."
  (setq sources (mapcar #'uwumacs--validate-source sources))
  (let ((priorities
         (sort (delete-dups
                (mapcar (lambda (source)
                          (or (plist-get source :priority) 0))
                        sources))
               #'>))
        maps
        metadata)
    (dolist (priority priorities)
      (pcase-let ((`(,map . ,layer-metadata)
                   (uwumacs--build-priority-layer priority sources)))
        (push map maps)
        (dolist (entry layer-metadata)
          (unless (assoc (car entry) metadata)
            (push entry metadata)))))
    (setq maps (nreverse maps))
    (list :map (if maps
                   (make-composed-keymap maps)
                 (make-sparse-keymap))
          :metadata (nreverse metadata))))

(defun uwumacs--native-map-bindings (map)
  "Return effective (EVENTS . DEFINITION) entries from native MAP.
Keep event vectors and raw menu items; skip inherited shadowed entries.
Plain prefixes are traversed natively, including parents and composed maps."
  (let (bindings opaque-prefixes)
    (dolist (entry (accessible-keymaps map))
      (let ((prefix (car entry))
            (seen (make-hash-table :test 'equal)))
        (unless (cl-some (lambda (opaque)
                           (uwumacs--events-prefix-p opaque prefix))
                         opaque-prefixes)
          (map-keymap
           (lambda (event definition)
             (when (and definition (not (gethash event seen)))
               (puthash event t seen)
               (let ((events (vconcat prefix (vector event))))
                 (unless (keymapp definition)
                   ;; Preserve menu filters as native definitions.  If such an
                   ;; item denotes a prefix, do not duplicate its descendants.
                   (when (eq (car-safe definition) 'menu-item)
                     (push events opaque-prefixes))
                   (push (cons events definition) bindings)))))
           (cdr entry)))))
    (nreverse bindings)))

(defun uwumacs--public-base-sources ()
  "Reconcile live public base bindings with their retained declarations.
An unchanged binding keeps its declaration's owner, priority and label.
Changed/new bindings belong to `public-base' at priority zero; removals
contribute nothing.  Native event vectors never round-trip through text."
  (let (declarations sources)
    (dolist (source uwumacs--leader-sources)
      (dolist (binding (plist-get source :bindings))
        (pcase-let ((`(,key ,definition ,label) binding))
          (let* ((events (uwumacs--binding-key-events key (plist-get source :owner)))
                 (entries (if (keymapp definition)
                              (uwumacs--native-map-bindings definition)
                            (list (cons [] definition)))))
            (dolist (entry entries)
              (push (list :events (vconcat events (car entry))
                          :definition (cdr entry) :owner (plist-get source :owner)
                          :priority (or (plist-get source :priority) 0) :label label)
                    declarations))))))
    (dolist (entry (uwumacs--native-map-bindings uwumacs-leader-map))
      (let ((events (car entry)) (definition (cdr entry)) match)
        (dolist (declaration declarations)
          (when (and (equal events (plist-get declaration :events))
                     (equal definition (plist-get declaration :definition))
                     (or (not match)
                         (> (plist-get declaration :priority)
                            (plist-get match :priority))))
            (setq match declaration)))
        (push (list :owner (if match (plist-get match :owner) 'public-base)
                    :priority (if match (plist-get match :priority) 0)
                    :bindings (list (list events definition
                                          (if match (plist-get match :label)
                                            (key-description events)))))
              sources)))
    (nreverse sources)))

(defun uwumacs--replace-leader-definitions (sources)
  "Validate SOURCES, then atomically replace the active base map and metadata."
  (let ((candidate (uwumacs--build-map-candidate sources)))
    (setq uwumacs-leader-map (plist-get candidate :map)
          uwumacs--leader-metadata (plist-get candidate :metadata)
          uwumacs--leader-sources (copy-tree sources)))
  uwumacs-leader-map)

(provide 'uwumacs-maps)
;;; uwumacs-maps.el ends here
