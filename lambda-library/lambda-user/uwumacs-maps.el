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
  "Public base leader map built from validated non-user definitions.")

(defvar uwumacs-user-leader-map (make-sparse-keymap)
  "Public user override map composed above `uwumacs-leader-map'.
A nil binding falls through to lower maps; `undefined' explicitly blocks one.")

(defvar uwumacs-user-state-maps nil
  "Alist from the state symbols `normal' and `motion' to user keymaps.")

(defvar uwumacs--leader-metadata nil
  "Alist from native key-event vectors to owner/label plists for the active map.")

(defun uwumacs--binding-key-events (key owner)
  "Return parsed KEY events, naming OWNER when validation fails."
  (condition-case nil
      (progn
        (unless (and (stringp key) (not (string-empty-p key))
                     (key-valid-p key))
          (error "invalid"))
        (vconcat (key-parse key)))
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
           for definition = (keymap-lookup map key)
           do (cond
               ((null definition)
                (keymap-set map key (make-sparse-keymap)))
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
                (keymap-set map key definition)
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

(defun uwumacs--replace-leader-definitions (sources)
  "Validate SOURCES, then atomically replace the active base map and metadata."
  (let ((candidate (uwumacs--build-map-candidate sources)))
    (setq uwumacs-leader-map (plist-get candidate :map)
          uwumacs--leader-metadata (plist-get candidate :metadata)))
  uwumacs-leader-map)

(provide 'uwumacs-maps)
;;; uwumacs-maps.el ends here
