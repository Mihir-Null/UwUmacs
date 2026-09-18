;;; uwumacs-ui.el --- Fonts, theme, mode line and icons -*- lexical-binding: t; -*-
;; Generated from literate/50-appearance.org; edit the Org source, then tangle.

;; Highlighting defaults distilled from Lambda-Emacs by Colin McLear (GPL-3.0-or-later).

;;; Code:

(require 'seq)
(require 'uwumacs-defaults)

(defgroup uwumacs-ui nil
  "Fonts, theme and presentation."
  :group 'uwumacs)

(defcustom uwumacs-font-family "GoogleSansCode Nerd Font"
  "Preferred editing font family; the platform default is used if it is absent."
  :type 'string)

(defcustom uwumacs-font-size 14
  "Default editing font size, in points."
  :type 'natnum)

(defcustom uwumacs-nerd-font "Symbols Nerd Font Mono"
  "Font family used for Nerd Font icons."
  :type 'string)

(defcustom uwumacs-icons 'auto
  "Whether to render Nerd Font icons.
With `auto', require a graphical frame and an installed icon font.
Use t for a terminal configured with a Nerd Font, or nil to disable icons."
  :type '(choice (const auto) (const t) (const nil)))

(defcustom uwumacs-theme 'doom-sonokai
  "Default theme."
  :type 'symbol)

(defcustom uwumacs-light-theme 'doom-one-light
  "Theme used by `uwumacs-toggle-theme'."
  :type 'symbol)

(defcustom uwumacs-line-numbers-in-programming t
  "Whether programming buffers show line numbers."
  :type 'boolean)
(defun uwumacs-resolve-font-family ()
  "Return the installed family for `uwumacs-font-family', or nil."
  (when (display-graphic-p)
    (seq-find (lambda (family) (find-font (font-spec :family family)))
              (if (equal uwumacs-font-family "GoogleSansCode Nerd Font")
                  (list uwumacs-font-family "GoogleSansCode NF")
                (list uwumacs-font-family)))))

(defun uwumacs-icons-available-p ()
  "Return non-nil when Nerd Font icons should be rendered."
  (pcase uwumacs-icons
    ('t t)
    ('nil nil)
    ('auto (and (display-graphic-p)
                (find-font (font-spec :family uwumacs-nerd-font))
                t))))

(defun uwumacs--apply-icon-font (&optional frame)
  "Map Nerd icon ranges to `uwumacs-nerd-font' in graphical FRAME."
  (with-selected-frame (or frame (selected-frame))
    (when (uwumacs-icons-available-p)
      (nerd-icons-set-font uwumacs-nerd-font (selected-frame)))))

(defun uwumacs-apply-font (&optional frame)
  "Apply the editing, symbol and icon fonts to FRAME."
  (with-selected-frame (or frame (selected-frame))
    (when (display-graphic-p)
      (when-let* ((family (uwumacs-resolve-font-family)))
        (set-face-attribute 'default (selected-frame) :family family))
      (set-face-attribute 'default (selected-frame) :height (* 10 uwumacs-font-size))
      (when-let* ((symbols (seq-find (lambda (family) (find-font (font-spec :family family)))
                                     '("Segoe UI Symbol" "Symbola" "Apple Symbols" "Symbol"))))
        (set-fontset-font t 'symbol symbols nil))
      (uwumacs--apply-icon-font))))

(setq-default line-spacing 0.1)
(setopt text-scale-mode-step 1.08
        use-default-font-for-symbols t)

(use-package nerd-icons
  :ensure t
  :demand t
  :custom
  (nerd-icons-font-family uwumacs-nerd-font))

(add-hook 'after-setting-font-hook #'uwumacs--apply-icon-font)
(add-hook 'after-make-frame-functions #'uwumacs-apply-font)
(uwumacs-apply-font)
(setopt custom-safe-themes t)
(add-to-list 'custom-theme-load-path
             (expand-file-name "themes/" (file-name-directory (or load-file-name buffer-file-name))))

(defun uwumacs-load-theme (theme)
  "Disable active themes and load THEME."
  (mapc #'disable-theme custom-enabled-themes)
  (load-theme theme t)
  (when (fboundp 'doom-themes-org-config)
    (doom-themes-org-config)))

(defun uwumacs-toggle-theme ()
  "Toggle between `uwumacs-theme' and `uwumacs-light-theme'."
  (interactive)
  (uwumacs-load-theme (if (memq uwumacs-theme custom-enabled-themes)
                          uwumacs-light-theme
                        uwumacs-theme)))

(use-package doom-themes
  :ensure t
  :custom
  (doom-themes-enable-bold t)
  (doom-themes-enable-italic t)
  :config
  (uwumacs-load-theme uwumacs-theme))
(use-package doom-modeline
  :ensure t
  :custom
  (doom-modeline-height 28)
  (doom-modeline-project-detection 'project)
  (doom-modeline-buffer-file-name-style 'truncate-upto-project)
  (doom-modeline-icon (uwumacs-icons-available-p))
  (doom-modeline-major-mode-icon t)
  (doom-modeline-buffer-state-icon t)
  :config
  (doom-modeline-mode 1))

(defun uwumacs--tab-bar-faces (&rest _)
  "Give the tab bar a compact, mode-line-like look."
  (set-face-attribute 'tab-bar nil :inherit 'default :box nil)
  (set-face-attribute 'tab-bar-tab nil :inherit 'mode-line :weight 'bold :box nil)
  (set-face-attribute 'tab-bar-tab-inactive nil :inherit 'mode-line-inactive :weight 'normal :box nil))

(with-eval-after-load 'tab-bar
  (setopt tab-bar-show 1)
  (uwumacs--tab-bar-faces)
  (add-hook 'enable-theme-functions #'uwumacs--tab-bar-faces))
(use-package nerd-icons-completion
  :ensure t
  :after marginalia
  :config
  (when (uwumacs-icons-available-p)
    (nerd-icons-completion-mode 1)
    (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup)))

(use-package nerd-icons-corfu
  :ensure t
  :after corfu
  :config
  (when (uwumacs-icons-available-p)
    (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter)))

(defun uwumacs--maybe-dired-icons ()
  "Enable Dired icons when their font is usable."
  (when (uwumacs-icons-available-p)
    (nerd-icons-dired-mode 1)))

(use-package nerd-icons-dired
  :ensure t
  :commands nerd-icons-dired-mode
  :hook (dired-mode . uwumacs--maybe-dired-icons))
(use-package spacious-padding
  :ensure t
  :custom
  (spacious-padding-widths '(:internal-border-width 8
                             :header-line-width 2
                             :mode-line-width 4
                             :tab-width 2
                             :right-divider-width 1
                             :scroll-bar-width 0
                             :fringe-width 6))
  :config
  (spacious-padding-mode 1))

(setopt x-underline-at-descent-line t
        cursor-in-non-selected-windows nil
        widget-image-enable nil
        pulse-delay 0.08)

(use-package dimmer
  :ensure t
  :custom
  (dimmer-fraction 0.3)
  (dimmer-adjustment-mode :foreground)
  (dimmer-watch-frame-focus-events nil)
  (dimmer-prevent-dimming-predicates '(window-minibuffer-p))
  :config
  (dimmer-configure-which-key)
  (dimmer-configure-magit)
  (dimmer-configure-posframe)
  (add-to-list 'dimmer-buffer-exclusion-regexps "^ \\*Vertico\\*$")
  (dimmer-mode 1))

(defun uwumacs-pulse-line (&rest _)
  "Briefly highlight the current line."
  (pulse-momentary-highlight-one-line (point)))
(dolist (command '(scroll-up-command scroll-down-command recenter-top-bottom other-window))
  (advice-add command :after #'uwumacs-pulse-line))
(add-hook 'window-selection-change-functions #'uwumacs-pulse-line)

(use-package hl-todo
  :ensure t
  :hook ((prog-mode markdown-mode) . hl-todo-mode))

(use-package highlight-numbers
  :ensure t
  :hook (prog-mode . highlight-numbers-mode))

(use-package goggles
  :ensure t
  :hook ((prog-mode text-mode) . goggles-mode)
  :custom
  (goggles-pulse t))

(use-package outline-minor-faces
  :ensure t
  :hook ((emacs-lisp-mode lisp-interaction-mode lisp-mode) . outline-minor-faces-mode))
(defun uwumacs--programming-presentation ()
  "Visual aids for programming buffers."
  (when uwumacs-line-numbers-in-programming
    (setq-local display-line-numbers-type t)
    (display-line-numbers-mode 1))
  (hl-line-mode 1))
(add-hook 'prog-mode-hook #'uwumacs--programming-presentation)

(provide 'uwumacs-ui)
;;; uwumacs-ui.el ends here
