;;; config.el --- Lambda learning configuration -*- lexical-binding: t; -*-

;;; Commentary:
;; Composition root for the user layer. Keep this file boring: choose Lambda modules
;; here and put subsystem-specific behavior in small files beside it.
;;
;; The staged structure follows Lambda's default config and Colin McLear's personal
;; config, while intentionally omitting machine/account-specific workflows.

;;; Code:

;;;; Personal identity
;; Leave blank until you choose to set these here or in private.el.
(setq user-full-name ""
      user-mail-address "")

;;;; Non-modal recovery / learning prefix
;; Define this before Lambda loads its keybinding module. `defcustom' preserves an
;; already-bound value, so the module will build its prefix maps with this choice.
(setq lem-prefix "C-c C-SPC")

;;;; Base framework
(message "Loading Lambda base modules...")
(measure-time
 (cl-dolist (mod '(lem-setup-libraries
                   lem-setup-settings
                   lem-setup-functions
                   lem-setup-macros
                   lem-setup-scratch
                   lem-setup-theme
                   lem-setup-windows
                   lem-setup-buffers
                   lem-setup-frames
                   lem-setup-fonts
                   lem-setup-faces))
   (require mod nil t)))

;; Portable user policy belongs after Lambda has defined its variables, but before
;; later modules consume shell/project paths.
(require 'starter-platform)

;; Machine/account-specific overrides are optional. Copy private.example.el to
;; private.el when needed; Git ignores that file.
(let ((private (expand-file-name "private.el" lem-user-dir)))
  (when (file-exists-p private)
    (load-file private)))
(starter-platform-apply)

;;;; After init — interactive editor shell
(defun starter-after-init ()
  "Load completion, navigation, projects, keymaps, and modal editing."
  (message "Loading Lambda interactive modules...")
  (measure-time
   (cl-dolist (mod '(lem-setup-completion
                     lem-setup-keybindings
                     lem-setup-help
                     lem-setup-navigation
                     lem-setup-dired
                     lem-setup-search
                     lem-setup-vc
                     lem-setup-projects
                     lem-setup-tabs))
     (require mod nil t)))

  ;; Lambda keymaps must exist before Meow exposes `lem+leader-map' through SPC.
  (require 'starter-setup-meow))
(add-hook 'after-init-hook #'starter-after-init)

;;;; After startup — useful editing subsystems
(defun starter-after-startup ()
  "Load programming, shell, Org, and lightweight UI modules."
  (message "Loading Lambda editing modules...")
  (measure-time
   (cl-dolist (mod '(lem-setup-programming
                     lem-setup-shell
                     lem-setup-eshell
                     lem-setup-org-base
                     lem-setup-org-settings
                     lem-setup-colors
                     lem-setup-modeline
                     lem-setup-server))
     (require mod nil t)))

  (require 'starter-setup-org)

  ;; Optional learning step: read this module first, then enable it.
  ;; (require 'starter-setup-languages)
  )
(add-hook 'emacs-startup-hook #'starter-after-startup)

;;;; Discoverability
;; which-key is built into Emacs 30+ and enabled by Lambda's keybinding module.
(with-eval-after-load 'which-key
  (setopt which-key-idle-delay 0.45
          which-key-idle-secondary-delay 0.05))

;;;; First commands to learn
;; M-x meow-tutor
;; SPC SPC        -> M-x
;; SPC /          -> describe Meow/keypad key
;; C-h k          -> describe key
;; C-h m          -> describe active modes
;; M-x describe-keymap

(provide 'config)
;;; config.el ends here
