;;; uwumacs-vc.el --- Magit and version control -*- lexical-binding: t; -*-
;; Generated from literate/66-vc.org; edit the Org source, then tangle.

;; Distilled from Lambda-Emacs by Colin McLear (GPL-3.0-or-later).

;;; Code:

(require 'uwumacs-leader)

(setopt vc-follow-symlinks t
        vc-handled-backends '(Git)
        vc-log-short-style '(file)
        vc-git-diff-switches "--patch-with-stat"
        vc-git-print-log-follow t
        vc-git-revision-complete-only-branches t
        vc-annotate-display-mode 'scale
        diff-refine 'navigation
        diff-font-lock-prettify t
        diff-font-lock-syntax 'hunk-also
        ediff-window-setup-function #'ediff-setup-windows-plain)

(with-eval-after-load 'smerge-mode
  (setopt smerge-command-prefix (kbd "C-c v")))
(defun uwumacs-magit-display-buffer (buffer)
  "Show Magit BUFFER in a frame under frames-only mode, otherwise traditionally."
  (if (and (bound-and-true-p frames-only-mode) (display-graphic-p))
      (display-buffer buffer '((display-buffer-reuse-window display-buffer-pop-up-frame)
                               (reusable-frames . t)))
    (magit-display-buffer-traditional buffer)))

(use-package magit
  :ensure t
  :commands (magit-status magit-log magit-diff magit-commit magit-blame magit-dispatch magit-file-dispatch)
  :hook (git-commit-mode . flyspell-mode)
  :custom
  (magit-display-buffer-function #'uwumacs-magit-display-buffer)
  (magit-diff-refine-hunk t)
  (magit-log-margin '(t "%Y-%m-%d %H:%M " magit-log-margin-width nil 18))
  (magit-section-initial-visibility-alist '((stashes . hide) (untracked . hide) (unpushed . hide)))
  (magit-no-message '("Turning on magit-auto-revert-mode..."))
  (git-commit-summary-max-length 50)
  :config
  (add-hook 'after-save-hook #'magit-after-save-refresh-status t)
  (defun uwumacs--git-commit-fill ()
    "Wrap commit message bodies at eighty columns."
    (setq fill-column 80)
    (setq-local comment-auto-fill-only-comments nil))
  (add-hook 'git-commit-setup-hook #'uwumacs--git-commit-fill))
(with-eval-after-load 'meow
  (add-to-list 'meow-mode-state-list '(magit-mode . motion))
  (add-hook 'git-commit-setup-hook #'meow-insert-mode))

(uwumacs-define-localleader 'magit-mode
  "s" (cons "stage" #'magit-stage)
  "u" (cons "unstage" #'magit-unstage)
  "c" (cons "commit" #'magit-commit)
  "p" (cons "push" #'magit-push)
  "F" (cons "pull" #'magit-pull)
  "f" (cons "fetch" #'magit-fetch)
  "b" (cons "branch" #'magit-branch)
  "m" (cons "merge" #'magit-merge)
  "r" (cons "rebase" #'magit-rebase)
  "z" (cons "stash" #'magit-stash)
  "l" (cons "log" #'magit-log)
  "d" (cons "diff" #'magit-diff)
  "x" (cons "discard" #'magit-discard)
  "g" (cons "refresh" #'magit-refresh)
  "?" (cons "all commands" #'magit-dispatch))

(provide 'uwumacs-vc)
;;; uwumacs-vc.el ends here
