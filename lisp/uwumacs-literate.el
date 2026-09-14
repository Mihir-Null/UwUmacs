;;; uwumacs-literate.el --- Edit and build the literate source -*- lexical-binding: t; -*-
;; Generated from literate/80-maintenance.org; edit the Org source, then tangle.
;;; Commentary:
;; Development addition: keep authoring explicit and startup independent of Org.
;;; Code:

(defun uwumacs-literate-open (&rest _)
  "Open the literate configuration's reading guide."
  (interactive)
  (find-file (expand-file-name "literate/index.org" user-emacs-directory)))
(defun uwumacs-literate--build (write)
  "Run the isolated literate builder; WRITE selects generation over checking."
  (let ((source-dir (expand-file-name "literate/" user-emacs-directory))
        (output (get-buffer-create "*UwUmacs literate build*")))
    (dolist (buffer (buffer-list))
      (when-let* ((file (buffer-file-name buffer)))
        (when (and (file-in-directory-p file source-dir)
                   (buffer-modified-p buffer))
          (user-error "Save %s before building the literate configuration" file))))
    (with-current-buffer output
      (let ((inhibit-read-only t)) (erase-buffer)))
    (let ((status
           (call-process (expand-file-name invocation-name invocation-directory)
                         nil (list output t) nil
                         "-Q" "--batch" "-l"
                         (expand-file-name "tools/tangle.el" user-emacs-directory)
                         "--" (if write "--write" "--check"))))
      (display-buffer output)
      (unless (equal status 0)
        (user-error "Literate build failed; see %s" (buffer-name output)))
      (message (if write
                   "Lisp regenerated. Restart Emacs to apply configuration changes."
                 "Literate sources and deployed Lisp agree.")))))
(defun uwumacs-literate-tangle ()
  "Regenerate deployed Lisp from saved literate sources."
  (interactive)
  (uwumacs-literate--build t))
(defun uwumacs-literate-check ()
  "Check that deployed Lisp matches saved literate sources without writing it."
  (interactive)
  (uwumacs-literate--build nil))
(provide 'uwumacs-literate)
;;; uwumacs-literate.el ends here
