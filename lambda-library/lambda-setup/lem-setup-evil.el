;;; lem-setup-evil.el --- Evil (vim emulation) setup -*- lexical-binding: t -*-

;; Author: Colin McLear
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

;; A basic Evil layer for Lambda-Emacs: modal (vim-style) editing via
;; `evil', broad keybinding coverage via `evil-collection', and the
;; `evil-surround' / `evil-commentary' operators.
;;
;; This module is opt-in on two axes, and both must hold before any evil
;; package is installed:
;;
;;   1. `lem-setup-evil' must be loaded (added to your module list); an
;;      unloaded file installs nothing.
;;   2. `lem-load-extras' must be non-nil.
;;
;; Unlike most setup modules -- which gate on packages installed
;; out-of-band from `lem-packages-alist' -- this one self-installs via
;; `:ensure t', so the (fairly heavy) evil package set lands only for
;; users who actually turn it on, not as part of the default install.
;; The forms are wrapped in `(when lem-load-extras ...)' rather than
;; carrying a per-form `:when', because use-package emits its `:ensure'
;; install call OUTSIDE any `:when'/`:if' guard; only a wrapping form
;; encloses the install so `lem-load-extras' can gate it too. `provide'
;; stays outside the guard so `(require 'lem-setup-evil)' always succeeds.
;;
;; This module is deliberately NOT part of `lem--default-modules', so
;; plain lambda-emacs stays non-modal. Escape-to-quit bindings and the
;; splash's hand-off to emacs-state already live in lem-setup-functions.el
;; and lem-setup-splash.el, so they are not repeated here.

;;; Code:

(when lem-load-extras

;;;; Evil
  (use-package evil
    :ensure t
    :init
    ;; These must be set before evil loads. `evil-want-keybinding' must
    ;; be nil so `evil-collection' can take over keybindings on a clean
    ;; slate.
    (setq evil-want-integration t
          evil-want-keybinding nil
          evil-want-C-u-scroll t              ; C-u scrolls up (vim default)
          evil-want-C-i-jump nil              ; leave TAB for org-cycle etc.
          evil-want-Y-yank-to-eol t
          evil-undo-system 'undo-redo         ; Emacs 28+ built-in, no undo-tree
          evil-respect-visual-line-mode t     ; j/k follow visual-line-mode
          evil-search-module 'evil-search
          evil-split-window-below t
          evil-vsplit-window-right t)
    :config
    (evil-mode 1)

    ;; Shape-only state cursors: symbols (or (shape . width) cons cells)
    ;; with no colour component, so state transitions change only cursor
    ;; shape and never touch `cursor-color'. Evil defines cursor
    ;; variables for its seven top-level states; visual-line and
    ;; visual-block are sub-types of visual and inherit
    ;; `evil-visual-state-cursor'.
    (setq evil-normal-state-cursor   'box
          evil-insert-state-cursor   '(bar . 2)
          evil-visual-state-cursor   'box
          evil-replace-state-cursor  'hbar
          evil-emacs-state-cursor    'box
          evil-motion-state-cursor   'box
          evil-operator-state-cursor 'hollow))

;;;; Evil Collection
  ;; Community keybindings for the many modes evil does not cover itself.
  (use-package evil-collection
    :ensure t
    :after evil
    :config
    (evil-collection-init)
    ;; Leave REPLs, terminals, and tabulated list UIs in Emacs state.
    ;; Runs after `evil-collection-init' so these choices take precedence.
    (dolist (mode '(eshell-mode
                    shell-mode
                    term-mode
                    vterm-mode
                    eat-mode
                    inferior-emacs-lisp-mode
                    debugger-mode
                    profiler-report-mode
                    tabulated-list-mode))
      (evil-set-initial-state mode 'emacs)))

;;;; Evil Surround
  ;; Operate on surrounding pairs -- parens, quotes, tags: ys / cs / ds.
  (use-package evil-surround
    :ensure t
    :after evil
    :config
    (global-evil-surround-mode 1))

;;;; Evil Commentary
  ;; gc<motion> / gcc to comment and uncomment with vim motions.
  (use-package evil-commentary
    :ensure t
    :after evil
    :config
    (evil-commentary-mode 1)))

;;; Provide:
(provide 'lem-setup-evil)
;;; lem-setup-evil.el ends here
