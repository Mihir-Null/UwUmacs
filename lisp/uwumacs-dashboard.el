;;; uwumacs-dashboard.el --- Doom-like home page -*- lexical-binding: t; -*-
;; Generated from literate/55-dashboard.org; edit the Org source, then tangle.

;;; Commentary:
;; A small home page using dashboard, project.el, recentf and bookmarks.
;; Fonts are established before dashboard measures the banner and buttons.

;;; Code:

(require 'uwumacs-ui)
(defun uwumacs-dashboard-open-cheatsheet (&rest _)
  "Open the local keybindings and commands cheat sheet."
  (interactive)
  (find-file (expand-file-name "keybindings.org" uwumacs-lisp-dir)))
(defun uwumacs-dashboard-open-tutor (&rest _)
  "Start Meow's interactive tutorial."
  (interactive)
  (call-interactively #'meow-tutor))

(defun uwumacs-dashboard-open-keys-chapter (&rest _)
  "Open the keys chapter: the whole SPC tree, group by group."
  (interactive)
  (find-file (expand-file-name "literate/42-keys.org" user-emacs-directory)))
(defun uwumacs-dashboard-open-file (&rest _)
  "Prompt for a file from a dashboard button."
  (interactive)
  (call-interactively #'find-file))
(defun uwumacs-dashboard-open-config (&rest _)
  "Open the documented literate configuration."
  (interactive)
  (uwumacs-literate-open))
(defun uwumacs-dashboard-open-project (&rest _)
  "Choose a project using Emacs project.el."
  (interactive)
  (call-interactively #'project-switch-project))
(defun uwumacs-dashboard-open-recent (&rest _)
  "Choose a recently opened file."
  (interactive)
  (if (fboundp 'consult-recent-file)
      (call-interactively #'consult-recent-file)
    (call-interactively #'recentf-open-files)))
(defun uwumacs-dashboard-open-agenda (&rest _)
  "Open the Org agenda."
  (interactive)
  (call-interactively #'org-agenda))
(defun uwumacs-dashboard-center-lines ()
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
(defun uwumacs-dashboard-recenter (&rest _)
  "Recompute visible dashboard text metrics after a font or theme change."
  (when-let* ((window (get-buffer-window dashboard-buffer-name t)))
    (with-selected-window window
      (with-current-buffer dashboard-buffer-name
        (uwumacs-dashboard-center-lines)))))
(defvar uwumacs-dashboard-key-guide
  '(("SPC SPC" "run a command by name" "SPC h ?" "the cheat sheet")
    ("SPC f f" "open a file"           "SPC h t" "Meow's tutorial")
    ("SPC m"   "menu for this mode"    "SPC C c" "the reading guide"))
  "Rows of (KEY WHAT KEY WHAT) shown at the bottom of the home page.")

(defun uwumacs-dashboard-insert-key-guide ()
  "Insert the short guide to the first keys."
  (insert "\n")
  (dolist (row uwumacs-dashboard-key-guide)
    (pcase-let ((`(,left-key ,left-what ,right-key ,right-what) row))
      (insert (propertize (format "%-8s" left-key) 'face 'dashboard-navigator)
              (propertize (format "%-24s" left-what) 'face 'font-lock-comment-face)
              (propertize (format "%-8s" right-key) 'face 'dashboard-navigator)
              (propertize right-what 'face 'font-lock-comment-face)
              "\n"))))
(use-package dashboard
  :ensure t
  :demand t
  :init
  (setq dashboard-buffer-name "*home*"
        dashboard-startup-banner 'ascii
        dashboard-banner-ascii
        (mapconcat #'identity
                   '("╭────────────────────────────╮"
                     "│                            │"
                     "│     U w U m a c s   :3     │"
                     "│                            │"
                     "╰────────────────────────────╯")
                   "\n")
        dashboard-banner-logo-title "select · extend · act"
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
                                    uwumacs-dashboard-insert-key-guide
                                    uwumacs-dashboard-center-lines)
        dashboard-init-info
        (lambda ()
          (format "Emacs %s · ready in %s"
                  emacs-version
                  (emacs-init-time)))
        dashboard-navigator-buttons
        '((("+" "File" "Open a file" uwumacs-dashboard-open-file)
           ("◆" "Project" "Switch project" uwumacs-dashboard-open-project)
           ("↺" "Recent" "Open a recent file" uwumacs-dashboard-open-recent))
          (("◎" "Agenda" "Open the Org agenda" uwumacs-dashboard-open-agenda)
           ("*" "Scratch" "Open the scratch buffer"
            (lambda (&rest _) (switch-to-buffer "*scratch*")))
           ("λ" "Config" "Open the UwUmacs reading guide (SPC C c)"
            uwumacs-dashboard-open-config))
          (("?" "Keys & commands" "Open the local cheat sheet (SPC h ?, or ? here)"
            uwumacs-dashboard-open-cheatsheet)
           ("»" "Meow tutor" "Learn select, extend, act (SPC h t)"
            uwumacs-dashboard-open-tutor)
           ("§" "Leader tree" "Every SPC key, group by group"
            uwumacs-dashboard-open-keys-chapter))))
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

  (define-key dashboard-mode-map (kbd "?") #'uwumacs-dashboard-open-cheatsheet)

  (add-hook 'window-setup-hook #'uwumacs-dashboard-recenter 100)
  (add-hook 'after-setting-font-hook #'uwumacs-dashboard-recenter 100)
  (add-hook 'enable-theme-functions #'uwumacs-dashboard-recenter 100)

  ;; Skip the home page when Emacs was invoked with a file argument.
  (dashboard-setup-startup-hook))
;; Keep r/p/b/? and dashboard item shortcuts alongside Meow j/k and SPC.
(with-eval-after-load 'meow
  (add-to-list 'meow-mode-state-list '(dashboard-mode . motion)))
(provide 'uwumacs-dashboard)
;;; uwumacs-dashboard.el ends here
