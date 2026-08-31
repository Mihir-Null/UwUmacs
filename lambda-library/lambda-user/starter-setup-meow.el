;;; starter-setup-meow.el --- Selection-first editing -*- lexical-binding: t; -*-

;; Adapted from Colin McLear's cpm-setup-meow.el (GPL-3.0-or-later).

;;; Commentary:
;; Meow is the interaction model, not a compatibility layer beneath Firemacs.
;; Firemacs-inspired bindings are added only on unused modified keys; Meow's
;; selection verbs, things, `f', `;', and motion grammar remain authoritative.

;;; Code:

(defun starter-meow-setup ()
  "Install starter Meow motion, leader, and normal-state bindings."
  (meow-motion-overwrite-define-key
   '("j" . meow-next)
   '("k" . meow-prev))

  ;; Reuse Lambda's semantic maps instead of maintaining a second hierarchy.
  (add-to-list 'meow-keymap-alist (cons 'leader lem+leader-map))

  (setq meow-keypad-meta-prefix nil
        meow-keypad-ctrl-meta-prefix nil
        meow-keypad-literal-prefix nil
        meow-keypad-start-keys nil)

  (meow-leader-define-key
   '("?" . consult-apropos)
   '("/" . meow-keypad-describe-key)
   '("SPC" . execute-extended-command)
   '(";" . comment-line)
   '("[" . lem-previous-user-buffer)
   '("]" . lem-next-user-buffer)
   '("{" . tab-bar-switch-to-prev-tab)
   '("}" . tab-bar-switch-to-next-tab)
   '("TAB" . lem-tab-bar-select-tab-dwim)
   '("b" . lem+buffer-keys)
   '("c" . lem+comment-wrap-keys)
   '("C" . lem+config-keys)
   '("d" . dired-jump)
   '("e" . lem+eval-keys)
   '("f" . lem+file-keys)
   '("F" . lem+flymake-keys)
   '("i" . lem-find-lambda-file)
   '("k" . consult-yank-from-kill-ring)
   '("l" . vertico-repeat)
   `("p" . ,project-prefix-map)
   '("q" . lem+quit-keys)
   '("r" . consult-register)
   '("R" . consult-recent-file)
   '("s" . lem+search-keys)
   '("t" . lem+toggle-keys)
   '("v" . lem+vc-keys)
   '("w" . lem+window-keys)
   '("W" . lem+workspace-keys))

  (meow-normal-define-key
   '("0" . meow-expand-0)
   '("9" . meow-expand-9)
   '("8" . meow-expand-8)
   '("7" . meow-expand-7)
   '("6" . meow-expand-6)
   '("5" . meow-expand-5)
   '("4" . meow-expand-4)
   '("3" . meow-expand-3)
   '("2" . meow-expand-2)
   '("1" . meow-expand-1)
   '("-" . negative-argument)
   '(";" . meow-reverse)
   '(":" . meow-goto-line)
   '("," . meow-inner-of-thing)
   '("." . meow-bounds-of-thing)
   '("[" . meow-beginning-of-thing)
   '("]" . meow-end-of-thing)
   '("a" . meow-append)
   '("A" . meow-open-below)
   '("b" . meow-back-word)
   '("B" . meow-back-symbol)
   '("c" . meow-change)
   '("d" . meow-delete)
   '("D" . meow-backward-delete)
   '("e" . meow-next-word)
   '("E" . meow-next-symbol)
   '("f" . meow-find)
   '("g" . beginning-of-buffer)
   '("G" . end-of-buffer)
   '("h" . meow-left)
   '("H" . meow-left-expand)
   '("i" . meow-insert)
   '("I" . meow-open-above)
   '("j" . meow-next)
   '("J" . meow-next-expand)
   '("k" . meow-prev)
   '("K" . meow-prev-expand)
   '("l" . meow-right)
   '("L" . meow-right-expand)
   '("m" . meow-join)
   '("n" . meow-search)
   '("o" . meow-block)
   '("O" . meow-to-block)
   '("p" . meow-yank)
   '("q" . meow-quit)
   '("r" . meow-replace)
   '("R" . overwrite-mode)
   '("s" . meow-kill)
   '("S" . consult-ripgrep)
   '("t" . meow-till)
   '("u" . meow-undo)
   '("U" . meow-undo-in-selection)
   '("v" . meow-visit)
   '("w" . meow-mark-word)
   '("W" . meow-mark-symbol)
   '("x" . meow-line)
   '("X" . meow-swap-grab)
   '("y" . meow-clipboard-save)
   '("Y" . meow-sync-grab)
   '("z" . meow-pop-selection)
   '("'" . repeat)
   '("&" . meow-query-replace-regexp)
   '("%" . meow-query-replace)
   '("=" . meow-grab)

   ;; Firemacs muscle-memory additions that do not replace Meow's plain keys.
   '("C-b" . consult-buffer)
   '("C-d" . starter-motion-scroll-half-page-down)
   '("C-e" . dired-jump)
   '("C-f" . starter-motion-scroll-page-down)
   '("C-o" . meow-pop-to-mark)
   '("C-i" . meow-unpop-to-mark)
   '("C-u" . starter-motion-scroll-half-page-up)
   '("<escape>" . meow-cancel-selection)))

(use-package meow
  :ensure t
  :custom
  (meow-use-cursor-position-hack t)
  (meow-use-clipboard t)
  (meow-goto-line-function #'consult-goto-line)
  (meow-display-thing-help t)
  (meow-keypad-message t)
  (meow-keypad-describe-delay 0.3)
  :config
  (setopt meow-use-dynamic-face-color nil)
  (setq meow-cursor-type-normal 'box
        meow-cursor-type-insert '(bar . 2)
        meow-cursor-type-motion 'hollow
        meow-cursor-type-keypad 'hollow
        meow-cursor-type-beacon 'box)

  (meow-thing-register 'angle '(regexp "<" ">") '(regexp "<" ">"))
  (add-to-list 'meow-char-thing-table '(?a . angle))

  (dolist (entry '((dired-mode . motion)
                   (help-mode . motion)
                   (Info-mode . motion)
                   (compilation-mode . motion)
                   (magit-status-mode . motion)
                   (magit-log-mode . motion)
                   (eshell-mode . insert)
                   (shell-mode . insert)
                   (term-mode . insert)))
    (add-to-list 'meow-mode-state-list entry))

  (with-eval-after-load 'magit
    (add-to-list 'meow-grab-fill-commands 'magit-discard))

  (with-eval-after-load 'org
    (modify-syntax-entry ?@ "_" org-mode-syntax-table))

  (starter-meow-setup)
  (meow-global-mode 1))

(provide 'starter-setup-meow)
;;; starter-setup-meow.el ends here
