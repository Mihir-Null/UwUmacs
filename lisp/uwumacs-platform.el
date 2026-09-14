;;; uwumacs-platform.el --- Portable platform defaults -*- lexical-binding: t; -*-
;; Generated from literate/30-platform.org; edit the Org source, then tangle.

;;; Commentary:
;; Safe defaults for Windows, GNU/Linux/Nix, and macOS.  Prefer discovery with
;; `executable-find' and platform-provided home locations over machine-specific
;; paths.  The macOS section is distilled from Lambda-Emacs by Colin McLear
;; (`lem-setup-macos', GPL-3.0-or-later).

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
              '("PATH" "MANPATH" "LANG" "NIX_PATH" "NIX_PROFILES"))))

  (when (eq system-type 'darwin)
    (uwumacs--platform-apply-macos)))
;; Defined by the Cocoa build and by auth-source; declared so the module
;; byte-compiles cleanly on every platform.
(defvar ns-use-native-fullscreen)
(defvar auth-sources)

(defcustom uwumacs-macos-modifiers
  '((ns-command-modifier . super)
    (ns-option-modifier . meta)
    (ns-right-option-modifier . none))
  "How the macOS modifier keys map to Emacs modifiers.
Each entry pairs an NS modifier variable with the modifier it produces:
`meta', `super', `hyper', `control', `alt', or `none' to leave the key
to macOS.  Applied by `uwumacs-platform-apply' after `private.el'."
  :type '(alist :key-type symbol :value-type symbol))
(defun uwumacs--macos-trash (path)
  "Move PATH to the macOS Trash with the `trash' command-line tool."
  (let ((status (call-process "trash" nil nil nil (expand-file-name path))))
    (unless (eql status 0)
      (error "Failed to move %s to the Trash (exit code %s)" path status))))

(defun uwumacs--macos-configure-trash ()
  "Send deleted files to the Trash by the best available means.
Return the means chosen: `native' when this Emacs moves files to the Trash
itself, `trash-command' for the `trash' tool, or `directory' for ~/.Trash."
  (setq delete-by-moving-to-trash t)
  (cond ((fboundp 'system-move-file-to-trash) 'native)
        ((executable-find "trash")
         (setq trash-directory nil)
         (defalias 'system-move-file-to-trash #'uwumacs--macos-trash)
         'trash-command)
        (t (setq trash-directory "~/.Trash")
           'directory)))

(defun uwumacs-delete-frame-or-quit ()
  "Close this frame when other frames remain; from the last one, quit Emacs."
  (interactive)
  (if (cdr (frame-list))
      (delete-frame)
    (save-buffers-kill-emacs)))

(defun uwumacs--macos-sync-titlebar (&rest _)
  "Give every frame's title bar the theme's light or dark appearance."
  (when (display-graphic-p)
    (let* ((background (face-background 'default nil (selected-frame)))
           (rgb (and (stringp background) (color-name-to-rgb background)))
           (appearance (if (and rgb (color-dark-p rgb)) 'dark 'light)))
      (setf (alist-get 'ns-appearance default-frame-alist) appearance)
      (dolist (frame (frame-list))
        (when (display-graphic-p frame)
          (set-frame-parameter frame 'ns-appearance appearance))))))
(defun uwumacs--platform-apply-macos ()
  "Apply the macOS policy: modifiers, Trash, locale, Keychain, keys, title bar."
  (pcase-dolist (`(,variable . ,modifier) uwumacs-macos-modifiers)
    (set variable modifier))
  (setq ns-use-native-fullscreen nil)
  (unless (getenv "LANG")
    (setenv "LANG" "en_US.UTF-8"))
  (uwumacs--macos-configure-trash)
  (with-eval-after-load 'auth-source
    (dolist (source '(macos-keychain-internet macos-keychain-generic))
      (add-to-list 'auth-sources source t)))
  (keymap-global-set "s-Z" #'undo-redo)
  (keymap-global-set "s-q" #'uwumacs-delete-frame-or-quit)
  (keymap-global-set "C-s-f" #'toggle-frame-fullscreen)
  (add-hook 'enable-theme-functions #'uwumacs--macos-sync-titlebar)
  (uwumacs--macos-sync-titlebar))
(defun uwumacs-reveal-in-file-manager (&optional file)
  "Show FILE in the desktop file manager, selected where the manager allows.
FILE defaults to this buffer's file, the file at point in Dired, or the
current directory."
  (interactive)
  (let* ((file (expand-file-name
                (or file
                    buffer-file-name
                    (and (derived-mode-p 'dired-mode)
                         (fboundp 'dired-get-filename)
                         (dired-get-filename nil t))
                    default-directory)))
         (directory (if (file-directory-p file)
                        (file-name-as-directory file)
                      (file-name-directory file))))
    (pcase system-type
      ('darwin (call-process "open" nil 0 nil "-R" file))
      ;; Explorer wants backslashes; `convert-standard-filename' would do
      ;; it, but only on a Windows build, and the tests run this branch
      ;; anywhere by binding `system-type'.
      ('windows-nt (call-process "explorer.exe" nil 0 nil
                                 (concat "/select," (subst-char-in-string ?/ ?\\ file))))
      (_ (call-process "xdg-open" nil 0 nil directory)))))
;; Do not force a font here. Inheriting the platform default makes first boot robust.
;; Fonts are chosen in the appearance chapter.

(provide 'uwumacs-platform)
;;; uwumacs-platform.el ends here
