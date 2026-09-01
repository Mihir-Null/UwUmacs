;;; starter-setup-terminal.el --- Integrated terminal entries -*- lexical-binding: t; -*-

;;; Commentary:
;; Keep the ordinary Windows shell policy in `starter-platform.el', while exposing
;; MSYS2 as an explicit Unix-like development terminal through EAT.
;;
;; MSYS2 documents the essential environment setup as setting MSYSTEM to UCRT64,
;; optionally CHERE_INVOKING to preserve the current directory, then starting a
;; login shell.  Doing that in a dynamically scoped `process-environment' keeps
;; the MSYS2 environment local to the EAT child process rather than changing the
;; environment of native Emacs itself.

;;; Code:

(defgroup starter-terminal nil
  "Integrated terminal entries for the starter configuration."
  :group 'lambda-emacs)

(defcustom starter-msys2-root
  (file-name-as-directory
   (or (getenv "MSYS2_ROOT") "C:/msys64/"))
  "Root directory of the MSYS2 installation on Windows."
  :type 'directory)

(defun starter--msys2-bash ()
  "Return the configured MSYS2 Bash executable path."
  (expand-file-name "usr/bin/bash.exe" starter-msys2-root))

(defun starter-eat-msys2-ucrt64 (&optional arg)
  "Open an MSYS2 UCRT64 login shell in EAT.

The terminal starts in `default-directory' and leaves Emacs's native Windows
shell configuration unchanged.  With prefix ARG, pass ARG through to `eat' so
multiple numbered terminal buffers can be created in the usual EAT way."
  (interactive "P")
  (unless (eq system-type 'windows-nt)
    (user-error "The MSYS2 UCRT64 terminal entry is for native Windows Emacs"))
  (let ((bash (starter--msys2-bash)))
    (unless (file-executable-p bash)
      (user-error "MSYS2 Bash not found at %s; customize starter-msys2-root" bash))
    (let ((process-environment (copy-sequence process-environment))
          (eat-buffer-name "*eat:msys2-ucrt64*"))
      ;; MSYS2's documented environment selector.  CHERE_INVOKING keeps the
      ;; current Emacs directory instead of changing to the MSYS2 home directory.
      (setenv "MSYSTEM" "UCRT64")
      (setenv "CHERE_INVOKING" "1")
      (eat (format "%s --login -i" (shell-quote-argument bash)) arg))))

(defvar-keymap starter+terminal-keys
  :doc "Integrated terminal commands."
  "e" #'eat
  "p" #'eat-project
  "m" #'starter-eat-msys2-ucrt64)

;; Meow should stay out of terminal input.  Keep EAT in insert state and expose a
;; compact terminal namespace without changing Lambda's native recovery prefix.
(with-eval-after-load 'meow
  (add-to-list 'meow-mode-state-list '(eat-mode . insert))
  (meow-leader-define-key `("o" . ,starter+terminal-keys)))

(provide 'starter-setup-terminal)
;;; starter-setup-terminal.el ends here
