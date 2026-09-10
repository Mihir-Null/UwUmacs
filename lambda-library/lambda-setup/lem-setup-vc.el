;;; lem-setup-vc.el --- setup for version control -*- lexical-binding: t -*-

;; Author: Colin McLear
;; Maintainer: Colin McLear

;; This file is not part of GNU Emacs

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Version Control -- I use git for version control. Magit is a great interface
;; for git projects. It's much more pleasant to use than the standard git
;; interface on the command line. I've set up some easy keybindings to access
;; magit and related packages.

;;; Code:

;;;; VC
(use-package vc
  :ensure nil
  :defer t
  :custom
  (vc-follow-symlinks t)
  (vc-log-short-style '(file))
  (vc-handled-backends '(Git)))

(use-package vc-git
  :ensure nil
  :after vc
  :config
  (setq vc-git-diff-switches "--patch-with-stat")
  (setq vc-git-print-log-follow t)
  (setq vc-git-revision-complete-only-branches t))

(use-package vc-annotate
  :ensure nil
  :after vc
  :config
  (setq vc-annotate-display-mode 'scale))

;;;; Diff Mode (built-in baseline)
;; EMACS-28+ built-in. Raw top-level setq -- diff-refine,
;; diff-font-lock-prettify, and diff-font-lock-syntax are
;; defcustoms in diff-mode.el with ;;;###autoload cookies, so the
;; symbols are bound before diff-mode.el is lazy-loaded.
(setq diff-refine 'navigation)
(setq diff-font-lock-prettify t)
(setq diff-font-lock-syntax 'hunk-also)

;;;; Smerge Mode (built-in baseline)
;; EMACS-25+ built-in. smerge-command-prefix is NOT autoloaded --
;; it is a defvar inside smerge-mode.el that only binds when the
;; library is loaded. Wrap in with-eval-after-load so the setq
;; fires after the defvar has installed its default, and avoid a
;; byte-compile free-var warning.
(with-eval-after-load 'smerge-mode
  (setq smerge-command-prefix (kbd "C-c v")))

;;;; Magit display-buffer helpers
;; Defined above the magit use-package form so byte-compile sees
;; the symbols before they are referenced in magit's :config via
;; (setq magit-display-buffer-function #'lem-display-magit-in-other-window).
(defun lem-magit-display-buffer-pop-up-frame (buffer)
  "Display magit BUFFER in a new frame when in magit-status-mode."
  (if (with-current-buffer buffer (eq major-mode 'magit-status-mode))
      (display-buffer buffer
                      '((display-buffer-reuse-window
                         display-buffer-pop-up-frame)
                        (reusable-frames . t)))
    (magit-display-buffer-traditional buffer)))

(defun lem-display-magit-in-other-window (buffer)
  "Display magit BUFFER in another window, splitting if necessary."
  (if (one-window-p)
      (progn
        (split-window-right)
        (other-window 1)
        (display-buffer buffer
                        '((display-buffer-reuse-window))))
    (magit-display-buffer-traditional buffer)))

;;;; Magit
(use-package magit
  :when (and lem-load-extras (locate-library "magit"))
  :commands
  (magit-blame-mode
   magit-commit
   magit-diff
   magit-log
   magit-status)
  :hook (git-commit-mode . flyspell-mode)
  :bind ((:map magit-log-mode-map
          ;; Keybindings for use with updating packages interactively
          ("Q" . #'exit-recursive-edit)))
  :init
  ;; Suppress the message we get about "Turning on
  ;; magit-auto-revert-mode" when loading Magit.
  (setq magit-no-message '("Turning on magit-auto-revert-mode..."))
  :config
  (setq magit-log-margin '(t "%Y-%m-%d.%H:%M:%S "  magit-log-margin-width nil 18))
  (setq magit-refresh-status-buffer t)
  ;; Fine grained diffs
  (setq magit-diff-refine-hunk t)
  ;; control magit initial visibility
  (setq magit-section-initial-visibility-alist
        '((stashes . hide) (untracked . hide) (unpushed . hide) ([unpulled status] . show)))
  (global-git-commit-mode t) ; use emacs as editor for git commits

  ;; Refresh the status buffer after saving -- but skip mail/compose
  ;; buffers.  mu4e/message drafts autosave constantly and live outside
  ;; any repo, so magit's per-save `git rev-parse' probe is pointless
  ;; there, and it froze the daemon when that git call stalled.
  (defun cpm-magit-after-save-refresh-status-maybe ()
    "Like `magit-after-save-refresh-status' but not in mail compose buffers."
    (unless (derived-mode-p 'message-mode)
      (magit-after-save-refresh-status)))
  (add-hook 'after-save-hook #'cpm-magit-after-save-refresh-status-maybe t)
  ;; no magit header line as it conflicts w/bespoke-modeline
  (advice-add 'magit-set-header-line-format :override #'ignore)
  ;; display magit setting
  (setq magit-display-buffer-function #'lem-display-magit-in-other-window)
  ;; (setq magit-display-buffer-function #'lem-magit-display-buffer-pop-up-frame)
  )


;;;; Git Commit (built-in to magit 4.x)
;; The standalone git-commit package has not existed since magit
;; 4.x bundled it. Configuration lives at file top-level so
;; byte-compile sees the defun before any :hook reference, and
;; the add-hook calls go inside with-eval-after-load 'git-commit
;; so they only fire once git-commit has actually loaded (which
;; magit's (global-git-commit-mode t) triggers in its :config).
;; Constraint C-7: Spec 04 assumes magit >= 4.0.0.
(defun cpm/git-commit-auto-fill-everywhere ()
  "Ensure the commit body does not exceed 80 characters."
  (setq fill-column 80)
  (setq-local comment-auto-fill-only-comments nil))

(setq-default git-commit-summary-max-length 50)

(with-eval-after-load 'git-commit
  (add-hook 'git-commit-mode-hook #'cpm/git-commit-auto-fill-everywhere)
  (with-eval-after-load 'meow
    (add-hook 'git-commit-mode-hook
              (lambda () (meow-insert-mode)))))

;;;; Git Gutter HL (Diff-HL)
;; Nice vc highlighting in margin/fringe
;; See https://www.reddit.com/r/emacs/comments/suxc9b/modern_gitgutter_in_emacs/
;; And https://github.com/jimeh/.emacs.d/blob/master/modules/version-control/siren-diff-hl.el

(use-package diff-hl
  :when (and lem-load-extras (locate-library "diff-hl"))
  :hook
  ((prog-mode . (lambda () (when (cpm--should-enable-diff-hl) (diff-hl-mode))))
   (text-mode . diff-hl-mode)
   ;; diff-hl-dired-mode's async git filter races with daemon frame
   ;; creation and wedges in a directory-files open() syscall.
   ;; diff-hl-magit-pre-refresh is obsolete (a no-op since diff-hl
   ;; 1.11); only the post-refresh hook is still needed.
   (magit-post-refresh . diff-hl-magit-post-refresh))
  :custom
  (diff-hl-update-async t)
  (diff-hl-side 'left)
  (diff-hl-fringe-bmp-function 'cpm--diff-hl-fringe-bmp-from-type)
  (diff-hl-fringe-face-function 'cpm--diff-hl-fringe-face-from-type)
  (diff-hl-margin-symbols-alist
   '((insert . "┃")
     (delete . "┃")
     (change . "┃")
     (unknown . "?")
     (ignored . "i")
     (reference . "*")))
  :init
  (defun cpm--should-enable-diff-hl ()
    "Check if diff-hl should be enabled in current buffer."
    (and buffer-file-name
         (not (string-match-p "/\\.#" buffer-file-name)) ; avoid lockfiles
         (vc-backend buffer-file-name))) ; only if under version control

  (defun cpm--diff-hl-fringe-face-from-type (type _pos)
    (intern (format "diff-hl-%s" type)))

  (defun cpm--diff-hl-fringe-bmp-from-type(type _pos)
    (intern (format "diff-hl-%s" type)))
  :config
  (diff-hl-margin-mode 1)
  (define-fringe-bitmap 'diff-hl-insert
    [#b00000011] nil nil '(center repeated))
  (define-fringe-bitmap 'diff-hl-change
    [#b00000011] nil nil '(center repeated))
  (define-fringe-bitmap 'diff-hl-delete
    [#b00000011] nil nil '(center repeated)))

;;;; Diff Files with Vdiff
(use-package vdiff-magit
  :when (and lem-load-extras (locate-library "vdiff-magit"))
  :defer t
  :init
  (with-eval-after-load 'magit
    (define-key magit-mode-map "e" #'vdiff-magit-dwim)
    (define-key magit-mode-map "E" #'vdiff-magit)
    (transient-suffix-put 'magit-dispatch "e" :description "vdiff (dwim)")
    (transient-suffix-put 'magit-dispatch "e" :command 'vdiff-magit-dwim)
    (transient-suffix-put 'magit-dispatch "E" :description "vdiff")
    (transient-suffix-put 'magit-dispatch "E" :command 'vdiff-magit)))

;;;; Ediff
;; Don't open ediff in new frame
(setq ediff-window-setup-function 'ediff-setup-windows-plain)

;;;; Quick Commits
;; Make a quick commit without opening magit. This is a version of a
;; workflow I used to use in Sublime Text. Perfect for short commit messages.
(defun lem-quick-commit ()
  "Quickly commit the current file-visiting buffer from the mini-buffer."
  (interactive)
  (shell-command (concat "git add " (buffer-file-name) " && git commit -m '" (read-string "Enter commit message: ") "'")))

;;; End Setup VC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(provide 'lem-setup-vc)
;;; lem-setup-vc.el ends here
