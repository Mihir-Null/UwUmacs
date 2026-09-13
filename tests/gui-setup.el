;;; gui-setup.el --- Build an isolated root for graphical tests -*- lexical-binding: t; -*-
;; Run: emacs -Q --batch -l tests/gui-setup.el
;; Prints the isolated root path on its last line; `tools/run-gui-tests.ps1'
;; reads it from there.  Installs nothing.
;;
;; Required environment:
;;   EMACS_DOTS_TEST_PACKAGES  an existing var/elpa to activate, read-only
;; Optional environment:
;;   EMACS_DOTS_SOURCE         repository root (default: this file's parent)
;;   EMACS_DOTS_GUI_SERVER     unique Emacs server name for the test instance
;;
;; What this builds, and why each part is load-bearing:
;;
;; * A WRAPPER early-init.el.  The real `early-init.el' becomes
;;   `early-init-real.el' and is loaded as a payload.  Isolation must arm before
;;   any configuration code runs: an earlier attempt that appended the overrides
;;   to the END of the copied file never reached them and started downloading
;;   packages from the network.
;; * A `package-initialize :before' advice.  The real `early-init.el' recomputes
;;   `package-user-dir' from `user-emacs-directory' AFTER any plain `setq' here
;;   and BEFORE its own `(package-initialize)', so pinning it once is not enough.
;;   Without this advice `package-activated-list' is empty, no module loads, and
;;   the configuration attempts roughly a hundred network installs.
;; * An install blocker that RECORDS as well as signals.  `lem-install-extras'
;;   wraps install failures in `display-warning' and continues, so a bare `error'
;;   is swallowed; `tests/gui-run.el' asserts the recorded list is empty after
;;   startup, which is what makes "zero downloads" checked rather than hopeful.
;; * A local Git repository.  `dots-frames-magit-status-quit' calls
;;   `magit-status' on the configuration root; in an isolated root that is not a
;;   repository, so Magit blocks on its "create repository?" prompt forever.
;;   `git init' plus one commit is a local operation -- no network.
;; * A unique `server-name' and a `server-auth-dir' inside the root.  The
;;   configuration calls `(server-start)' whenever `window-system' is non-nil;
;;   a per-run name makes it structurally impossible for this instance to be
;;   reached as, or to collide with, the user's own Emacs server.
;; * A synthesized `private.el' and `var/etc/custom.el', and `use-dialog-box' /
;;   `use-file-dialog' nil so a blocked prompt stays in the minibuffer, where
;;   timers still run and the watchdog can fire.

(require 'cl-lib)

(defvar dots-gui-source
  (or (getenv "EMACS_DOTS_SOURCE")
      (file-name-directory (directory-file-name (file-name-directory load-file-name)))))

(defvar dots-gui-packages
  (let ((packages (getenv "EMACS_DOTS_TEST_PACKAGES")))
    (unless (and packages (file-directory-p packages))
      (error "Set EMACS_DOTS_TEST_PACKAGES to an existing var/elpa directory"))
    (directory-file-name (expand-file-name packages))))

(defvar dots-gui-server
  ;; `random' is seeded identically in every batch Emacs, so derive the fallback
  ;; from values that really do differ between runs.
  (or (getenv "EMACS_DOTS_GUI_SERVER")
      (format "uwumacs-gui-%d-%s" (emacs-pid) (format-time-string "%s"))))

(defvar dots-gui-root (make-temp-file "emacs-dots-gui-" t))

