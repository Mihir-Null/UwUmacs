;;; starter-setup-ui.el --- Firemacs-inspired portable presentation -*- lexical-binding: t; -*-

;;; Commentary:
;; A graphical, Windows-safe interpretation of Firemacs: dark editor surface,
;; orange accent, rich modeline, grouped buffer strip, navigation rail, smooth
;; feedback, and visible native help affordances.  Frames remain decorated and
;; non-fullscreen so the operating-system window manager stays in control.

;;; Code:

(require 'color)

(defgroup starter-ui nil
  "Presentation defaults for the Lambda learning configuration."
  :group 'lambda-emacs)

(defcustom starter-ui-theme 'doom-dark+
  "Dark/default theme loaded by the starter UI layer."
  :type 'symbol)

(defcustom starter-ui-light-theme 'doom-one-light
  "Light theme used by `starter-ui-toggle-theme'."
  :type 'symbol)

(defcustom starter-ui-accent "#ff5a36"
  "Firemacs-inspired accent used for navigation and modal feedback."
  :type 'color)

(defcustom starter-ui-icons 'auto
  "Whether to use Nerd Font icons.
When `auto', use them only in graphical frames where the font exists."
  :type '(choice (const :tag "Detect automatically" auto)
                 (const :tag "Always" t)
                 (const :tag "Never" nil)))

(defcustom starter-ui-nerd-font "Symbols Nerd Font Mono"
  "Font family used for Nerd Icons."
  :type 'string)

(defcustom starter-ui-enable-menu-bar t
  "Whether graphical frames expose the native menu bar."
  :type 'boolean)

(defcustom starter-ui-enable-tool-bar t
  "Whether graphical frames expose the native icon tool bar."
  :type 'boolean)

(defcustom starter-ui-line-numbers-in-programming t
  "Whether programming buffers should show line numbers by default."
  :type 'boolean)

(defun starter-ui-icons-available-p ()
  "Return non-nil when the starter should render Nerd Font icons."
  (pcase starter-ui-icons
    ('t t)
    ('nil nil)
    ('auto
     (and (display-graphic-p)
          (find-font (font-spec :name starter-ui-nerd-font))))))

(defun starter-ui-apply-frame-policy (&optional frame)
  "Apply native, decorated, non-fullscreen policy to graphical FRAME."
  (with-selected-frame (or frame (selected-frame))
    (when (display-graphic-p)
      (modify-frame-parameters
       nil `((fullscreen . nil)
             (undecorated . nil)
             (menu-bar-lines . ,(if starter-ui-enable-menu-bar 1 0))
             (tool-bar-lines . ,(if starter-ui-enable-tool-bar 1 0))))
      (when (fboundp 'tooltip-mode)
        (tooltip-mode 1))
      (when (fboundp 'context-menu-mode)
        (context-menu-mode 1)))))

;; Remove inherited Lambda frame policy before future Windows/FancyWM frames
;; are created.  This does not prevent the user from maximizing a frame later.
(setq default-frame-alist
      (assq-delete-all 'fullscreen
                       (assq-delete-all 'undecorated default-frame-alist)))
(add-to-list 'default-frame-alist '(fullscreen . nil))
(add-to-list 'default-frame-alist '(undecorated . nil))
(add-hook 'after-make-frame-functions #'starter-ui-apply-frame-policy)
(starter-ui-apply-frame-policy)

;;;; Theme and Firemacs face layer

(defun starter-ui-apply-firemacs-faces ()
  "Apply the accent and compact bar faces after a theme change."
  (let ((accent starter-ui-accent)
        (surface (if (eq (frame-parameter nil 'background-mode) 'dark)
                     "#2b2b2b"
                   "#f4f4f4"))
        (muted (if (eq (frame-parameter nil 'background-mode) 'dark)
                   "#4a4a4a"
                 "#d8d8d8"))
        (muted-foreground
         (if (eq (frame-parameter nil 'background-mode) 'dark)
             "#d7d7d7"
           "#303030")))
    (dolist (face '(tab-bar tab-line))
      (when (facep face)
        (set-face-attribute face nil :background surface :box nil)))
    (dolist (face '(tab-bar-tab tab-line-tab-current))
      (when (facep face)
        (set-face-attribute face nil
                            :background accent :foreground surface
                            :weight 'bold :box nil)))
    (dolist (face '(tab-bar-tab-inactive tab-line-tab tab-line-tab-inactive
                    tab-line-tab-group))
      (when (facep face)
        (set-face-attribute face nil
                            :background muted :foreground muted-foreground
                            :box nil)))
    (dolist (spec `((meow-normal-cursor . ,accent)
                    (meow-normal-indicator . ,accent)
                    (doom-modeline-meow-normal-state . ,accent)
                    (meow-insert-cursor . "#98c379")
                    (meow-insert-indicator . "#98c379")
                    (doom-modeline-meow-insert-state . "#98c379")
                    (meow-motion-cursor . "#61afef")
                    (meow-motion-indicator . "#61afef")
                    (doom-modeline-meow-motion-state . "#61afef")
                    (meow-keypad-cursor . "#c678dd")
                    (meow-keypad-indicator . "#c678dd")
                    (doom-modeline-meow-keypad-state . "#c678dd")
                    (meow-beacon-cursor . "#e5c07b")
                    (meow-beacon-indicator . "#e5c07b")
                    (doom-modeline-meow-beacon-state . "#e5c07b")))
      (when (facep (car spec))
        (set-face-attribute (car spec) nil
                            :background (cdr spec)
                            :foreground surface
                            :weight 'bold)))
    (when (facep 'which-key-posframe-border)
      (set-face-attribute 'which-key-posframe-border nil :background accent))
    (when (facep 'eldoc-box-border)
      (set-face-attribute 'eldoc-box-border nil :background accent))))

(defun starter-ui-load-theme (theme)
  "Disable active themes and load THEME non-interactively."
  (mapc #'disable-theme custom-enabled-themes)
  (load-theme theme t)
  (when (fboundp 'doom-themes-org-config)
    (doom-themes-org-config))
  (starter-ui-apply-firemacs-faces))

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
  (starter-ui-load-theme starter-ui-theme))

(with-eval-after-load 'lem-setup-keybindings
  (define-key lem+toggle-keys (kbd "t") #'starter-ui-toggle-theme))

;;;; Modeline and icons

(use-package nerd-icons
  :ensure t
  :defer t
  :custom
  (nerd-icons-font-family starter-ui-nerd-font))

(use-package doom-modeline
  :ensure t
  :init
  (setq doom-modeline-height 30
        doom-modeline-bar-width 4
        doom-modeline-project-detection 'project
        doom-modeline-buffer-file-name-style 'truncate-upto-project
        doom-modeline-icon (starter-ui-icons-available-p)
        doom-modeline-major-mode-icon t
        doom-modeline-buffer-state-icon t
        doom-modeline-modal t
        doom-modeline-modal-icon t
        doom-modeline-buffer-encoding 'nondefault)
  :config
  (doom-modeline-mode 1)
  (starter-ui-apply-firemacs-faces))

;;;; Lambda workspace bar

(with-eval-after-load 'tab-bar
  (setopt tab-bar-show 1)
  (starter-ui-apply-firemacs-faces))

;;;; Navigation rail

(use-package diff-hl
  :ensure t
  :hook ((prog-mode . diff-hl-mode)
         (text-mode . diff-hl-mode)
         (dired-mode . diff-hl-dired-mode))
  :config
  (when (not (display-graphic-p))
    (diff-hl-margin-mode 1))
  (with-eval-after-load 'magit
    (add-hook 'magit-post-refresh-hook #'diff-hl-magit-post-refresh)))

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

;;;; Spacing and editing-surface polish

(use-package spacious-padding
  :ensure t
  :custom
  (spacious-padding-widths
   '(:internal-border-width 8
     :header-line-width 2
     :mode-line-width 4
     :tab-width 2
     :right-divider-width 1
     :scroll-bar-width 0
     :fringe-width 8))
  :config
  (spacious-padding-mode 1))

(show-paren-mode 1)

(defun starter-ui-programming-presentation ()
  "Apply the Firemacs-inspired navigation rail in programming buffers."
  (when starter-ui-line-numbers-in-programming
    (setq-local display-line-numbers-type t)
    (display-line-numbers-mode 1))
  (hl-line-mode 1))

(add-hook 'prog-mode-hook #'starter-ui-programming-presentation)

(provide 'starter-setup-ui)
;;; starter-setup-ui.el ends here
