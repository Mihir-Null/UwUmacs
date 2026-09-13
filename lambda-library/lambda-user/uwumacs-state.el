;;; uwumacs-state.el --- Owned native map activation -*- lexical-binding: t; -*-
;; Generated from literate/41-uwumacs-core.org; edit the Org source, then tangle.

;;; Code:

(require 'cl-lib)
(require 'uwumacs-maps)
(declare-function uwumacs--registry-refresh "uwumacs-registry" (&optional buffer))
(declare-function uwumacs--registry-start "uwumacs-registry" ())
(declare-function uwumacs--registry-stop "uwumacs-registry" ())
(declare-function uwumacs--registry-context-entry "uwumacs-registry" ())
(defvar uwumacs-mode nil)

(defvar uwumacs-map-context-function nil
  "Optional no-argument provider of the current buffer's map sources.
Return a plist with :leader-sources, :localleader-sources and :state-sources.
The first two use `uwumacs--build-map-candidate' sources; :state-sources is
an alist from normal/motion to those sources.  Providers must not mutate
active maps or load packages.  Nil provides no contextual bindings.")

(defvar-local uwumacs-localleader-map nil
  "Buffer-owned user localleader map, initialized to a fresh native prefix.
Edit this map for local overrides; major-mode changes reset it.")
(defvar-local uwumacs--buffer-leader-map nil)

(defun uwumacs-localleader-map (&optional buffer)
  "Return BUFFER's effective localleader map, defaulting to the current buffer.
When inactive, return its user map or an empty native map."
  (with-current-buffer (or buffer (current-buffer))
    (or (and uwumacs--buffer-leader-map
             (keymap-lookup uwumacs--buffer-leader-map uwumacs-localleader-key))
        uwumacs-localleader-map (make-sparse-keymap))))

(defvar-local uwumacs--buffer-metadata nil
  "Non-user ownership metadata from the committed buffer candidate.
Plist keys :leader and :localleader contain P01 event-vector tables; :state
is an alist from normal/motion to those tables.  Native user maps remain
above these contributions and are the authority for effective dispatch.")
(defvar-local uwumacs--emulation-alist nil)
(defvar-local uwumacs--literal-active nil)
(defvar-local uwumacs--alternate-active nil)
(defvar-local uwumacs--normal-active nil)
(defvar-local uwumacs--motion-active nil)
(defvar uwumacs--refreshing nil)
(defvar uwumacs--installed nil)
(defvar uwumacs--saved-order nil)
(defvar uwumacs--had-order-table nil)

(defun uwumacs--ordinary-buffer-p ()
  "Return non-nil where core command prefixes are safe.
Terminal adapters may refine this conservative whole-buffer exclusion later."
  (not (or (minibufferp)
           (derived-mode-p 'term-mode 'vterm-mode 'eat-mode)
           (and (derived-mode-p 'eshell-mode)
                (bound-and-true-p eat-terminal))
           (bound-and-true-p meow-beacon-mode)
           (bound-and-true-p meow-keypad-mode))))

(defun uwumacs--update-eligibility (&rest _)
  "Observe current Meow state without changing its grammar."
  (let ((ordinary (and uwumacs-mode (uwumacs--ordinary-buffer-p))))
    (setq uwumacs--alternate-active ordinary
          uwumacs--normal-active (and ordinary (bound-and-true-p meow-mode)
                                      (bound-and-true-p meow-normal-mode))
          uwumacs--motion-active (and ordinary (bound-and-true-p meow-mode)
                                      (bound-and-true-p meow-motion-mode))
          uwumacs--literal-active (or uwumacs--normal-active uwumacs--motion-active))))

(defun uwumacs--reserve-localleader (map key)
  "Reject MAP bindings that would consume the reserved localleader KEY."
  (let* ((events (uwumacs--validated-key-events 'uwumacs-localleader-key key))
         (binding (lookup-key map events)))
    (when binding
      (error "UwUmacs localleader %S conflicts with a leader binding" key))))

(defun uwumacs--buffer-candidate (leader localleader alternate)
  "Build this buffer's native maps using the three supplied prefix strings."
  (let* ((context (when uwumacs-map-context-function
                    (funcall uwumacs-map-context-function)))
         (non-user-candidate
          (uwumacs--build-map-candidate
           (append (uwumacs--public-base-sources) (plist-get context :leader-sources))))
         (non-user-map (plist-get non-user-candidate :map))
         (base (make-composed-keymap
                (list uwumacs-user-leader-map non-user-map uwumacs-leader-map)))
         (local-user (or uwumacs-localleader-map (make-sparse-keymap)))
         (local-candidate (uwumacs--build-map-candidate
                           (plist-get context :localleader-sources)))
         (local-base (plist-get local-candidate :map))
         (local (make-composed-keymap (list local-user local-base)))
         (child (make-sparse-keymap))
         (literal (make-sparse-keymap))
         (modified (make-sparse-keymap))
         state-maps state-metadata)
    (dolist (map (list uwumacs-user-leader-map non-user-map uwumacs-leader-map))
      (uwumacs--reserve-localleader map localleader))
    (uwumacs--ensure-prefixes child (key-parse localleader))
    (keymap-set child localleader local)
    (let ((root (make-composed-keymap (list child base))))
      (keymap-set literal leader root)
      (keymap-set modified alternate root)
      (dolist (state '(normal motion))
        (let* ((candidate (uwumacs--build-map-candidate
                           (alist-get state (plist-get context :state-sources))))
               (state-map (plist-get candidate :map))
              (user (alist-get state uwumacs-user-state-maps)))
          (push (cons state (make-composed-keymap
                             (delq nil (list user literal state-map))))
                state-maps)
          (push (cons state (plist-get candidate :metadata)) state-metadata)))
      (list :root root :local-user local-user
            :metadata (list :leader (plist-get non-user-candidate :metadata)
                            :localleader (plist-get local-candidate :metadata)
                            :state state-metadata)
            :alist `((uwumacs--normal-active . ,(alist-get 'normal state-maps))
                     (uwumacs--motion-active . ,(alist-get 'motion state-maps))
                     (uwumacs--alternate-active . ,modified))))))

(defun uwumacs--prepare-buffers (buffers leader localleader alternate)
  "Build all BUFFERS with LEADER, LOCALLEADER and ALTERNATE before committing."
  (let ((uwumacs--refreshing t))
    (mapcar (lambda (buffer)
              (with-current-buffer buffer
                (cons buffer (uwumacs--buffer-candidate leader localleader alternate))))
            buffers)))

(defun uwumacs--commit-buffers (candidates)
  "Install prepared CANDIDATES without invoking context providers again."
  (let ((uwumacs--refreshing t))
    (dolist (entry candidates)
      (when (buffer-live-p (car entry))
        (with-current-buffer (car entry)
          (setq uwumacs-localleader-map (plist-get (cdr entry) :local-user)
                uwumacs--buffer-leader-map (plist-get (cdr entry) :root)
                uwumacs--emulation-alist (plist-get (cdr entry) :alist)
                uwumacs--buffer-metadata (plist-get (cdr entry) :metadata))
          (uwumacs--update-eligibility))))))

(defun uwumacs-refresh (&optional buffer)
  "Refresh BUFFER, or all live buffers when nil, transactionally when enabled.
Call after changing the public base map or the registry context.  Native user
map edits take effect directly.  A failed candidate
leaves every selected buffer's previous maps intact."
  (interactive)
  (when (and uwumacs-mode (not uwumacs--refreshing))
    (uwumacs--validate-prefix-values uwumacs-leader-key uwumacs-localleader-key
                                     uwumacs-leader-alt-key)
    (if (fboundp 'uwumacs--registry-refresh)
        (uwumacs--registry-refresh buffer)
      (uwumacs--commit-buffers
       (uwumacs--prepare-buffers (if buffer (list buffer) (buffer-list))
                                uwumacs-leader-key uwumacs-localleader-key
                                uwumacs-leader-alt-key)))))

(defun uwumacs--observe-buffer (&rest _)
  "Initialize newly visited buffers and keep input eligibility current."
  (when (and uwumacs-mode (not uwumacs--refreshing))
    (if uwumacs--emulation-alist
        (uwumacs--update-eligibility)
      (uwumacs-refresh (current-buffer)))
    (when (fboundp 'uwumacs--registry-context-entry)
      (uwumacs--registry-context-entry))))

(defconst uwumacs--observation-hooks
  '(meow-switch-state-hook meow-mode-hook meow-normal-mode-hook
    meow-motion-mode-hook meow-insert-mode-hook meow-beacon-mode-hook
    meow-keypad-mode-hook buffer-list-update-hook post-command-hook
    eat-eshell-exec-hook eat-eshell-exit-hook)
  "Hooks owned only while `uwumacs-mode' is active.")

(defun uwumacs--disable ()
  "Remove only UwUmacs-owned activation and restore its ordering metadata."
  (when (fboundp 'uwumacs--registry-stop) (uwumacs--registry-stop))
  (dolist (hook uwumacs--observation-hooks)
    (remove-hook hook #'uwumacs--observe-buffer))
  (remove-hook 'after-change-major-mode-hook #'uwumacs--observe-buffer)
  (setq emulation-mode-map-alists
        (delq 'uwumacs--emulation-alist emulation-mode-map-alists))
  (when uwumacs--installed
    (let ((orders (get 'emulation-mode-map-alists 'list-order)))
      (when (hash-table-p orders)
        (if uwumacs--saved-order
            (puthash 'uwumacs--emulation-alist uwumacs--saved-order orders)
          (remhash 'uwumacs--emulation-alist orders))
        (when (and (not uwumacs--had-order-table) (zerop (hash-table-count orders)))
          (cl-remprop 'emulation-mode-map-alists 'list-order)))))
  (setq uwumacs--installed nil uwumacs--saved-order nil
        uwumacs--had-order-table nil)
  (dolist (buffer (buffer-list))
    (with-current-buffer buffer
      (setq uwumacs--literal-active nil uwumacs--alternate-active nil
            uwumacs--normal-active nil uwumacs--motion-active nil
            uwumacs--emulation-alist nil uwumacs--buffer-leader-map nil
            uwumacs--buffer-metadata nil))))

;;;###autoload
(define-minor-mode uwumacs-mode
  "Use literal native leader maps with Meow and a modified editing fallback."
  :global t :group 'uwumacs
  (if (not uwumacs-mode)
      (uwumacs--disable)
    (condition-case error-data
        (progn
          (when (fboundp 'uwumacs--registry-start) (uwumacs--registry-start))
          (uwumacs-refresh)
          (unless uwumacs--installed
            (setq uwumacs--had-order-table (get 'emulation-mode-map-alists 'list-order)
                  uwumacs--saved-order
                  (when-let* ((orders (get 'emulation-mode-map-alists 'list-order)))
                    (gethash 'uwumacs--emulation-alist orders))
                  uwumacs--installed t))
          (add-to-ordered-list 'emulation-mode-map-alists 'uwumacs--emulation-alist -100)
          (dolist (hook uwumacs--observation-hooks)
            (add-hook hook #'uwumacs--observe-buffer))
          (add-hook 'after-change-major-mode-hook #'uwumacs--observe-buffer))
      (error
       (setq uwumacs-mode nil)
       (uwumacs--disable)
       (signal (car error-data) (cdr error-data))))))

(provide 'uwumacs-state)
;;; uwumacs-state.el ends here
