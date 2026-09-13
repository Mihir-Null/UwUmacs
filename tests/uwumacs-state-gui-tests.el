;;; uwumacs-state-gui-tests.el --- Real command-loop state checks -*- lexical-binding: t; -*-
(load (expand-file-name "uwumacs-test-helper.el" (file-name-directory load-file-name)) nil t)
(load (expand-file-name "uwumacs-state-tests.el" (file-name-directory load-file-name)) nil t)

(ert-deftest uwumacs-state-gui-native-command-loop ()
  (should (display-graphic-p))
  (save-window-excursion
    (let ((buffer (generate-new-buffer " *uwumacs-state-gui*")))
      (unwind-protect
          (progn
            (switch-to-buffer buffer)
            (emacs-lisp-mode)
            (uwumacs-test-with-meow-state 'normal
              (uwumacs-state-test-with-mode
                (keymap-set uwumacs-localleader-map "x" #'forward-char)
                (insert "abcdef")
                (goto-char (point-min))
                (execute-kbd-macro (kbd "C-u 2 SPC m x"))
                (should (= (point) 3))
                (uwumacs-test-enter-meow-state 'insert)
                (execute-kbd-macro (kbd "SPC"))
                (should (equal (buffer-string) "ab cdef"))
                (execute-kbd-macro (kbd "C-c C-SPC m x"))
                (should (= (point) 5)))))
        (when (buffer-live-p buffer) (kill-buffer buffer))))))
