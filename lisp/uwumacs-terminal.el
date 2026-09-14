;;; uwumacs-terminal.el --- Integrated terminal entries -*- lexical-binding: t; -*-
;; Generated from literate/30-platform.org; edit the Org source, then tangle.

;;; Commentary:
;; Keep the ordinary Windows shell policy in `uwumacs-platform.el', while exposing
;; MSYS2 as an explicit Unix-like development terminal through EAT.
;;
;; MSYS2 documents the essential environment setup as setting MSYSTEM to UCRT64,
;; optionally CHERE_INVOKING to preserve the current directory, then starting a
;; login shell.  Doing that in a dynamically scoped `process-environment' keeps
;; the MSYS2 environment local to the EAT child process rather than changing the
;; environment of native Emacs itself.

;;; Code:

(require 'cl-lib)
(defgroup uwumacs-terminal nil
  "Integrated terminal entries for the starter configuration."
  :group 'uwumacs)
(defcustom uwumacs-msys2-root
  (file-name-as-directory
   (or (getenv "MSYS2_ROOT") "C:/msys64/"))
  "Root directory of the MSYS2 installation on Windows."
  :type 'directory)
(defun uwumacs--msys2-bash ()
  "Return the configured MSYS2 Bash executable path."
  (expand-file-name "usr/bin/bash.exe" uwumacs-msys2-root))
(defun uwumacs--msys2-env ()
  "Return the configured MSYS2 env executable path."
  (expand-file-name "usr/bin/env.exe" uwumacs-msys2-root))
(defun uwumacs--msys2-process-path ()
  "Return PATH for an MSYS2 UCRT64 child process.

The MSYS2 POSIX tools are included so EAT can find its `sh' and `stty'
helpers.  This value is only installed in the dynamically scoped child
environment; it does not alter Emacs's global PATH or `exec-path'."
  (mapconcat #'identity
             (list (expand-file-name "ucrt64/bin" uwumacs-msys2-root)
                   (expand-file-name "usr/bin" uwumacs-msys2-root)
                   (or (getenv "PATH") ""))
             (if (characterp path-separator)
                 (char-to-string path-separator)
               path-separator)))
(defun uwumacs--eat-with-msys2-process-wrapper (function &rest args)
  "Call EAT FUNCTION with ARGS through MSYS2's POSIX process wrapper.

EAT currently starts its terminal process with `/usr/bin/env sh', a path
which native Windows Emacs cannot resolve.  Translate only that outer helper
to the configured MSYS2 `env.exe'; paths used inside the MSYS2 shell retain
their normal POSIX meaning."
  (let ((env (uwumacs--msys2-env))
        (make-process-function (symbol-function 'make-process))
        (process-environment (copy-sequence process-environment)))
    (unless (file-executable-p env)
      (user-error "MSYS2 env not found at %s; customize uwumacs-msys2-root" env))
    (setenv "PATH" (uwumacs--msys2-process-path))
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
(defun uwumacs-eat (&optional arg)
  "Open an ordinary EAT terminal, portably passing prefix ARG.

On native Windows, use MSYS2 only for EAT's POSIX launch helper.  The terminal
still runs the native shell selected by `uwumacs-platform-apply'."
  (interactive "P")
  (if (eq system-type 'windows-nt)
      (uwumacs--eat-with-msys2-process-wrapper #'eat nil arg)
    (eat nil arg)))
(defun uwumacs-eat-project (&optional arg)
  "Open project-local EAT, portably passing prefix ARG."
  (interactive "P")
  (if (eq system-type 'windows-nt)
      (uwumacs--eat-with-msys2-process-wrapper #'eat-project arg)
    (eat-project arg)))
(defun uwumacs-eat-msys2-ucrt64 (&optional arg)
  "Open an MSYS2 UCRT64 login shell in EAT.

The terminal starts in `default-directory' and leaves Emacs's native Windows
shell configuration unchanged.  With prefix ARG, pass ARG through to `eat' so
multiple numbered terminal buffers can be created in the usual EAT way."
  (interactive "P")
  (unless (eq system-type 'windows-nt)
    (user-error "The MSYS2 UCRT64 terminal entry is for native Windows Emacs"))
  (let ((bash (uwumacs--msys2-bash)))
    (unless (file-executable-p bash)
      (user-error "MSYS2 Bash not found at %s; customize uwumacs-msys2-root" bash))
    (let ((process-environment (copy-sequence process-environment))
          (eat-buffer-name "*eat:msys2-ucrt64*"))
      ;; MSYS2's documented environment selector.  CHERE_INVOKING keeps the
      ;; current Emacs directory instead of changing to the MSYS2 home directory.
      (setenv "MSYSTEM" "UCRT64")
      (setenv "CHERE_INVOKING" "1")
      (uwumacs--eat-with-msys2-process-wrapper
       #'eat (format "%s --login -i" (shell-quote-argument bash)) arg))))

;;;; Spelling
;; Use whichever checker exists: hunspell or aspell on PATH, or MSYS2's
;; hunspell.  Nothing is enabled when none is installed.
(defun uwumacs-spell-checker ()
  "Return the spell-checker program to use, or nil."
  (or (executable-find "hunspell")
      (executable-find "aspell")
      (let ((msys2 (expand-file-name "ucrt64/bin/hunspell.exe" uwumacs-msys2-root)))
        (and (eq system-type 'windows-nt) (file-executable-p msys2) msys2))))

(with-eval-after-load 'ispell
  (when-let* ((program (uwumacs-spell-checker)))
    (setopt ispell-program-name program)
    (when (string-suffix-p "hunspell.exe" program)
      (setenv "DICPATH" (expand-file-name "ucrt64/share/hunspell" uwumacs-msys2-root))
      (setopt ispell-dictionary "en_US"))))

(when (uwumacs-spell-checker)
  (add-hook 'text-mode-hook #'flyspell-mode)
  (add-hook 'prog-mode-hook #'flyspell-prog-mode))

(use-package flyspell-correct
  :ensure t
  :after flyspell
  :bind (:map flyspell-mode-map ("C-;" . flyspell-correct-wrapper)))

(use-package consult-flyspell
  :ensure t
  :commands consult-flyspell)

(provide 'uwumacs-terminal)
;;; uwumacs-terminal.el ends here
