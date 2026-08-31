;;; config.el --- Meow-first Firemacs adaptation -*- lexical-binding: t; -*-

;;; Commentary:
;; Composition root for the Lambda user layer on the `firemacs-meow' branch.
;; Lambda remains the framework; the modules in this directory adapt Firemacs'
;; layout, feedback, and motion ideas around Meow and portable graphical Emacs.

;;; Code:

;;;; Personal identity
(setq user-full-name ""
      user-mail-address "")

;;;; Non-modal recovery / learning prefix
(setq lem-prefix "C-c C-SPC")

;;;; Early theme fallback
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

;; Do not load `lem-setup-frames'.  This branch deliberately keeps ordinary,
;; decorated, non-fullscreen frames so FancyWM and native Linux/macOS window
;; managers remain authoritative for placement, resizing, and tiling.

(require 'starter-platform)

(let ((private (expand-file-name "private.el" lem-user-dir)))
  (when (file-exists-p private)
    (load-file private)))
(starter-platform-apply)

;;;; After init — navigation, command hierarchy, and modal interaction
(defun starter-after-init ()
  "Load the interactive Lambda shell and the Meow-first motion layer."
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

  ;; Motion commands exist before Meow binds C-u/C-d/C-f to them.
  (require 'starter-setup-motion)
  (require 'starter-setup-meow))
(add-hook 'after-init-hook #'starter-after-init)

;;;; After startup — editing subsystems and presentation
(defun starter-after-startup ()
  "Load editing, presentation, tabs, and graphical discoverability."
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
  (require 'starter-setup-ui)
  (require 'starter-setup-tabs)
  (require 'starter-setup-discoverability)

  ;; Optional learning step: read this module first, then enable it.
  ;; (require 'starter-setup-languages)
  )
(add-hook 'emacs-startup-hook #'starter-after-startup)

;;;; Discoverability defaults available before the richer UI loads
(with-eval-after-load 'which-key
  (setopt which-key-idle-delay 0.35
          which-key-idle-secondary-delay 0.05))

;;;; First commands to learn
;; M-x meow-tutor
;; SPC             -> semantic leader with which-key
;; SPC h .         -> documentation at point
;; SPC j ...       -> visible jump commands
;; SPC .           -> contextual Embark actions
;; C-h k / C-h m   -> native key/mode inspection

(provide 'config)
;;; config.el ends here
