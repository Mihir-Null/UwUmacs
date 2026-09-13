;;; key-hints-gui-tests.el --- Rendered Meow hints -*- lexical-binding: t; -*-
;; Load after ordinary graphical startup and run selector "^dots-hints-gui-".
(require 'ert)

(defmacro dots-hints-gui-in-editor (&rest body)
  "Run BODY from a normal-state editor buffer."
  (declare (indent 0) (debug t))
  `(save-window-excursion
     (let ((buffer (generate-new-buffer " *key-hints-test*")))
       (unwind-protect
           (progn
             (switch-to-buffer buffer)
             (emacs-lisp-mode)
             (meow--switch-state 'normal)
             (should (meow-normal-mode-p))
             ,@body)
         (when (buffer-live-p buffer) (kill-buffer buffer))))))

(ert-deftest dots-hints-gui-keypad-renders-physical-prefix ()
  (skip-unless (display-graphic-p))
  (dots-hints-gui-in-editor
    (let ((unread-command-events (list ?f))
          (meow-keypad-describe-delay 0)
          rendered timer)
      (setq timer
            (run-with-timer
             0.4 nil
             (lambda ()
               (unwind-protect
                   (setq rendered (with-current-buffer which-key--buffer
                                    (buffer-substring-no-properties (point-min) (point-max))))
                 (setq unread-command-events (list 'escape))))))
      (unwind-protect (call-interactively #'meow-keypad)
        (cancel-timer timer))
      (should (string-match-p "SPC f  \\[next key\\]" rendered))
      (should (string-match-p "find-file" rendered))
      (should-not (string-match-p "C-c C-SPC" rendered))
      (setq dots-hints-gui-menu rendered))))

(ert-deftest dots-hints-gui-mx-renders-physical-annotation ()
  (skip-unless (display-graphic-p))
  (dots-hints-gui-in-editor
    (let (rendered timer)
      (unwind-protect
          (condition-case nil
              (minibuffer-with-setup-hook
                  (lambda ()
                    (setq timer
                          (run-with-timer
                           0.3 nil
                           (lambda ()
                             (unwind-protect
                                 (with-current-buffer (window-buffer (active-minibuffer-window))
                                   (insert "consult-line")
                                   (vertico--exhibit)
                                   (setq rendered
                                         (substring-no-properties
                                          (overlay-get vertico--candidates-ov 'before-string))))
                               (setq unread-command-events (list ?\C-g)))))))
                (call-interactively #'execute-extended-command))
            (quit nil))
        (when timer (cancel-timer timer)))
      (should (string-match-p "consult-line" rendered))
      (should (string-match-p (regexp-quote "consult-line (SPC s s)") rendered))
      (setq dots-hints-gui-completion rendered))))

(ert-deftest dots-hints-gui-advertised-keys-execute-command ()
  (skip-unless (display-graphic-p))
  (dots-hints-gui-in-editor
    (let ((keys (starter-meow-command-key 'dashboard-open)))
      (should (equal keys "SPC h"))
      (execute-kbd-macro (kbd keys))
      (should (equal (buffer-name) dashboard-buffer-name)))))

(provide 'key-hints-gui-tests)
