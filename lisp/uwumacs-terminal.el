;;; uwumacs-terminal.el --- The terminal -*- lexical-binding: t; -*-
;; Generated from literate/34-terminal.org; edit the Org source, then tangle.

;;; Commentary:
;; ghostel (https://github.com/dakra/ghostel) is the terminal emulator.  This
;; module sets its options, loads the integrations it ships for Eshell, comint,
;; Org, bookmarks, desktop, input methods and Consult, and bridges its five
;; input modes to Meow's states.

;;; Code:

(require 'uwumacs-defaults)
(require 'uwumacs-leader)
(require 'uwumacs-platform)

(declare-function meow-insert-exit "meow-command" ())
(declare-function ghostel-alt-screen-p "ghostel" ())
(declare-function ghostel-send-key "ghostel" (key-name &optional mods))
(declare-function ghostel-semi-char-mode "ghostel" ())
(declare-function ghostel-readonly-enter "ghostel" ())
(declare-function ghostel "ghostel" (&optional arg))
(declare-function ghostel-project "ghostel" (&optional arg))

(defgroup uwumacs-terminal nil
  "The integrated terminal."
  :group 'uwumacs)
(defcustom uwumacs-terminal-module-directory
  (expand-file-name "ghostel/" uwumacs-var-dir)
  "Directory holding ghostel's native module.
Kept outside `package-user-dir' so upgrading the package never deletes a
module file this Emacs has already loaded."
  :type 'directory)

(defun uwumacs-terminal-module-installed-p ()
  "Return non-nil when ghostel's native module has been downloaded or built.
Nil also when this Emacs was built without dynamic module support, which
is what the terminal needs."
  (and module-file-suffix
       (file-exists-p
        (expand-file-name (concat "ghostel-module" module-file-suffix)
                          uwumacs-terminal-module-directory))))
(use-package ghostel
  :vc (:url "https://github.com/dakra/ghostel" :lisp-dir "lisp" :rev :newest)
  :defer t
  :commands (ghostel ghostel-project ghostel-other ghostel-list-buffers
             ghostel-create ghostel-exec ghostel-compile ghostel-recompile)
  :custom
  (ghostel-module-directory uwumacs-terminal-module-directory)
  (ghostel-kill-buffer-on-exit t)
  (ghostel-query-before-killing 'auto)
  (ghostel-max-scrollback (* 5 1024 1024))
  (ghostel-scroll-on-input t)
  (ghostel-enable-osc52 nil)
  (ghostel-detect-password-prompts t)
  :config
  ;; Ghostel runs $SHELL, which native Windows does not set; follow the shell
  ;; the platform chapter picked instead of ghostel's /bin/sh fallback.
  (when (and (eq system-type 'windows-nt) (not (getenv "SHELL")))
    (setopt ghostel-shell (or explicit-shell-file-name shell-file-name)))

  ;; A shell inside the terminal can call these Emacs commands by name:
  ;;   ghostel_cmd find-file README.md
  ;;   ghostel_cmd magit-status
  ;; Only the listed commands can be reached, and every argument is a string.
  (dolist (command '(("magit-status" magit-status)
                     ("find-file-other-frame" find-file-other-frame)
                     ("treemacs-find-file" treemacs-find-file)))
    (add-to-list 'ghostel-eval-cmds command))

  ;; Integrations that ship with ghostel and only make sense once it is here:
  ;; ghostel: links in Org, bookmarks that reopen a terminal where it was,
  ;; terminals that survive a desktop session, and Lisp input methods
  ;; (Hangul, Quail) composing into the terminal rather than the buffer.
  (require 'ghostel-org nil t)
  (require 'ghostel-bookmark nil t)
  (require 'ghostel-desktop nil t)
  (when (require 'ghostel-ime nil t)
    (add-hook 'ghostel-mode-hook #'ghostel-ime-mode)))
(defun uwumacs-terminal--freeze ()
  "Freeze the terminal when Meow leaves Insert state.
The buffer becomes read-only, so Meow's grammar can select its output."
  (when (and (derived-mode-p 'ghostel-mode) (not buffer-read-only))
    (ghostel-readonly-enter)))

(defun uwumacs-terminal--thaw ()
  "Give the keyboard back to the terminal when Meow enters Insert state."
  (when (and (derived-mode-p 'ghostel-mode) buffer-read-only)
    (ghostel-semi-char-mode)))

(defun uwumacs-terminal--meow-setup ()
  "Keep Meow's state and ghostel's input mode in step in this buffer."
  (add-hook 'meow-insert-exit-hook #'uwumacs-terminal--freeze nil t)
  (add-hook 'meow-insert-enter-hook #'uwumacs-terminal--thaw nil t))

(add-hook 'ghostel-mode-hook #'uwumacs-terminal--meow-setup)
(defcustom uwumacs-terminal-escape 'auto
  "Where the escape key goes in a terminal while Meow is in Insert state.
`auto'     to the program while it is drawing a full-screen interface
           (vim, less, htop, a TUI agent), and to Meow otherwise.
`terminal' always to the program.
`meow'     always to Meow, leaving Insert state."
  :type '(choice (const :tag "Full-screen programs only" auto)
                 (const :tag "Always the terminal" terminal)
                 (const :tag "Always Meow" meow)))

(defvar-local uwumacs-terminal--escape nil
  "This buffer's override of `uwumacs-terminal-escape', or nil to follow it.")

(defun uwumacs-terminal--escape-target ()
  "Return `terminal' or `meow': where the escape key should go here."
  (pcase (or uwumacs-terminal--escape uwumacs-terminal-escape)
    ('terminal 'terminal)
    ('meow 'meow)
    (_ (if (ghostel-alt-screen-p) 'terminal 'meow))))

(defun uwumacs-terminal-escape-dwim ()
  "Leave Meow's Insert state, or send escape to a full-screen program."
  (interactive)
  (if (and (derived-mode-p 'ghostel-mode)
           (eq (uwumacs-terminal--escape-target) 'terminal))
      (ghostel-send-key "escape")
    (call-interactively #'meow-insert-exit)))

(defun uwumacs-terminal-toggle-escape ()
  "Switch where the escape key goes in this terminal, and say where."
  (interactive)
  (unless (derived-mode-p 'ghostel-mode)
    (user-error "This is not a terminal buffer"))
  (setq uwumacs-terminal--escape
        (if (eq (uwumacs-terminal--escape-target) 'terminal) 'meow 'terminal))
  (message "Escape %s"
           (if (eq uwumacs-terminal--escape 'terminal)
               "now goes to the program in the terminal"
             "now leaves Insert state")))
(with-eval-after-load 'meow
  (dolist (entry '((ghostel-mode . insert)
                   (ghostel-compile-view-mode . motion)))
    (add-to-list 'meow-mode-state-list entry))
  (keymap-set meow-insert-state-keymap "<escape>" #'uwumacs-terminal-escape-dwim))
(defun uwumacs-terminal--without-module (error)
  "Re-signal ERROR, or explain that the native module is missing."
  (if (uwumacs-terminal-module-installed-p)
      (signal (car error) (cdr error))
    (user-error "The terminal needs its native module: %s"
                (substitute-command-keys "\\[ghostel-download-module]"))))

(defun uwumacs-terminal-open (&optional arg)
  "Open a terminal.  With prefix ARG, open another one.
Ghostel offers to fetch its native module the first time; declining that
offer leaves the terminal unavailable, so say so in words."
  (interactive "P")
  (condition-case error (ghostel arg)
    (void-function (uwumacs-terminal--without-module error))))

(defun uwumacs-terminal-project (&optional arg)
  "Open a terminal at the current project's root.  ARG is passed through."
  (interactive "P")
  (condition-case error (ghostel-project arg)
    (void-function (uwumacs-terminal--without-module error))))

(defun uwumacs-terminal-msys2 (&optional arg)
  "Open an MSYS2 UCRT64 login shell in a terminal.
With prefix ARG, create another one instead of reusing the existing buffer."
  (interactive "P")
  (unless (eq system-type 'windows-nt)
    (user-error "The MSYS2 terminal is for native Windows Emacs"))
  (let ((bash (expand-file-name "usr/bin/bash.exe" uwumacs-msys2-root)))
    (unless (file-executable-p bash)
      (user-error "MSYS2 Bash not found at %s; set `uwumacs-msys2-root' in private.el"
                  bash))
    (let ((ghostel-shell (list bash "--login" "-i"))
          (ghostel-environment (append '("MSYSTEM=UCRT64" "CHERE_INVOKING=1")
                                       ghostel-environment))
          (ghostel-buffer-name "*ghostel: msys2*"))
      (ghostel arg))))
(with-eval-after-load 'project
  (add-to-list 'project-switch-commands '(ghostel-project "Terminal") t))

(use-package consult-ghostel
  :vc (:url "https://github.com/dakra/ghostel"
       :lisp-dir "extensions/consult-ghostel" :rev :newest)
  :after (ghostel consult)
  :demand t
  :bind (:map ghostel-semi-char-mode-map
         ("C-c h" . consult-ghostel-history)))
(with-eval-after-load 'eshell
  (when (require 'ghostel-eshell nil t)
    (ghostel-eshell-visual-command-mode 1)))

(defun uwumacs-terminal-comint-colours ()
  "Render this comint buffer's output with ghostel's terminal parser."
  (when (and (uwumacs-terminal-module-installed-p)
             (require 'ghostel-comint nil t))
    (ghostel-comint-mode 1)))

(add-hook 'shell-mode-hook #'uwumacs-terminal-comint-colours)
;; `ghostel-recompile' carries no autoload cookie, and `SPC m t' must work
;; before the terminal has ever been opened.
(autoload 'ghostel-compile "ghostel-compile" "Run a command in a terminal." t)
(autoload 'ghostel-recompile "ghostel-compile" "Re-run the last command." t)
(with-eval-after-load 'ghostel
  (require 'ghostel-compile nil t))

;; `uwumacs-define-localleader' replaces a mode's whole map, and prog-mode's
;; belongs to the programming chapter, so add to the map it built.
(with-eval-after-load 'uwumacs-programming
  (when-let* ((map (alist-get 'prog-mode uwumacs-localleader-alist)))
    (keymap-set map "t" (cons "compile in a terminal" #'ghostel-compile))
    (keymap-set map "T" (cons "recompile in a terminal" #'ghostel-recompile))
    (uwumacs-refresh-localleaders)))
(uwumacs-define-localleader 'ghostel-mode
  "i" (cons "type in the terminal" #'ghostel-semi-char-mode)
  "I" (cons "send every key (char mode)" #'ghostel-char-mode)
  "e" (cons "read live output" #'ghostel-emacs-mode)
  "c" (cons "freeze and copy" #'ghostel-copy-mode)
  "l" (cons "compose a line first" #'ghostel-line-mode)
  "y" (cons "copy everything" #'ghostel-copy-all)
  "p" (cons "paste" #'ghostel-paste)
  "k" (cons "clear" #'ghostel-clear)
  "K" (cons "clear scrollback" #'ghostel-clear-scrollback)
  "n" (cons "next prompt" #'ghostel-next-prompt)
  "N" (cons "previous prompt" #'ghostel-previous-prompt)
  "f" (cons "next link" #'ghostel-next-hyperlink)
  "F" (cons "previous link" #'ghostel-previous-hyperlink)
  "h" (cons "shell history" #'consult-ghostel-history)
  "b" (cons "another terminal" #'consult-ghostel)
  "q" (cons "send the next key literally" #'ghostel-send-next-key)
  "<escape>" (cons "where escape goes" #'uwumacs-terminal-toggle-escape)
  "M" (cons "install the native module" #'ghostel-download-module))

(provide 'uwumacs-terminal)
;;; uwumacs-terminal.el ends here
