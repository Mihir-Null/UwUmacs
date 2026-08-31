;;; check-elisp.el --- Parse every user-layer Elisp file -*- lexical-binding: t; -*-

(let ((failed nil)
      (root (expand-file-name "../lambda-library/lambda-user/"
                              (file-name-directory load-file-name))))
  (dolist (file (directory-files-recursively root "\\.el\\'"))
    (condition-case error-data
        (with-temp-buffer
          (insert-file-contents file)
          (emacs-lisp-mode)
          (check-parens)
          (message "check-parens: %s" file))
      (error
       (setq failed t)
       (message "check-parens FAILED: %s: %S" file error-data))))
  (when failed
    (kill-emacs 1)))

;;; check-elisp.el ends here
