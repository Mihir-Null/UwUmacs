;;; config.el --- Lambda learning configuration -*- lexical-binding: t; -*-
;; Generated from literate/20-user-policy.org; edit the Org source, then tangle.

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
;; no-surprises fallback; `starter-setup-ui' replaces it with Sonokai after the
;; rest of the editor surface is available.
(setq lem-ui-theme 'lambda-dark)
;;;; Base framework
(message "Loading Lambda base modules...")
(measure-time
 (cl-dolist (mod '(lem-setup-functions
                   lem-setup-theme
                   lem-setup-fonts
                   lem-setup-faces))
   (require mod nil t)))
;; Sane defaults, state directories and small helpers (literate/25-defaults.org).
(require 'uwumacs-defaults)
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
;; Establish final font metrics and icon mappings before dashboard measures text.
(require 'starter-setup-fonts)
;; Explicit authoring commands; ordinary startup loads generated Lisp only.
(require 'starter-setup-literate)
;; Install the startup home page before after-init/startup hooks run. The dashboard
;; uses project.el/recentf/bookmarks and therefore remains a presentation layer over
;; ordinary Emacs facilities rather than a second workspace system.
(require 'starter-setup-dashboard)
;;;; After init — interactive editor shell
(defun starter-after-init ()
  "Load completion, navigation, projects, keymaps, and modal editing."
  (message "Loading Lambda interactive modules...")
  (measure-time
   (cl-dolist (mod '(lem-setup-keybindings
                     lem-setup-navigation
                     lem-setup-dired
                     lem-setup-search
                     lem-setup-vc
                     lem-setup-projects
                     lem-setup-tabs))
     (require mod nil t)))

  ;; Completion and help are ours (literate/60-completion.org, 62-help.org).
  (require 'uwumacs-completion)
  (require 'uwumacs-help)
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
                     lem-setup-org-settings))
     (require mod nil t)))

  ;; Replace Lambda's moving Tree-sitter grammar recipes and unconditional mode
  ;; remaps with reproducible Emacs-30-compatible pins and availability checks.
  (require 'starter-setup-treesit)

  ;; Eglot commands are always available, while language packages and automatic
  ;; server startup remain explicit per-machine choices.
  (require 'starter-setup-languages)

  ;; Lambda owns EAT itself; this user module only adds explicit terminal entries
  ;; such as the Windows MSYS2 UCRT64 environment.
  (require 'starter-setup-terminal)

  (require 'starter-setup-org)
  ;; UI is intentionally a user module rather than Lambda's `lem-setup-modeline'.
  ;; It supplies Sonokai, doom-modeline, workspace-tab presentation, optional
  ;; Nerd Icons, and modest spacing while retaining ordinary OS-managed frames.
  (require 'starter-setup-ui)

  ;; Apply frame policy after Lambda's Help, Org and UI defaults.
  (require 'starter-setup-frames)

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
;; SPC /          -> describe the leader and this buffer's localleader
;; SPC o m        -> MSYS2 UCRT64 in EAT (Windows)
;; C-h k          -> describe key
;; C-h m          -> describe active modes
;; M-x describe-keymap

(provide 'config)
;;; config.el ends here
