;;; starter-setup-dashboard.el --- Doom-like home page -*- lexical-binding: t; -*-
;; Generated from literate/55-dashboard.org; edit the Org source, then tangle.

;;; Commentary:
;; A small home page using dashboard, project.el, recentf and bookmarks.
;; Fonts are established before dashboard measures the banner and buttons.

;;; Code:

(require 'uwumacs-ui)
(defun starter-dashboard-open-cheatsheet (&rest _)
  "Open the local keybindings and commands cheat sheet."
  (interactive)
  (find-file (expand-file-name "keybindings.org" lem-user-dir)))
(defun starter-dashboard-open-file (&rest _)
  "Prompt for a file from a dashboard button."
  (interactive)
  (call-interactively #'find-file))
(defun starter-dashboard-open-config (&rest _)
  "Open the documented literate configuration."
  (interactive)
  (starter-literate-open))
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
(defun starter-dashboard-center-lines ()
  "Center each visible dashboard line using its rendered pixel width.
Measure the actual buffer so heading display overlays and icon faces count.
Exclude trailing padding and compensate for leading indentation."
  (let ((inhibit-read-only t)
        (inhibit-redisplay t)
        (buffer (current-buffer)))
    (save-window-excursion
      ;; During after-init this buffer may not have been displayed yet.
      (set-window-buffer (selected-window) buffer)
      (with-current-buffer buffer
        (remove-text-properties (point-min) (point-max)
                                '(line-prefix nil wrap-prefix nil indent-prefix nil))
        (save-excursion
          (goto-char (point-min))
          (while (not (eobp))
            (let* ((start (line-beginning-position))
                   (end (line-end-position))
                   (first (progn (skip-chars-forward " \t" end) (point)))
                   (last (save-excursion
                           (goto-char end)
                           (skip-chars-backward " \t" start)
                           (point))))
              (when (< first last)
                (let* ((width (car (window-text-pixel-size
                                    (selected-window) start last t)))
                       (indent (car (window-text-pixel-size
                                     (selected-window) start first t)))
                       (offset (/ (+ width indent) 2.0))
                       (prefix (propertize
                                " " 'display
                                `(space :align-to (- center (,offset))))))
                  (add-text-properties start end
                                       `(line-prefix ,prefix wrap-prefix ,prefix)))))
            (forward-line)))))))
(defun starter-dashboard-recenter (&rest _)
  "Recompute visible dashboard text metrics after a font or theme change."
  (when-let* ((window (get-buffer-window dashboard-buffer-name t)))
    (with-selected-window window
      (with-current-buffer dashboard-buffer-name
        (starter-dashboard-center-lines)))))
(use-package dashboard
  :ensure t
  :demand t
  :init
  (setq dashboard-buffer-name "*home*"
        dashboard-startup-banner 'ascii
        dashboard-banner-ascii
        "╭──────────────────────────╮\n│            λ             │\n│       EMACS · DOTS       │\n╰──────────────────────────╯"
        dashboard-banner-logo-title "selection first · systems visible"
        dashboard-center-content t
        dashboard-vertically-center-content nil
        dashboard-navigation-cycle t
        dashboard-hide-cursor t
        dashboard-icon-type 'nerd-icons
        dashboard-set-heading-icons t
        dashboard-set-file-icons t
        dashboard-display-icons-p #'uwumacs-icons-available-p
        dashboard-heading-icon-height 1.0
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
                                    dashboard-insert-items
                                    starter-dashboard-center-lines)
        dashboard-init-info
        (lambda ()
          (format "Emacs %s · ready in %s"
                  emacs-version
                  (emacs-init-time)))
        dashboard-navigator-buttons
        '((("+" "File" "Open a file" starter-dashboard-open-file)
           ("◆" "Project" "Switch project" starter-dashboard-open-project)
           ("↺" "Recent" "Open a recent file" starter-dashboard-open-recent))
          (("λ" "Config" "Open Emacs-Dots config" starter-dashboard-open-config)
           ("◎" "Agenda" "Open Org agenda" starter-dashboard-open-agenda)
           ("*" "Scratch" "Open scratch buffer"
            (lambda (&rest _) (switch-to-buffer "*scratch*"))))
          (("?" "Keys & commands" "Open the local cheat sheet (or press ?)"
            starter-dashboard-open-cheatsheet))))
  :config
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

  (define-key dashboard-mode-map (kbd "?") #'starter-dashboard-open-cheatsheet)

  (add-hook 'window-setup-hook #'starter-dashboard-recenter 100)
  (add-hook 'after-setting-font-hook #'starter-dashboard-recenter 100)
  (add-hook 'enable-theme-functions #'starter-dashboard-recenter 100)

  ;; Skip the home page when Emacs was invoked with a file argument.
  (dashboard-setup-startup-hook))
;; Keep r/p/b/? and dashboard item shortcuts alongside Meow j/k and SPC.
(with-eval-after-load 'starter-setup-meow
  (add-to-list 'meow-mode-state-list '(dashboard-mode . motion))
  (meow-leader-define-key '("h" . dashboard-open)
                         '("H" . starter-dashboard-open-cheatsheet)))
(provide 'starter-setup-dashboard)
;;; starter-setup-dashboard.el ends here
