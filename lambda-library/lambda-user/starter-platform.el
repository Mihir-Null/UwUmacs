;;; starter-platform.el --- Portable platform defaults -*- lexical-binding: t; -*-

;;; Commentary:
;; Safe defaults for Windows, GNU/Linux/Nix, and macOS. Prefer discovery with
;; `executable-find' over absolute machine-specific paths.

;;; Code:

(require 'seq)
(require 'subr-x)

(defgroup starter-platform nil
  "Portable defaults for the Lambda learning configuration."
  :group 'lambda-emacs)

(defcustom starter-project-directory (expand-file-name "~/Projects/")
  "Default place to look for projects."
  :type 'directory)

(defcustom starter-org-directory (expand-file-name "~/Documents/org/")
  "Portable starter Org directory."
  :type 'directory)

(defun starter--first-executable (&rest programs)
  "Return the first executable found in PROGRAMS."
  (seq-some #'executable-find programs))

(defun starter-platform-apply ()
  "Apply the currently configured portable platform defaults."
  ;; `lem-setup-projects' defines and also assigns `lem-project-dir', so apply the
  ;; user value after that feature loads rather than racing its initialization.
  (with-eval-after-load 'lem-setup-projects
    (setq lem-project-dir starter-project-directory))

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
     (when-let ((shell (starter--first-executable "zsh" "bash" "sh")))
       (setq-default shell-file-name shell)
       (setq explicit-shell-file-name shell
             shell-command-switch "-c")))
    ('gnu/linux
     (when-let ((shell (starter--first-executable "zsh" "bash" "sh")))
       (setq-default shell-file-name shell)
       (setq explicit-shell-file-name shell
             shell-command-switch "-c"))))

  ;; Lambda configures exec-path-from-shell. Declare useful variables when it loads;
  ;; do not assume a particular Nix profile path.
  (when (memq system-type '(gnu/linux darwin))
    (with-eval-after-load 'exec-path-from-shell
      (setopt exec-path-from-shell-variables
              '("PATH" "MANPATH" "NIX_PATH" "NIX_PROFILES")))))

;; Do not force a font here. Inheriting the platform default makes first boot robust.
;; Set `lem-ui-default-font' later once you know which fonts are available everywhere.

(provide 'starter-platform)
;;; starter-platform.el ends here
