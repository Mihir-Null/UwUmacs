;;; starter-setup-dashboard.el --- Doom-like home page -*- lexical-binding: t; -*-

;;; Commentary:
;; A small startup dashboard built on the maintained `dashboard.el' package.
;; It intentionally reuses project.el, recentf, bookmarks, Org, and the existing
;; Lambda/Meow command surface instead of introducing a second project/workspace
;; abstraction.

;;; Code:

(defun starter-dashboard-open-config (&rest _)
  "Open the user Lambda configuration."
  (interactive)
  (find-file lem-config-file))

(defun starter-dashboard-open-project (&rest _)
  "Choose a project using Emacs project.el."
  (interactive)
  (call-interactively #'project-switch-project))

(defun starter-dashboard-open-recent (&rest _)
  "Choose a recently opened file."
  (interactive)
  (if (fboundp 'consult-recent-file)
      (call-interactively #'consult-recent-file)
    (call-interactively #'recentf-open-files)))

(defun starter-dashboard-open-agenda (&rest _)
  "Open the Org agenda."
  (interactive)
  (call-interactively #'org-agenda))

(use-package dashboard
  :ensure t
  :demand t
  :init
  (setq dashboard-buffer-name "*home*"
        dashboard-startup-banner 'ascii
        dashboard-banner-ascii
        "          ╭──────────────────────────╮\n          │            λ             │\n          │       EMACS · DOTS       │\n          ╰──────────────────────────╯"
        dashboard-banner-logo-title "selection first · systems visible"
        dashboard-center-content t
        dashboard-vertically-center-content nil
        dashboard-navigation-cycle t
        dashboard-hide-cursor t
        dashboard-show-shortcuts t
        dashboard-projects-backend 'project-el
        dashboard-path-style 'truncate-middle
        dashboard-path-max-length 48
        dashboard-items '((recents . 5)
                          (projects . 5)
                          (bookmarks . 3))
        dashboard-item-shortcuts '((recents . "r")
                                   (projects . "p")
                                   (bookmarks . "b"))
        dashboard-item-names '(("Recent Files:" . "Recent")
                               ("Projects:" . "Projects")
                               ("Bookmarks:" . "Bookmarks"))
        dashboard-startupify-list '(dashboard-insert-banner
                                    dashboard-insert-banner-title
                                    dashboard-insert-newline
                                    dashboard-insert-navigator
                                    dashboard-insert-newline
                                    dashboard-insert-init-info
                                    dashboard-insert-items)
        dashboard-init-info
        (lambda ()
          (format "Emacs %s · ready in %s"
                  emacs-version
                  (emacs-init-time)))
        dashboard-navigator-buttons
        '((("+" "File" "Open a file" find-file)
           ("◆" "Project" "Switch project" starter-dashboard-open-project)
           ("↺" "Recent" "Open a recent file" starter-dashboard-open-recent))
          (("λ" "Config" "Open Emacs-Dots config" starter-dashboard-open-config)
           ("◎" "Agenda" "Open Org agenda" starter-dashboard-open-agenda)
           ("*" "Scratch" "Open scratch buffer"
            (lambda (&rest _) (switch-to-buffer "*scratch*")))))))
  :config
  ;; Keep the dashboard visually tied to the active theme rather than baking in
  ;; a second palette.
  (set-face-attribute 'dashboard-text-banner nil
                      :inherit 'font-lock-keyword-face
                      :weight 'bold)
  (set-face-attribute 'dashboard-banner-logo-title nil
                      :inherit 'font-lock-comment-face
                      :height 1.05)
  (set-face-attribute 'dashboard-heading nil
                      :inherit 'font-lock-function-name-face
                      :weight 'bold)
  (set-face-attribute 'dashboard-navigator nil
                      :inherit 'font-lock-keyword-face
                      :weight 'semi-bold)

  ;; `dashboard.el' intentionally skips the startup page when Emacs was invoked
  ;; with a file argument, matching Doom's behavior.
  (dashboard-setup-startup-hook))

;; Dashboard is an application-like buffer: retain its own r/p/b/number shortcuts
;; while Meow supplies j/k motion and SPC leader access.
(with-eval-after-load 'meow
  (add-to-list 'meow-mode-state-list '(dashboard-mode . motion)))

(provide 'starter-setup-dashboard)
;;; starter-setup-dashboard.el ends here
