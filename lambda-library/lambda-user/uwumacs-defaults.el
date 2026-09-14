;;; uwumacs-defaults.el --- Sane defaults -*- lexical-binding: t; -*-
;; Generated from literate/25-defaults.org; edit the Org source, then tangle.

;; Distilled from Lambda-Emacs by Colin McLear (GPL-3.0-or-later).

;;; Code:
(defvar uwumacs-var-dir
  (if (boundp 'lem-var-dir) lem-var-dir (expand-file-name "var/" user-emacs-directory))
  "Directory for everything Emacs writes on its own.  Ignored by Git.")

(defvar uwumacs-cache-dir
  (if (boundp 'lem-cache-dir) lem-cache-dir (expand-file-name "cache/" uwumacs-var-dir))
  "Directory for caches that can be deleted at any time.")

(defvar uwumacs-etc-dir
  (if (boundp 'lem-etc-dir) lem-etc-dir (expand-file-name "etc/" uwumacs-var-dir))
  "Directory for state worth keeping: saved customizations, shell history.")

(dolist (directory (list uwumacs-var-dir uwumacs-cache-dir uwumacs-etc-dir))
  (make-directory directory t))

(setopt custom-file (expand-file-name "custom.el" uwumacs-etc-dir))
(unless (file-exists-p custom-file)
  (make-empty-file custom-file t))
(load custom-file nil t)
(setopt require-final-newline t
        large-file-warning-threshold 100000000
        confirm-kill-processes nil
        find-file-visit-truename t
        view-read-only t)

(let ((backups (expand-file-name "backup/" uwumacs-cache-dir))
      (auto-saves (expand-file-name "auto-save/" uwumacs-cache-dir)))
  (make-directory backups t)
  (make-directory auto-saves t)
  (setopt backup-directory-alist `(("." . ,backups))
          auto-save-file-name-transforms `((".*" ,auto-saves t))
          auto-save-list-file-prefix (expand-file-name ".saves-" auto-saves)))
(setopt make-backup-files t
        backup-by-copying t
        version-control t
        delete-old-versions t
        kept-new-versions 10
        kept-old-versions 0
        vc-make-backup-files t
        create-lockfiles nil
        auto-save-default t
        auto-save-timeout 30
        auto-save-interval 300)
(auto-save-visited-mode 1)

(setopt savehist-file (expand-file-name "savehist" uwumacs-cache-dir)
        savehist-save-minibuffer-history t
        history-length 100)
(savehist-mode 1)
(global-so-long-mode 1)
(setopt multisession-directory (expand-file-name "multisession/" uwumacs-cache-dir))
(setq-default indent-tabs-mode nil
              tab-width 4
              fill-column 80
              tab-always-indent 'complete)
(setopt completion-cycle-threshold 3
        sentence-end-double-space nil
        line-move-visual t
        global-mark-ring-max 8
        mark-ring-max 8)
(prefer-coding-system 'utf-8)
(global-subword-mode 1)
(global-visual-line-mode 1)
(use-package ws-butler
  :ensure t
  :hook ((text-mode prog-mode) . ws-butler-mode))

(use-package expand-region
  :ensure t
  :defer t)
(setopt use-short-answers t
        ring-bell-function #'ignore
        make-pointer-invisible t
        switch-to-buffer-preserve-window-point t
        display-line-numbers-type 'visual
        display-line-numbers-width-start t)
(blink-cursor-mode -1)
(fringe-mode '(1 . 0))

(setopt scroll-step 1
        scroll-margin 3
        scroll-conservatively 101
        scroll-up-aggressively 0.01
        scroll-down-aggressively 0.01
        auto-window-vscroll nil
        hscroll-step 1
        hscroll-margin 1
        mouse-wheel-follow-mouse t
        mouse-wheel-progressive-speed nil
        mouse-wheel-scroll-amount '(1 ((shift) . 2))
        mouse-autoselect-window t)
(context-menu-mode 1)

(setopt uniquify-buffer-name-style 'reverse
        uniquify-separator " • "
        uniquify-after-kill-buffer-p t
        uniquify-ignore-buffers-re "^\\*")

(setopt auto-revert-verbose nil
        auto-revert-interval 0.5
        revert-without-query '(".*")
        global-auto-revert-non-file-buffers t)
(global-auto-revert-mode 1)

;; A buffer that is not visiting a file still picks a major mode by its name.
(setq-default major-mode (lambda ()
                           (if buffer-file-name
                               (fundamental-mode)
                             (let ((buffer-file-name (buffer-name)))
                               (set-auto-mode)))))
(fset 'undo-auto-amalgamate #'ignore)
(setopt undo-limit 67108864
        undo-strong-limit 100663296
        undo-outer-limit 1006632960)
(winner-mode 1)
(windmove-default-keybindings)
(setopt window-divider-default-right-width 10
        window-divider-default-bottom-width 10
        window-divider-default-places 'right-only)
(window-divider-mode 1)

(use-package ace-window
  :ensure t
  :commands (ace-window ace-swap-window aw-flip-window))

(use-package popper
  :ensure t
  :bind (("M-`" . popper-toggle)
         ("C-`" . popper-cycle)
         ("C-M-`" . popper-toggle-type))
  :custom
  (popper-window-height 20)
  (popper-group-function #'popper-group-by-directory)
  (popper-reference-buffers
   '("\\*Messages\\*"
     "Output\\*$"
     "\\*Async Shell Command\\*"
     help-mode
     compilation-mode))
  :init
  (popper-mode 1)
  (popper-echo-mode 1))
(defvar uwumacs-scratch-file (expand-file-name "scratch" uwumacs-cache-dir)
  "Where the *scratch* buffer's text is kept between sessions.")

(defun uwumacs--bury-scratch ()
  "Bury *scratch* instead of killing it."
  (if (eq (current-buffer) (get-buffer "*scratch*"))
      (progn (bury-buffer) nil)
    t))

(defun uwumacs--save-scratch ()
  "Save the text of *scratch* to `uwumacs-scratch-file'."
  (with-current-buffer (get-buffer-create "*scratch*")
    (write-region (point-min) (point-max) uwumacs-scratch-file nil 'quiet)))

(defun uwumacs--restore-scratch ()
  "Restore *scratch* from `uwumacs-scratch-file' when it exists."
  (when (file-exists-p uwumacs-scratch-file)
    (with-current-buffer (get-buffer-create "*scratch*")
      (erase-buffer)
      (insert-file-contents uwumacs-scratch-file))))

(add-hook 'kill-buffer-query-functions #'uwumacs--bury-scratch)
(add-hook 'after-init-hook #'uwumacs--restore-scratch)
(add-hook 'kill-emacs-hook #'uwumacs--save-scratch)
(run-with-idle-timer 300 t #'uwumacs--save-scratch)
(when (or window-system (daemonp))
  (require 'server)
  (setopt server-client-instructions nil)
  (unless (server-running-p)
    (server-start)))
(defun uwumacs-user-buffer-p (&optional buffer)
  "Return non-nil when BUFFER is one the user opened, not an internal one."
  (not (string-match-p "\\`[ *]" (buffer-name buffer))))

(defun uwumacs-next-user-buffer ()
  "Switch to the next user buffer."
  (interactive)
  (next-buffer)
  (let ((tries 0))
    (while (and (< tries 20) (not (uwumacs-user-buffer-p)))
      (next-buffer)
      (setq tries (1+ tries)))))

(defun uwumacs-previous-user-buffer ()
  "Switch to the previous user buffer."
  (interactive)
  (previous-buffer)
  (let ((tries 0))
    (while (and (< tries 20) (not (uwumacs-user-buffer-p)))
      (previous-buffer)
      (setq tries (1+ tries)))))

(defun uwumacs-new-buffer (&optional frame)
  "Create an empty buffer; with FRAME (prefix argument), show it in a new frame."
  (interactive "P")
  (let ((buffer (generate-new-buffer "untitled")))
    (with-current-buffer buffer
      (funcall (default-value 'major-mode)))
    (if frame
        (display-buffer buffer '(display-buffer-pop-up-frame))
      (switch-to-buffer buffer))))

(defun uwumacs-copy-file-name ()
  "Show this buffer's file name and copy it to the kill ring."
  (interactive)
  (if-let* ((name (buffer-file-name)))
      (let ((short (abbreviate-file-name name)))
        (message "%s" short)
        (kill-new short))
    (user-error "This buffer is not visiting a file")))

(use-package rainbow-mode
  :ensure t
  :commands rainbow-mode)

(provide 'uwumacs-defaults)
;;; uwumacs-defaults.el ends here
