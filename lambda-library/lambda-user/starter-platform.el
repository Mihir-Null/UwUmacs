;;; starter-platform.el --- Portable platform defaults -*- lexical-binding: t; -*-

;;; Commentary:
;; Safe defaults for native Windows, GNU/Linux/Nix, and macOS.  Platform
;; differences are kept here instead of being scattered across UI modules.

;;; Code:

(require 'seq)
(require 'subr-x)

(defgroup starter-platform nil
  "Portable defaults for the Lambda learning configuration."
  :group 'lambda-emacs)

(defun starter--user-home-directory ()
  "Return the user's ordinary home directory for configuration defaults.
On native Windows, Emacs may define HOME as AppData/Roaming, so prefer
USERPROFILE for user-owned projects and documents."
  (file-name-as-directory
   (if (eq system-type 'windows-nt)
       (or (getenv "USERPROFILE") (expand-file-name "~"))
     (expand-file-name "~"))))

(defcustom starter-project-directory
  (expand-file-name "Projects/" (starter--user-home-directory))
  "Default place to look for projects."
  :type 'directory)

(defcustom starter-org-directory
  (expand-file-name "Documents/org/" (starter--user-home-directory))
  "Portable starter Org directory."
  :type 'directory)

(defun starter--first-executable (&rest programs)
  "Return the first executable found in PROGRAMS."
  (seq-some #'executable-find programs))

(defun starter-platform-reveal-in-file-manager (&optional target)
  "Reveal TARGET in the native file manager.
Interactively, reveal the current file or open `default-directory'."
  (interactive)
  (let* ((path (expand-file-name
                (or target buffer-file-name default-directory)))
         (file-p (file-regular-p path))
         (directory (if file-p (file-name-directory path) path)))
    (pcase system-type
      ('windows-nt
       (if file-p
           (w32-shell-execute
            "open" "explorer.exe"
            (format "/select,\"%s\"" (convert-standard-filename path)))
         (w32-shell-execute "open" (convert-standard-filename directory))))
      ('darwin
       (if file-p
           (start-process "starter-reveal" nil "open" "-R" path)
         (start-process "starter-open-directory" nil "open" directory)))
      ('gnu/linux
       (if-let ((opener (executable-find "xdg-open")))
           (start-process "starter-open-directory" nil opener directory)
         (user-error "Install xdg-utils to reveal files externally")))
      (_ (user-error "No file-manager integration for %s" system-type)))))

(defun starter-platform-apply ()
  "Apply the currently configured portable platform defaults."
  (with-eval-after-load 'lem-setup-projects
    (setq lem-project-dir starter-project-directory))

  ;; Replace Lambda's macOS-only Finder command with a portable implementation.
  (with-eval-after-load 'lem-setup-keybindings
    (define-key lem+buffer-keys (kbd "f")
                #'starter-platform-reveal-in-file-manager))

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

  (when (memq system-type '(gnu/linux darwin))
    (with-eval-after-load 'exec-path-from-shell
      (setopt exec-path-from-shell-variables
              '("PATH" "MANPATH" "NIX_PATH" "NIX_PROFILES")))))

(provide 'starter-platform)
;;; starter-platform.el ends here
