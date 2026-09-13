;;; starter-setup-ui.el --- Portable starter presentation -*- lexical-binding: t; -*-
;; Generated from literate/50-appearance.org; edit the Org source, then tangle.

;;; Commentary:
;; A small presentation layer for the Lambda learning configuration.
;;
;; Design goals:
;; - retain ordinary OS-managed Emacs frames;
;; - use Sonokai as a vivid dark default without requiring Doom Emacs;
;; - use Google Sans Code Nerd Font when installed, while retaining a safe
;;   platform fallback when it is absent;
;; - keep Lambda's built-in tab-bar/tabspaces architecture rather than adding a
;;   second tab/workspace framework;
;; - borrow the useful presentation ideas from Firemacs (compact modeline,
;;   visible tabs, dark editor surface) without importing its terminal-specific
;;   custom statuscolumn/MRU-tab implementation;
;; - make icons optional so a missing Nerd Font never breaks first boot.

;;; Code:

(require 'starter-setup-fonts)
(defgroup starter-ui nil
  "Presentation defaults for the Lambda learning configuration."
  :group 'lambda-emacs)
(defcustom starter-ui-theme 'doom-sonokai
  "Dark/default theme loaded by the starter UI layer."
  :type 'symbol)
(defcustom starter-ui-light-theme 'doom-one-light
  "Light theme used by `starter-ui-toggle-theme'."
  :type 'symbol)
(defcustom starter-ui-line-numbers-in-programming t
  "Whether programming buffers should show line numbers by default."
  :type 'boolean)
;;;; Theme

(defun starter-ui-load-theme (theme)
  "Disable active themes and load THEME non-interactively."
  (mapc #'disable-theme custom-enabled-themes)
  (load-theme theme t)
  (when (fboundp 'doom-themes-org-config)
    (doom-themes-org-config)))
(defun starter-ui-toggle-theme ()
  "Toggle between `starter-ui-theme' and `starter-ui-light-theme'."
  (interactive)
  (starter-ui-load-theme
   (if (memq starter-ui-theme custom-enabled-themes)
       starter-ui-light-theme
     starter-ui-theme)))
(use-package doom-themes
  :ensure t
  :custom
  (doom-themes-enable-bold t)
  (doom-themes-enable-italic t)
  :config
  ;; Prefer our tracked theme port over package-managed copies.
  (add-to-list 'custom-theme-load-path (expand-file-name "themes/" lem-user-dir))
  ;; Lambda loads a fallback theme early so startup is never unthemed. Replace it
  ;; here once the user-facing UI layer is ready.
  (starter-ui-load-theme starter-ui-theme))
;; Lambda's default toggle calls a macOS-only `dark-mode' shell utility. Replace
;; just that binding with a portable theme toggle while retaining the rest of the
;; Lambda toggle map. `SPC t T' remains Lambda's interactive theme chooser.
(with-eval-after-load 'lem-setup-keybindings
  (define-key lem+toggle-keys (kbd "t") #'starter-ui-toggle-theme))
;;;; Modeline

(use-package nerd-icons
  :ensure t
  :defer t
  :custom
  (nerd-icons-font-family starter-ui-nerd-font))
(use-package doom-modeline
  :ensure t
  :init
  (setq doom-modeline-height 28
        doom-modeline-project-detection 'project
        doom-modeline-buffer-file-name-style 'truncate-upto-project
        doom-modeline-icon (starter-ui-icons-available-p)
        doom-modeline-major-mode-icon t
        doom-modeline-buffer-state-icon t)
  :config
  (doom-modeline-mode 1))
;;;; Workspace/tab presentation

(with-eval-after-load 'tab-bar
  ;; Lambda uses tabs as window-configuration/project workspaces. Keep that
  ;; semantic model, but expose it visually once a second workspace exists.
  (setopt tab-bar-show 1)

  (defun starter-ui-apply-tab-faces ()
    "Give the built-in tab bar a compact editor-like presentation."
    (set-face-attribute 'tab-bar nil
                        :inherit 'default
                        :box nil)
    (set-face-attribute 'tab-bar-tab nil
                        :inherit 'mode-line
                        :weight 'bold
                        :box nil)
    (set-face-attribute 'tab-bar-tab-inactive nil
                        :inherit 'mode-line-inactive
                        :weight 'normal
                        :box nil))

  (starter-ui-apply-tab-faces)
  ;; Lambda defines this hook around `load-theme'; keep tab faces coherent when
  ;; changing themes interactively later.
  (when (boundp 'lem-after-load-theme-hook)
    (add-hook 'lem-after-load-theme-hook #'starter-ui-apply-tab-faces)))
;;;; Completion and file-manager icons

(use-package nerd-icons-completion
  :ensure t
  :after marginalia
  :config
  (when (starter-ui-icons-available-p)
    (nerd-icons-completion-mode 1)
    (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup)))
(use-package nerd-icons-corfu
  :ensure t
  :after corfu
  :config
  (when (starter-ui-icons-available-p)
    (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter)))
(defun starter-ui-maybe-enable-dired-icons ()
  "Enable Dired icons only when their font is usable."
  (when (starter-ui-icons-available-p)
    (nerd-icons-dired-mode 1)))
(use-package nerd-icons-dired
  :ensure t
  :commands nerd-icons-dired-mode
  :hook (dired-mode . starter-ui-maybe-enable-dired-icons))
;;;; Spacing

(use-package spacious-padding
  :ensure t
  :custom
  ;; Deliberately modest: visual separation without changing the basic frame
  ;; decoration model or relying on a particular desktop/window manager.
  (spacious-padding-widths
   '(:internal-border-width 8
     :header-line-width 2
     :mode-line-width 4
     :tab-width 2
     :right-divider-width 1
     :scroll-bar-width 0
     :fringe-width 6))
  :config
  (spacious-padding-mode 1))
;;;; Editing-surface polish

(show-paren-mode 1)
(defun starter-ui-programming-presentation ()
  "Apply unobtrusive visual aids in programming buffers."
  (when starter-ui-line-numbers-in-programming
    (setq-local display-line-numbers-type t)
    (display-line-numbers-mode 1))
  (hl-line-mode 1))
(add-hook 'prog-mode-hook #'starter-ui-programming-presentation)
(provide 'starter-setup-ui)
;;; starter-setup-ui.el ends here
