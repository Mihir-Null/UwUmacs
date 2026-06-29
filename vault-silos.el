;;; vault-silos.el --- Leaky silo management for ~/vault/roam/ -*- lexical-binding: t; -*-
;;
;; A "leaky silo" is a subdirectory of roam/ that lives in its own git repo,
;; ignored by the main vault repo, and optionally pushed to an external remote
;; (e.g. a work GitHub) as a submodule.  The files remain physically inside
;; org-roam-directory so ID links and backlinks work normally in your local vault.
;;
;; Entry points:
;;   M-x vault-silo-create      scaffold a new silo (prompts for name, subdirs, remote)
;;   M-x vault-silo-push-remote add a remote to an existing silo + link as submodule
;;   M-x vault-silo-list        show all silos and their remote URLs

(require 'subr-x)

(defvar vault-silo-root (expand-file-name "~/vault/roam/")
  "Parent directory under which all silos live.")

(defvar vault-root (expand-file-name "~/vault/")
  "Root of the personal vault git repository.")

;;; ── Internal helpers ────────────────────────────────────────────────────────

(defun vault-silo--git (dir &rest args)
  "Run git ARGS in DIR.  Return (success . trimmed-output)."
  (let ((default-directory (file-name-as-directory dir)))
    (with-temp-buffer
      (let ((code (apply #'call-process "git" nil t nil args)))
        (cons (= code 0) (string-trim (buffer-string)))))))

(defun vault-silo--list-silos ()
  "Return names of existing silos (subdirs of roam/ that contain .git)."
  (seq-filter
   (lambda (d)
     (and (file-directory-p (expand-file-name d vault-silo-root))
          (file-directory-p
           (expand-file-name (concat d "/.git") vault-silo-root))))
   (directory-files vault-silo-root nil "^[^.]")))

(defun vault-silo--gitignore-append (entry)
  "Append ENTRY to vault .gitignore if not already present."
  (let ((gitignore (expand-file-name ".gitignore" vault-root)))
    (unless (and (file-exists-p gitignore)
                 (with-temp-buffer
                   (insert-file-contents gitignore)
                   (search-forward entry nil t)))
      (write-region (concat entry "\n") nil gitignore 'append))))

;;; ── Submodule wiring ────────────────────────────────────────────────────────

(defun vault-silo--wire-submodule (name remote silo-dir)
  "Push silo at SILO-DIR to REMOTE and register it as a vault submodule."
  (let ((push (vault-silo--git silo-dir "push" "-u" "origin" "main")))
    (if (not (car push))
        (user-error "Push failed for silo '%s': %s" name (cdr push))
      ;; git submodule add will re-attach the dir as a tracked submodule
      (vault-silo--git vault-root "submodule" "add" "--force"
                       remote (concat "roam/" name))
      (vault-silo--git vault-root "add" ".gitmodules")
      (vault-silo--git vault-root "commit" "-m"
                       (format "Add roam/%s as git submodule" name))
      (message "Silo '%s' published to %s and linked as submodule." name remote))))

;;; ── Public commands ─────────────────────────────────────────────────────────

;;;###autoload
(defun vault-silo-create (name subdirs remote)
  "Scaffold a new leaky silo at roam/NAME.

Prompts for:
  NAME     — directory name under roam/ (e.g. \"qec\", \"amo-physics\")
  SUBDIRS  — comma-separated list of subdirectories to create inside the silo
  REMOTE   — git remote URL; leave blank to add later with `vault-silo-push-remote'

Steps performed:
  1. Create NAME/ and any requested subdirectories
  2. Write a README.org stub with an org-roam ID so the silo is immediately
     discoverable via org-roam-find-file
  3. git init + initial commit inside NAME/
  4. Append roam/NAME to vault .gitignore
  5. git rm --cached roam/NAME (detach from vault index if previously tracked)
  6. If REMOTE given: push + register as vault submodule"
  (interactive
   (list
    (read-string "Silo name: ")
    (let ((raw (read-string "Subdirectories (comma-separated, blank for none): ")))
      (when (> (length raw) 0)
        (split-string raw "[,[:space:]]+" t)))
    (read-string "Remote URL (blank to add later): ")))
  (let* ((silo-dir (expand-file-name name vault-silo-root))
         (readme   (expand-file-name "README.org" silo-dir)))
    ;; 1. Directories
    (dolist (sub (cons "" subdirs))
      (make-directory (expand-file-name sub silo-dir) t))
    ;; 2. README.org stub (only if absent — safe to re-run)
    (unless (file-exists-p readme)
      (require 'org-id)
      (with-temp-file readme
        (insert (format ":PROPERTIES:\n:ID:       %s\n:END:\n"
                        (org-id-new)))
        (insert (format "#+title: %s\n" (capitalize name)))
        (insert (format "#+date: [%s]\n" (format-time-string "%Y-%m-%d")))
        (insert (format "#+filetags: :silo:%s:\n\n" name))
        (insert "* Overview\n\n")
        (insert (format "Silo for =%s= notes.\n" name))
        (insert (format "Subdirectories: %s\n\n"
                        (if subdirs (string-join subdirs ", ") "none")))
        (insert "* Index\n\n")))
    ;; 3. git init + commit
    (vault-silo--git silo-dir "init" "-b" "main")
    (vault-silo--git silo-dir "add" ".")
    (vault-silo--git silo-dir "commit" "-m"
                     (format "Initial %s silo" name))
    ;; 4. Gitignore
    (vault-silo--gitignore-append (concat "roam/" name))
    ;; 5. Detach from vault index (ignore errors — may not be tracked)
    (vault-silo--git vault-root "rm" "-r" "--cached"
                     "--ignore-unmatch" (concat "roam/" name))
    ;; 6. Optional remote
    (if (string-empty-p remote)
        (message
         (concat "Silo '%s' ready at %s\n"
                 "Run M-x vault-silo-push-remote when you have a remote URL.")
         name silo-dir)
      (vault-silo--git silo-dir "remote" "add" "origin" remote)
      (vault-silo--wire-submodule name remote silo-dir))))

;;;###autoload
(defun vault-silo-push-remote (name remote)
  "Add REMOTE to an existing silo NAME and link it as a vault submodule.

Use this when the silo was created earlier without a remote URL, e.g. once
you've created the repo on the work GitHub and have the SSH/HTTPS URL."
  (interactive
   (let* ((silos (vault-silo--list-silos)))
     (if (null silos)
         (user-error "No silos found under %s" vault-silo-root)
       (let ((n (completing-read "Silo: " silos nil t)))
         (list n (read-string (format "Remote URL for '%s': " n)))))))
  (let ((silo-dir (expand-file-name name vault-silo-root)))
    (unless (file-directory-p silo-dir)
      (user-error "Silo directory not found: %s" silo-dir))
    ;; Add remote only if not already set
    (let ((existing (vault-silo--git silo-dir "remote" "get-url" "origin")))
      (if (car existing)
          (unless (y-or-n-p
                   (format "Remote 'origin' already set to %s — replace? "
                           (cdr existing)))
            (user-error "Aborted"))
        (vault-silo--git silo-dir "remote" "add" "origin" remote)))
    (vault-silo--wire-submodule name remote silo-dir)))

;;;###autoload
(defun vault-silo-list ()
  "Display all silos under roam/ with their remote URLs."
  (interactive)
  (let ((silos (vault-silo--list-silos)))
    (if (null silos)
        (message "No silos found under %s" vault-silo-root)
      (with-current-buffer (get-buffer-create "*vault-silos*")
        (let ((inhibit-read-only t))
          (erase-buffer)
          (insert "Vault Silos\n")
          (insert (make-string 40 ?─) "\n\n")
          (dolist (name silos)
            (let* ((dir    (expand-file-name name vault-silo-root))
                   (result (vault-silo--git dir "remote" "get-url" "origin"))
                   (remote (if (car result) (cdr result) "(no remote yet)"))
                   (log    (vault-silo--git dir "log" "--oneline" "-1"))
                   (head   (if (car log) (cdr log) "no commits")))
              (insert (format "  %-20s  %s\n" name remote))
              (insert (format "  %-20s  last: %s\n\n" "" head))))
          (goto-char (point-min)))
        (display-buffer (current-buffer))))))

(provide 'vault-silos)
;;; vault-silos.el ends here
