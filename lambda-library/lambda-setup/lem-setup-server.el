;;; lem-setup-server.el --- emacs server configuration -*- lexical-binding: t -*-

;;; Server
;; start server for emacsclient. The original guard was `:if
;; window-system', which is nil when emacs starts under launchd as
;; `--fg-daemon' before any GUI client connects. That meant the
;; launchd-managed daemon never called `(server-start)' and never
;; created /tmp/emacsUID/server, which forced every `emacsclient'
;; with ALTERNATE_EDITOR="" to spawn its own one-shot bg-daemon to
;; fill the socket gap -- the source of the "two daemons" pattern.
;; Run the server whenever this Emacs is GUI OR daemon-mode.
(use-package server
  :ensure nil
  :if (or window-system (daemonp))
  ;; :hook (after-init . server-mode)
  :defer 2
  :config
  ;; t/nil for instructions
  (setq server-client-instructions nil)
  ;; avoid warning screen
  (or (server-running-p)
      (server-start)))

;; functions for killing server-related emacsen
(defun lem-kill-all-emacsen ()
  (interactive)
  (dolist (pid (mapcar #'string-to-number
                       (split-string (shell-command-to-string "pgrep -i emacs") "\n" t)))
    (unless (= pid (emacs-pid))
      (signal-process pid 'TERM)))
  (save-buffers-kill-emacs))

(defun lem-kill-emacs-capture-daemon ()
  (interactive)
  (shell-command-to-string "pkill -f /Applications/Emacs.app/Contents/MacOS/emacs"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(provide 'lem-setup-server)
