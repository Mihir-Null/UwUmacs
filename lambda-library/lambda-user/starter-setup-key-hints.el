;;; starter-setup-key-hints.el --- Physical keys in Meow hints -*- lexical-binding: t; -*-
;; Generated from literate/40-editing.org; edit the Org source, then tangle.

;;; Code:
(require 'cl-lib)
(require 'seq)
(require 'meow)
(require 'which-key)

(defun starter-meow-physical-leader-p ()
  "Whether the starter's semantic, unmodified SPC leader policy is in use."
  (not (or meow-keypad-leader-dispatch meow-keypad-start-keys
           meow-keypad-meta-prefix meow-keypad-ctrl-meta-prefix
           meow-keypad-literal-prefix)))
(defun starter-meow--leader-binding (leader physical)
  "Resolve printable PHYSICAL keys through LEADER using Meow's lookup rules."
  (let ((prefix []) binding)
    (catch 'unreachable
      (seq-doseq (event physical)
        (when (and (> (length prefix) 0) (not (keymapp binding)))
          (throw 'unreachable nil))
        (let* ((literal (vconcat prefix (vector event)))
               (control (and (> (length prefix) 0)
                             (vconcat prefix
                                      (kbd (meow--keypad-format-key-1
                                            (cons 'control (single-key-description event)))))))
               (controlled (and control (lookup-key leader control))))
          (setq prefix (if (or (keymapp controlled) (commandp controlled t))
                           control literal)
                binding (lookup-key leader prefix))))
      binding)))

(defun starter-meow-command-key (command)
  "Return a reachable physical SPC shortcut for COMMAND in the current state."
  (when (and (starter-meow-physical-leader-p)
             (or (bound-and-true-p meow-normal-mode)
                 (bound-and-true-p meow-motion-mode)))
    (let* ((leader (alist-get 'leader meow-keymap-alist))
           (bindings (and (keymapp leader)
                          (where-is-internal command (list leader) nil nil t))))
      (cl-loop for keys in (sort bindings (lambda (a b) (< (length a) (length b))))
               for physical = (vconcat (mapcar #'meow--get-event-key keys))
               when (and (seq-every-p
                          (lambda (event)
                            (and (integerp event) (<= 32 event 126)
                                 (cl-subsetp (event-modifiers event) '(shift))))
                          physical)
                         (seq-every-p
                          (lambda (event)
                            (cl-subsetp (event-modifiers event) '(control shift)))
                          keys)
                         (eq (starter-meow--leader-binding leader physical) command))
               return (concat "SPC " (key-description physical))))))
(defun starter-meow-keypad-prompt ()
  "Describe the physical leader keys entered so far."
  (if (starter-meow-physical-leader-p)
      (concat (when meow--keypad-help "Describe key: ")
              (when meow--prefix-arg (format "(argument %s) " meow--prefix-arg))
              "SPC"
              (when meow--keypad-keys
                (concat " " (mapconcat #'cdr (reverse meow--keypad-keys) " "))))
    (concat meow-keypad-message-prefix (meow--keypad-format-keys))))

(defun starter-meow-keypad-show-message (original)
  "Show physical input when supported, otherwise call ORIGINAL."
  (if (starter-meow-physical-leader-p)
      (let ((message-log-max nil))
        (message "%s" (starter-meow-keypad-prompt)))
    (funcall original)))

(defun starter-meow-keypad-describe (keymap)
  "Display Meow's physical next-key KEYMAP with the physical prefix title."
  (let ((which-key-show-prefix 'top))
    (which-key--create-buffer-and-show
     nil keymap nil (concat (starter-meow-keypad-prompt) "  [next key]"))))

(defun starter-meow-install-keypad-hints ()
  "Use physical prefix titles while Which-key is enabled."
  (when (bound-and-true-p which-key-mode)
    (setq meow-keypad-describe-keymap-function #'starter-meow-keypad-describe
          meow-keypad-clear-describe-keymap-function #'which-key--hide-popup)))

(advice-add 'meow--keypad-show-message :around #'starter-meow-keypad-show-message)
;; Run after Meow's own hook when Which-key is toggled on again.
(add-hook 'which-key-mode-hook #'starter-meow-install-keypad-hints t)
(starter-meow-install-keypad-hints)
(defun starter-meow-annotate-binding (original candidate)
  "Prefer physical Meow keys for CANDIDATE; otherwise use ORIGINAL."
  (if-let* ((command (intern-soft candidate))
            (keys (starter-meow-command-key command)))
      (propertize (format " (%s)" keys) 'face 'marginalia-key)
    (funcall original candidate)))

(with-eval-after-load 'marginalia
  (advice-add 'marginalia-annotate-binding :around #'starter-meow-annotate-binding))

(provide 'starter-setup-key-hints)
;;; starter-setup-key-hints.el ends here
