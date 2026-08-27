;;; starter-setup-org.el --- Minimal portable Org policy -*- lexical-binding: t; -*-

;;; Commentary:
;; Lambda supplies the substantial Org configuration. This module owns only enough
;; user policy for agenda/capture to work on a fresh machine.

;;; Code:

(require 'starter-platform)

(unless (file-directory-p starter-org-directory)
  (make-directory starter-org-directory t))

(setopt org-directory starter-org-directory
        org-default-notes-file (expand-file-name "inbox.org" starter-org-directory)
        org-agenda-files (list starter-org-directory))

(with-eval-after-load 'org
  (setopt org-log-done 'time
          org-catch-invisible-edits 'show-and-error
          org-M-RET-may-split-line '((default . nil)))

  ;; Intentionally simple starter captures; replace them once your actual workflow is
  ;; understood rather than inheriting another person's ontology.
  (setopt org-capture-templates
          `(("t" "Inbox TODO" entry
             (file ,org-default-notes-file)
             "* TODO %?\n  %U\n")
            ("n" "Inbox note" entry
             (file ,org-default-notes-file)
             "* %?\n  %U\n"))))

(provide 'starter-setup-org)
;;; starter-setup-org.el ends here
