;;; uwumacs-platform.el --- Portable platform defaults -*- lexical-binding: t; -*-
;; Generated from literate/30-platform.org; edit the Org source, then tangle.

;;; Commentary:
;; Safe defaults for Windows, GNU/Linux/Nix, and macOS. Prefer discovery with
;; `executable-find' and platform-provided home locations over machine-specific paths.

;;; Code:

(require 'seq)
(require 'subr-x)
(defgroup uwumacs-platform nil
  "Portable defaults for the Lambda learning configuration."
  :group 'uwumacs)
(defun uwumacs--user-home-directory ()
  "Return the user's ordinary home directory for configuration defaults.
On native Windows, Emacs may define HOME as AppData/Roaming, so prefer
USERPROFILE for user-owned projects and documents."
  (file-name-as-directory
   (if (eq system-type 'windows-nt)
       (or (getenv "USERPROFILE") (expand-file-name "~"))
     (expand-file-name "~"))))
(defcustom uwumacs-project-directory
  (expand-file-name "Projects/" (uwumacs--user-home-directory))
  "Default place to look for projects."
  :type 'directory)
(defcustom uwumacs-org-directory
  (expand-file-name "Documents/org/" (uwumacs--user-home-directory))
  "Portable starter Org directory."
  :type 'directory)
(defun uwumacs--first-executable (&rest programs)
  "Return the first executable found in PROGRAMS."
  (seq-some #'executable-find programs))
(defun uwumacs--skip-exec-path-from-shell-on-windows (&rest _)
  "Keep native Windows Emacs's inherited process environment unchanged."
  nil)
(defun uwumacs-platform-apply ()
  "Apply the currently configured portable platform defaults."
  ;; Choose a usable shell without assuming a username, Homebrew prefix, Nix profile,
  ;; or conventional Unix filesystem on Windows.
  (pcase system-type
    ('windows-nt
     (cond
      ((executable-find "pwsh.exe")
       (setq-default shell-file-name (executable-find "pwsh.exe"))
       (setq explicit-shell-file-name (executable-find "pwsh.exe")
             shell-command-switch "-Command"))
      ((executable-find "powershell.exe")
       (setq-default shell-file-name (executable-find "powershell.exe"))
       (setq explicit-shell-file-name (executable-find "powershell.exe")
             shell-command-switch "-Command"))
      ((executable-find "cmd.exe")
       (setq-default shell-file-name (executable-find "cmd.exe"))
       (setq explicit-shell-file-name (executable-find "cmd.exe")
             shell-command-switch "/c"))))
    ('darwin
     (when-let ((shell (uwumacs--first-executable "zsh" "bash" "sh")))
       (setq-default shell-file-name shell)
       (setq explicit-shell-file-name shell
             shell-command-switch "-c")))
    ('gnu/linux
     (when-let ((shell (uwumacs--first-executable "zsh" "bash" "sh")))
       (setq-default shell-file-name shell)
       (setq explicit-shell-file-name shell
             shell-command-switch "-c"))))

  ;; Lambda configures exec-path-from-shell.  It supports POSIX shells, so native
  ;; Windows keeps the environment inherited from Windows instead of asking
  ;; PowerShell to evaluate Unix `printf' syntax.  Linux/macOS retain Lambda's
  ;; intended login-shell import without assuming a particular Nix profile path.
  (if (eq system-type 'windows-nt)
      (with-eval-after-load 'exec-path-from-shell
        (unless (advice-member-p
                 #'uwumacs--skip-exec-path-from-shell-on-windows
                 #'exec-path-from-shell-initialize)
          (advice-add #'exec-path-from-shell-initialize :override
                      #'uwumacs--skip-exec-path-from-shell-on-windows)))
    (with-eval-after-load 'exec-path-from-shell
      (setopt exec-path-from-shell-variables
              '("PATH" "MANPATH" "NIX_PATH" "NIX_PROFILES")))))
;; Do not force a font here. Inheriting the platform default makes first boot robust.
;; Fonts are chosen in the appearance chapter.

(provide 'uwumacs-platform)
;;; uwumacs-platform.el ends here
