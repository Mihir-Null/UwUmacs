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

;;;; UI fallback
;; Lambda's theme module loads during the base stage. Keep its dark theme as a
;; no-surprises fallback; `starter-setup-ui' replaces it with Doom Dark+ after the
;; rest of the editor surface is available.
(setq lem-ui-theme 'lambda-dark)

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
                   lem-setup-fonts
                   lem-setup-faces))
   (require mod nil t)))

;; Deliberately do not load `lem-setup-frames' in the starter configuration.
;; Lambda's frame module makes frames undecorated and recenters them. That aesthetic
;; is useful as an opt-in, but ordinary OS-managed frames are a more portable base:
;; Windows window managers can tile/resize them normally and Linux/macOS retain their
;; native compositor/window-manager behavior. Load `lem-setup-frames' explicitly
;; later if you decide you want Lambda's frameless presentation.

;; Portable user policy belongs after Lambda has defined its variables, but before
;; later modules consume shell/project paths.
(require 'starter-platform)

;; Machine/account-specific overrides are optional. Copy private.example.el to
;; private.el when needed; Git ignores that file.
(let ((private (expand-file-name "private.el" lem-user-dir)))
  (when (file-exists-p private)
    (load-file private)))
(starter-platform-apply)

;; Install the startup home page before after-init/startup hooks run. The dashboard
;; uses project.el/recentf/bookmarks and therefore remains a presentation layer over
;; ordinary Emacs facilities rather than a second workspace system.
(require 'starter-setup-dashboard)

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
  "Load programming, shell, Org, and the starter presentation layer."
  (message "Loading Lambda editing modules...")
  (measure-time
   (cl-dolist (mod '(lem-setup-programming
                     lem-setup-shell
                     lem-setup-eshell
                     lem-setup-org-base
                     lem-setup-org-settings
                     lem-setup-colors
                     lem-setup-server))
     (require mod nil t)))

  (require 'starter-setup-org)

  ;; UI is intentionally a user module rather than Lambda's `lem-setup-modeline'.
  ;; It supplies Doom Dark+, doom-modeline, workspace-tab presentation, optional
  ;; Nerd Icons, and modest spacing while retaining ordinary OS-managed frames.
  (require 'starter-setup-ui)

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
;; M-x dashboard-open -> return to the home page
;; SPC SPC        -> M-x
;; SPC /          -> describe Meow/keypad key
;; C-h k          -> describe key
;; C-h m          -> describe active modes
;; M-x describe-keymap

(provide 'config)
;;; config.el ends here
