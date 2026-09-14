;;; uwumacs-shell.el --- Eshell, EAT and Tramp -*- lexical-binding: t; -*-
;; Generated from literate/35-shells.org; edit the Org source, then tangle.

;; Distilled from Lambda-Emacs by Colin McLear (GPL-3.0-or-later).

;;; Code:

(require 'uwumacs-defaults)
(require 'uwumacs-leader)

(setenv "PAGER" "cat")
(setopt kill-buffer-query-functions
        (delq #'process-kill-buffer-query-function kill-buffer-query-functions))
(use-package exec-path-from-shell
  :ensure t
  :if (not (eq system-type 'windows-nt))
  :custom
  (exec-path-from-shell-arguments nil)
  :config
  (when (or window-system (daemonp))
    (exec-path-from-shell-initialize)))
(use-package eat
  :ensure t
  :commands (eat eat-project eat-eshell-mode)
  :custom
  (eat-kill-buffer-on-exit t)
  (eat-enable-yank-to-terminal t)
  (eat-enable-directory-tracking t)
  (eat-enable-shell-command-history t)
  (eat-enable-shell-prompt-annotation t)
  :config
  (with-eval-after-load 'eshell
    (eat-eshell-mode 1)))
(defvar uwumacs-eshell-dir (expand-file-name "eshell/" uwumacs-etc-dir)
  "Directory for Eshell history, aliases and the directory ring.")

(setopt eshell-directory-name uwumacs-eshell-dir
        eshell-history-file-name (expand-file-name "history" uwumacs-eshell-dir)
        eshell-last-dir-ring-file-name (expand-file-name "lastdir" uwumacs-eshell-dir)
        eshell-aliases-file (expand-file-name "alias" uwumacs-eshell-dir)
        eshell-buffer-maximum-lines 20000
        eshell-scroll-to-bottom-on-input 'all
        eshell-scroll-to-bottom-on-output 'all
        eshell-list-files-after-cd nil
        eshell-cmpl-ignore-case t
        eshell-cmpl-cycle-completions t
        eshell-history-size 10000
        eshell-hist-ignoredups t
        eshell-glob-case-insensitive t
        eshell-error-if-no-glob t
        eshell-destroy-buffer-when-process-dies t
        eshell-banner-message ""
        eshell-highlight-prompt t
        eshell-prompt-regexp "^Î» ")

(with-eval-after-load 'em-term
  (dolist (command '("htop" "top" "less" "more" "vim" "nano" "ssh" "tail"))
    (add-to-list 'eshell-visual-commands command))
  (add-to-list 'eshell-visual-subcommands '("git" "log" "diff" "show")))

(defun uwumacs--eshell-git-branch ()
  "Return the current Git branch for the prompt, or nil."
  (when (and (not (file-remote-p default-directory))
             (locate-dominating-file default-directory ".git"))
    (car (vc-git-branches))))

(defun uwumacs-eshell-prompt ()
  "A two-line prompt: directory and branch, then Î»."
  (let ((branch (uwumacs--eshell-git-branch)))
    (concat "\n"
            (propertize (abbreviate-file-name (eshell/pwd)) 'face 'font-lock-constant-face)
            (when branch (propertize (format " (%s)" branch) 'face 'font-lock-comment-face))
            "\n"
            (propertize "Î»" 'face 'font-lock-keyword-face)
            (propertize " " 'face 'default))))
(setopt eshell-prompt-function #'uwumacs-eshell-prompt)
(defvar uwumacs-eshell-aliases
  '(("g" "git --no-pager $*")
    ("gs" "magit-status")
    ("gd" "git diff --color $*")
    ("gl" "git log --oneline -20")
    ("l" "ls $*")
    ("la" "ls -la $*")
    ("ll" "ls -lah $*")
    ("d" "dired $1")
    ("ff" "find-file $1")
    ("e" "find-file $1")
    ("fr" "consult-recent-file")
    ("bb" "consult-buffer")
    ("pp" "project-switch-project")
    ("up" "eshell-up $1")
    ("q" "exit")
    ("x" "exit"))
  "Eshell aliases defined in Lisp.")

(with-eval-after-load 'em-alias
  (advice-add #'eshell-write-aliases-list :override #'ignore)
  (setq eshell-command-aliases-list (append eshell-command-aliases-list uwumacs-eshell-aliases)))

(defun eshell/z (&optional regexp)
  "Change to a previously visited directory chosen with completion.
With REGEXP, go to the most recent directory matching it."
  (let ((dirs (delete-dups (mapcar #'abbreviate-file-name (ring-elements eshell-last-dir-ring)))))
    (eshell/cd (if regexp
                   (eshell-find-previous-directory regexp)
                 (completing-read "Directory: " dirs nil t)))))

(defun uwumacs-eshell-clear ()
  "Clear the Eshell buffer."
  (interactive)
  (let ((inhibit-read-only t))
    (erase-buffer)
    (eshell-send-input)))

(defun uwumacs-eshell-project ()
  "Open an Eshell for the current project, or for this directory."
  (interactive)
  (require 'eshell)
  (let* ((root (if-let* ((project (project-current))) (project-root project) default-directory))
         (name (file-name-nondirectory (directory-file-name root)))
         (eshell-buffer-name (format "*eshell: %s*" name))
         (default-directory root))
    (eshell)))

(defun uwumacs--eshell-setup ()
  "Per-buffer Eshell settings."
  (keymap-local-set "C-l" #'uwumacs-eshell-clear)
  (setq-local imenu-generic-expression '(("Prompt" "^Î» \\(.*\\)" 1)))
  (hl-line-mode -1)
  (visual-line-mode 1))
(add-hook 'eshell-mode-hook #'uwumacs--eshell-setup)

(use-package eshell-syntax-highlighting
  :ensure t
  :after eshell
  :config
  (eshell-syntax-highlighting-global-mode 1))

(use-package eshell-up
  :ensure t
  :commands eshell-up
  :config
  (defalias 'eshell/up #'eshell-up))

(use-package esh-help
  :ensure t
  :after eshell
  :config
  (setup-esh-help-eldoc))

(use-package pcmpl-args :ensure t :after eshell)
(use-package pcomplete-extension :ensure t :after eshell)
(setopt tramp-persistency-file-name (expand-file-name "tramp" uwumacs-cache-dir)
        tramp-default-method "ssh"
        tramp-copy-size-limit nil
        tramp-use-ssh-controlmaster-options nil)
(with-eval-after-load 'meow
  (dolist (entry '((eshell-mode . insert) (eat-mode . insert) (shell-mode . insert) (term-mode . insert)))
    (add-to-list 'meow-mode-state-list entry)))

(uwumacs-define-localleader 'eshell-mode
  "c" (cons "clear" #'uwumacs-eshell-clear)
  "h" (cons "history" #'consult-history)
  "d" (cons "directory" #'consult-dir)
  "p" (cons "previous prompt" #'eshell-previous-prompt)
  "n" (cons "next prompt" #'eshell-next-prompt)
  "i" (cons "insert" #'meow-insert)
  "?" (cons "menu" #'casual-eshell-tmenu))

(provide 'uwumacs-shell)
;;; uwumacs-shell.el ends here