(defun dots-gui--write (file text)
  "Write TEXT to FILE as UTF-8, never consulting `select-safe-coding-system'."
  (let ((coding-system-for-write 'utf-8-unix))
    (make-directory (file-name-directory file) t)
    (write-region text nil file nil 'silent)))

(defun dots-gui--git (&rest arguments)
  "Run git with ARGUMENTS inside the isolated root, signalling on failure."
  (let ((executable (executable-find "git")))
    (unless executable
      (error "The graphical runner needs git on PATH to prepare its root"))
    (with-temp-buffer
      (let* ((default-directory (file-name-as-directory dots-gui-root))
             (status (apply #'call-process executable nil t nil arguments)))
        (unless (eq status 0)
          (error "git %s failed (%s): %s"
                 (string-join arguments " ") status (buffer-string)))))))

;;;; Copy the configuration

(copy-file (expand-file-name "init.el" dots-gui-source)
           (expand-file-name "init.el" dots-gui-root))
;; The real early-init becomes a payload loaded by the wrapper below.
(copy-file (expand-file-name "early-init.el" dots-gui-source)
           (expand-file-name "early-init-real.el" dots-gui-root))
(dolist (directory '("lambda-library" "literate" "tools" "tests"))
  (copy-directory (expand-file-name directory dots-gui-source)
                  (expand-file-name directory dots-gui-root) nil t))

;;;; Root-local state the configuration expects

(dots-gui--write (expand-file-name "var/etc/custom.el" dots-gui-root) "\n")
(dots-gui--write
 (expand-file-name "lambda-library/lambda-user/private.el" dots-gui-root)
 "(setopt starter-project-directory (expand-file-name \"test-projects/\" user-emacs-directory))\n")
;; Disposable home directory: the parent points HOME/USERPROFILE/APPDATA and the
;; XDG variables here, so anything the session would write into the real profile
;; lands where it can be inspected and deleted.
(make-directory (expand-file-name "home/cache" dots-gui-root) t)

;;;; A local Git repository, so magit-status cannot block on a prompt

(dots-gui--write (expand-file-name ".gitignore" dots-gui-root) "*\n!.gitignore\n")
(dots-gui--git "init" "--quiet")
(dots-gui--git "add" "--" ".gitignore")
(dots-gui--git "-c" "user.name=UwUmacs Test"
               "-c" "user.email=uwumacs-test@invalid"
               "commit" "--quiet" "-m" "graphical test root")

;;;; The wrapper early-init.el

(let ((packages (prin1-to-string dots-gui-packages))
      (gnupg (prin1-to-string (concat dots-gui-packages "/gnupg")))
      (payload (prin1-to-string (expand-file-name "early-init-real.el" dots-gui-root)))
      (server (prin1-to-string dots-gui-server))
      (auth (prin1-to-string (expand-file-name "server/" dots-gui-root))))
  (dots-gui--write
   (expand-file-name "early-init.el" dots-gui-root)
   (concat
    ";;; early-init.el --- isolated graphical test wrapper -*- lexical-binding: t; -*-\n"
    ";; Generated by tests/gui-setup.el.  Arms isolation, then loads the real\n"
    ";; early-init.el as a payload.  Every form here runs before any\n"
    ";; configuration code, which is the whole point of the wrapper.\n"
    "\n"
    "(require 'package)\n"
    "(defvar dots-gui-blocked-installs nil\n"
    "  \"Every package operation this root refused, newest first.\")\n"
    "(defun dots-gui-block-install (&rest args)\n"
    "  \"Record and refuse a package operation.\n"
    "`lem-install-extras' reports install failures with `display-warning' and\n"
    "keeps going, so signalling alone leaves no evidence; the recorded list is\n"
    "asserted empty after startup.\"\n"
    "  (push (format \"%S\" args) dots-gui-blocked-installs)\n"
    "  (error \"Package installation disabled in graphical test root: %S\" args))\n"
    "(dolist (fn '(package-install package-vc-install package-refresh-contents))\n"
    "  (advice-add fn :override #'dots-gui-block-install))\n"
    "\n"
    ";; A modal Windows dialog freezes the event loop and every timer with it.\n"
    "(setq use-dialog-box nil\n"
    "      use-file-dialog nil\n"
    "      inhibit-startup-screen t\n"
    "      confirm-kill-emacs nil\n"
    "      native-comp-jit-compilation nil\n"
    "      native-comp-async-report-warnings-errors nil)\n"
    "\n"
    ";; A per-run server name and a root-local auth directory: this instance can\n"
    ";; neither be reached as, nor collide with, the user's own Emacs server.\n"
    "(setq server-name " server "\n"
    "      server-auth-dir " auth "\n"
    "      server-socket-dir " auth ")\n"
    "(make-directory " auth " t)\n"
    "\n"
    ";; The configuration recomputes `package-user-dir' from\n"
    ";; `user-emacs-directory' during early-init and before its own\n"
    ";; `(package-initialize)', so pin it at every activation instead of once.\n"
    "(advice-add 'package-initialize :before\n"
    "            (lambda (&rest _)\n"
    "              (setq package-user-dir " packages "\n"
    "                    package-gnupghome-dir " gnupg "\n"
    "                    package-archives nil)))\n"
    "(setq package-user-dir " packages "\n"
    "      package-gnupghome-dir " gnupg "\n"
    "      package-archives nil)\n"
    "\n"
    "(load " payload " nil t)\n"
    "\n"
    "(setq package-user-dir " packages "\n"
    "      package-archives nil)\n"
    ";;; early-init.el ends here\n")))

(princ (format "SERVER=%s\n" dots-gui-server))
(princ (format "%s\n" dots-gui-root))
