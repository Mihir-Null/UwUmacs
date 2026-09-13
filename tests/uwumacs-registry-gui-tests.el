;;; uwumacs-registry-gui-tests.el --- Native registry entry behavior -*- lexical-binding: t; -*-
(load (expand-file-name "uwumacs-registry-tests.el" (file-name-directory load-file-name)) nil t)

(ert-deftest uwumacs-registry-gui-initial-policy-keeps-user-state-and-input ()
  (should (display-graphic-p))
  (save-window-excursion
    (let ((buffer (generate-new-buffer " *uwumacs-registry-gui*")))
      (unwind-protect
          (progn
            (switch-to-buffer buffer)
            (uwumacs-registry-child-mode)
            (meow-mode 1)
            (uwumacs-registry-test-with-registry
              (uwumacs-register-integration 'editing :modes '(uwumacs-registry-parent-mode)
                :initial-state 'normal :local-bindings '(("x" forward-char "Forward")))
              (uwumacs-enable-integration 'editing)
              (should (bound-and-true-p meow-normal-mode))
              (insert "abc")
              (goto-char (point-min))
              (execute-kbd-macro (kbd "SPC m x"))
              (should (= (point) 2))
              (meow-insert-mode 1)
              (uwumacs-refresh)
              (execute-kbd-macro (kbd "SPC"))
              (should (equal (buffer-string) "a bc"))
              (execute-kbd-macro (kbd "C-c C-SPC m x"))
              (should (= (point) 4))
              (should (bound-and-true-p meow-insert-mode))))
        (when (buffer-live-p buffer) (kill-buffer buffer))))))
