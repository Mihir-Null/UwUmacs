;;; starter-setup-discoverability.el --- Graphical command discovery -*- lexical-binding: t; -*-

;;; Commentary:
;; Make the Meow/Lambda command hierarchy visible through which-key tooltips,
;; Eldoc child frames, context actions, Casual transient menus, native menus,
;; and an opt-in keycast log.  All child-frame features have terminal fallbacks.

;;; Code:

(defgroup starter-discoverability nil
  "Graphical and transient help for the Meow-first configuration."
  :group 'starter-ui)

(defcustom starter-discoverability-posframes t
  "Whether graphical frames should show which-key in a child frame."
  :type 'boolean)

(defcustom starter-discoverability-eldoc-hover t
  "Whether Eglot buffers should show Eldoc in a child frame."
  :type 'boolean)

(defcustom starter-discoverability-casual-menus t
  "Whether to initialize Casual transient menus for supported modes."
  :type 'boolean)

(defun starter-help-callable ()
  "Describe a callable using Helpful when it is available."
  (interactive)
  (call-interactively
   (if (fboundp 'helpful-callable) #'helpful-callable #'describe-function)))

(defun starter-help-variable ()
  "Describe a variable using Helpful when it is available."
  (interactive)
  (call-interactively
   (if (fboundp 'helpful-variable) #'helpful-variable #'describe-variable)))

(defun starter-help-key ()
  "Describe a key using Helpful when it is available."
  (interactive)
  (call-interactively
   (if (fboundp 'helpful-key) #'helpful-key #'describe-key)))

(defun starter-help-at-point ()
  "Show documentation at point in a child frame or an Eldoc buffer."
  (interactive)
  (cond
   ((and (display-graphic-p) (fboundp 'eldoc-box-help-at-point))
    (eldoc-box-help-at-point))
   ((fboundp 'eldoc-doc-buffer)
    (eldoc-doc-buffer))
   (t (call-interactively #'describe-symbol))))

(defun starter-discoverability-enable-which-key-posframe (&optional frame)
  "Enable the which-key posframe when FRAME is graphical."
  (with-selected-frame (or frame (selected-frame))
    (when (and starter-discoverability-posframes
               (display-graphic-p)
               (fboundp 'which-key-posframe-mode))
      (which-key-posframe-mode 1))))

(defun starter-discoverability-enable-eldoc-box ()
  "Enable hover documentation in graphical Eglot buffers."
  (when (and starter-discoverability-eldoc-hover (display-graphic-p))
    (eldoc-box-hover-mode 1)))

(defun starter-discoverability-toggle-keycast ()
  "Toggle Keycast's dedicated command log."
  (interactive)
  (require 'keycast)
  (keycast-log-mode (if (bound-and-true-p keycast-log-mode) -1 1)))

(defvar-keymap starter-help-map
  :doc "Meow-first help and discoverability commands."
  "." #'starter-help-at-point
  "a" #'apropos-command
  "c" #'casual-suite-about
  "f" #'starter-help-callable
  "k" #'starter-help-key
  "K" #'starter-discoverability-toggle-keycast
  "m" #'describe-mode
  "M" #'menu-bar-open
  "v" #'starter-help-variable)

(defvar-keymap starter-jump-map
  :doc "Visible and semantic jump commands."
  "c" #'avy-goto-char-timer
  "i" #'consult-imenu
  "l" #'avy-goto-line
  "m" #'consult-mark
  "w" #'avy-goto-word-1)

(use-package which-key
  :ensure nil
  :custom
  (which-key-idle-delay 0.35)
  (which-key-idle-secondary-delay 0.05)
  (which-key-max-description-length 36)
  :config
  (which-key-mode 1))

(use-package which-key-posframe
  :ensure t
  :after which-key
  :custom
  (which-key-posframe-border-width 1)
  (which-key-posframe-poshandler
   #'posframe-poshandler-frame-bottom-right-corner)
  :config
  (starter-discoverability-enable-which-key-posframe)
  (when (fboundp 'starter-ui-apply-firemacs-faces)
    (starter-ui-apply-firemacs-faces))
  (add-hook 'after-make-frame-functions
            #'starter-discoverability-enable-which-key-posframe))

(use-package helpful
  :ensure t
  :commands (helpful-callable helpful-key helpful-variable))

(use-package eldoc-box
  :ensure t
  :commands (eldoc-box-help-at-point eldoc-box-hover-mode)
  :custom
  (eldoc-box-only-multi-line t)
  (eldoc-box-cleanup-interval 0.5)
  :hook (eglot-managed-mode . starter-discoverability-enable-eldoc-box)
  :config
  (when (fboundp 'starter-ui-apply-firemacs-faces)
    (starter-ui-apply-firemacs-faces)))

(use-package casual-suite
  :ensure t
  :if starter-discoverability-casual-menus
  :config
  (casual-suite-init))

(use-package keycast
  :ensure t
  :commands (keycast-log-mode))

(with-eval-after-load 'meow
  (meow-leader-define-key
   (cons "h" starter-help-map)
   (cons "j" starter-jump-map)
   '("." . embark-act)
   '("m" . menu-bar-open)))

(provide 'starter-setup-discoverability)
;;; starter-setup-discoverability.el ends here
