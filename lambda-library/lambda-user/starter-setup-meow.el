;;; starter-setup-meow.el --- Selection-first editing -*- lexical-binding: t; -*-

;; Adapted from Colin McLear's cpm-setup-meow.el (GPL-3.0-or-later).

;;; Commentary:
;; Reduced Meow configuration derived from Colin McLear's Lambda setup.
;;
;; The important architectural choice is to expose Lambda's existing semantic
;; `lem+leader-map' through Meow. SPC therefore shows the user-facing command
;; hierarchy in which-key while ordinary Emacs keymaps remain underneath it.

;;; Code:

(defun starter-meow-setup ()
  "Install starter Meow motion, leader, and normal-state bindings."

  ;; Motion state is for special buffers where the major mode should keep most keys.
  (meow-motion-overwrite-define-key
   '("j" . meow-next)
   '("k" . meow-prev))

  ;; Colin's useful integration trick: make Lambda's actual leader map the map
  ;; Meow/which-key sees rather than duplicating the hierarchy.
  (add-to-list 'meow-keymap-alist (cons 'leader lem+leader-map))

  ;; SPC is a semantic leader here, not a generic modifier translator.
  (setopt meow-keypad-meta-prefix nil
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

  ;; Colin's QWERTY Meow grammar, kept close to the documented/recommended Meow
  ;; vocabulary so `meow-tutor' and upstream documentation transfer cleanly.
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
   '("<escape>" . meow-cancel-selection)))

(use-package meow
  :ensure t
  :custom
  (meow-use-cursor-position-hack t)
  (meow-use-clipboard t)
  (meow-goto-line-function #'consult-goto-line)
  :config
  (setopt meow-use-dynamic-face-color nil)

  ;; Useful extra semantic "thing" retained from Colin's config.
  (meow-thing-register 'angle '(regexp "<" ">") '(regexp "<" ">"))
  (add-to-list 'meow-char-thing-table '(?a . angle))

  ;; Predictable starting states for application-like modes.
  (dolist (entry '((magit-status-mode . normal)
                   (magit-log-mode . normal)
                   (eshell-mode . insert)
                   (shell-mode . insert)
                   (term-mode . insert)))
    (add-to-list 'meow-mode-state-list entry))

  (with-eval-after-load 'magit
    (add-to-list 'meow-grab-fill-commands 'magit-discard)
    (add-hook 'magit-mode-hook
              (lambda ()
                (local-unset-key (kbd "j"))
                (local-unset-key (kbd "k")))))

  (with-eval-after-load 'org
    ;; Treat @ as part of symbols/words during Meow movement in Org.
    (modify-syntax-entry ?@ "_" org-mode-syntax-table))

  (starter-meow-setup)
  (meow-global-mode 1))

(provide 'starter-setup-meow)
;;; starter-setup-meow.el ends here
