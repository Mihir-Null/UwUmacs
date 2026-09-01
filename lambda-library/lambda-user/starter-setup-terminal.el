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

(require 'cl-lib)

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

(defun starter--msys2-env ()
  "Return the configured MSYS2 env executable path."
  (expand-file-name "usr/bin/env.exe" starter-msys2-root))

(defun starter--msys2-process-path ()
  "Return PATH for an MSYS2 UCRT64 child process.

The MSYS2 POSIX tools are included so EAT can find its `sh' and `stty'
helpers.  This value is only installed in the dynamically scoped child
environment; it does not alter Emacs's global PATH or `exec-path'."
  (mapconcat #'identity
             (list (expand-file-name "ucrt64/bin" starter-msys2-root)
                   (expand-file-name "usr/bin" starter-msys2-root)
                   (or (getenv "PATH") ""))
             (if (characterp path-separator)
                 (char-to-string path-separator)
               path-separator)))

(defun starter--eat-with-msys2-process-wrapper (function &rest args)
  "Call EAT FUNCTION with ARGS through MSYS2's POSIX process wrapper.

EAT currently starts its terminal process with `/usr/bin/env sh', a path
which native Windows Emacs cannot resolve.  Translate only that outer helper
to the configured MSYS2 `env.exe'; paths used inside the MSYS2 shell retain
their normal POSIX meaning."
  (let ((env (starter--msys2-env))
        (make-process-function (symbol-function 'make-process))
        (process-environment (copy-sequence process-environment)))
    (unless (file-executable-p env)
      (user-error "MSYS2 env not found at %s; customize starter-msys2-root" env))
    (setenv "PATH" (starter--msys2-process-path))
    ;; Rebinding a C primitive can otherwise make native-comp try to write a
    ;; trampoline beside the Emacs installation, which is normally read-only.
    (let ((native-comp-enable-subr-trampolines nil))
      (cl-letf (((symbol-function 'make-process)
                 (lambda (&rest plist)
                   (let ((command (plist-get plist :command)))
                     (when (equal (car-safe command) "/usr/bin/env")
                       (setq plist
                             (plist-put plist :command
                                        (cons env (cdr command)))))
                     (apply make-process-function plist)))))
        (apply function args)))))

(defun starter-eat (&optional arg)
  "Open an ordinary EAT terminal, portably passing prefix ARG.

On native Windows, use MSYS2 only for EAT's POSIX launch helper.  The terminal
still runs the native shell selected by `starter-platform-apply'."
  (interactive "P")
  (if (eq system-type 'windows-nt)
      (starter--eat-with-msys2-process-wrapper #'eat nil arg)
    (eat nil arg)))

(defun starter-eat-project (&optional arg)
  "Open project-local EAT, portably passing prefix ARG."
  (interactive "P")
  (if (eq system-type 'windows-nt)
      (starter--eat-with-msys2-process-wrapper #'eat-project arg)
    (eat-project arg)))

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
      (starter--eat-with-msys2-process-wrapper
       #'eat (format "%s --login -i" (shell-quote-argument bash)) arg))))

(defvar-keymap starter+terminal-keys
  :doc "Integrated terminal commands."
  "e" #'starter-eat
  "p" #'starter-eat-project
  "m" #'starter-eat-msys2-ucrt64)

;; Meow should stay out of terminal input.  Keep EAT in insert state and expose a
;; compact terminal namespace without changing Lambda's native recovery prefix.
(with-eval-after-load 'meow
  (add-to-list 'meow-mode-state-list '(eat-mode . insert))
  (meow-leader-define-key `("o" . ,starter+terminal-keys)))

(provide 'starter-setup-terminal)
;;; starter-setup-terminal.el ends here
