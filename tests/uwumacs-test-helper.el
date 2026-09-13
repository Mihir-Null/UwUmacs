;;; tests/uwumacs-test-helper.el -*- lexical-binding: t; -*-

;; Shared loader and temporary-directory fixtures for the UwUmacs suites.
;;
;; Usage (batch):
;;   $env:EMACS_DOTS_TEST_PACKAGES = '<repo>/var/elpa'
;;   emacs -Q --batch -l tests/uwumacs-test-helper.el -l tests/<file>.el \
;;         -f ert-run-tests-batch-and-exit
;;
;; Each test file explicitly requires the core/adapter it exercises AFTER this
;; helper.  Tests must save and restore any global Meow/UwUmacs state and user
;; maps they change, with `unwind-protect'.
;;
;; Two deliberate decisions, both asserted by `tests/uwumacs-test-helper-tests.el'
;; so that changing one breaks a test here rather than a downstream suite:
;;
;; * `meow-global-mode' is NOT enabled at load time.  After loading this helper
;;   `meow-global-mode' is nil, `(key-binding (kbd "SPC"))' is
;;   `self-insert-command' and `lem+leader-map' is unbound.  A suite that needs
;;   a genuinely live Meow state opts in with `uwumacs-test-with-meow-state'.
;; * `marginalia' is NOT required here.  `tests/key-hints-tests.el' requires it
;;   itself because it asserts on `marginalia-annotate-binding'; the helper
;;   stays minimal so a suite that does not need the completion stack does not
;;   load it.
;;
;; Fixture cleanup policy: every fixture macro deletes its temporary directory
;; on both the normal and the error exit path.  (`tests/verify-config.el' keeps
;; its root; that behaviour is unchanged by this file and is recorded as a
;; deferred observation.)

(require 'ert)
(require 'cl-lib)
(require 'package)
(when-let* ((directory (getenv "EMACS_DOTS_TEST_PACKAGES")))
  (setq package-user-dir directory))
(package-initialize)
(add-to-list 'load-path
             (expand-file-name "../lambda-library/lambda-user"
                               (file-name-directory load-file-name)))
(require 'meow)

(defconst uwumacs-test-directory
  (file-name-as-directory (file-name-directory load-file-name))
  "Absolute path of the directory holding this helper (the repository `tests/').")

(defconst uwumacs-test-source-directory
  (file-name-as-directory
   (file-name-directory (directory-file-name uwumacs-test-directory)))
  "Absolute path of the repository root that owns this helper.")

(defconst uwumacs-test-user-directory
  (file-name-as-directory
   (expand-file-name "lambda-library/lambda-user" uwumacs-test-source-directory))
  "Absolute path of the generated user Lisp directory added to `load-path'.")


;;;; Temporary-directory fixtures

(defun uwumacs-test-delete-directory (directory)
  "Delete DIRECTORY and everything under it.
Windows marks the object files Git writes under `.git/' read-only, so clear
every file mode before recursing; a bare `delete-directory' can otherwise fail
on a `git init'-ed fixture root."
  (when (and directory (file-directory-p directory))
    (dolist (file (directory-files-recursively directory "" t))
      (ignore-errors (set-file-modes file #o700)))
    (delete-directory directory t)))

(defun uwumacs-test-make-temp-directory (&optional prefix)
  "Create and return a new temporary directory named with PREFIX."
  (file-name-as-directory (make-temp-file (or prefix "uwumacs-test-") t)))

(defmacro uwumacs-test-with-temp-directory (symbol &rest body)
  "Bind SYMBOL to a fresh temporary directory, run BODY, then delete it."
  (declare (indent 1) (debug (symbolp body)))
  `(let ((,symbol (uwumacs-test-make-temp-directory)))
     (unwind-protect (progn ,@body)
       (uwumacs-test-delete-directory ,symbol))))

(defun uwumacs-test--write (file text)
  "Write TEXT to FILE as UTF-8 without consulting `select-safe-coding-system'."
  (let ((coding-system-for-write 'utf-8-unix))
    (write-region text nil file nil 'silent)))

(defun uwumacs-test--visit (file)
  "Visit FILE in a fresh buffer without running configuration hooks."
  (let ((find-file-hook nil)
        (prog-mode-hook nil)
        (text-mode-hook nil)
        (org-mode-hook nil)
        (emacs-lisp-mode-hook nil))
    (find-file-noselect file)))

(defun uwumacs-test--release (buffer)
  "Kill BUFFER without offering to save it."
  (when (buffer-live-p buffer)
    (with-current-buffer buffer (set-buffer-modified-p nil))
    (kill-buffer buffer)))

(defmacro uwumacs-test-with-file-fixture (spec &rest body)
  "Run BODY over a visited temporary Emacs Lisp file.
SPEC is (DIRECTORY FILE BUFFER): DIRECTORY is the fixture root, FILE the
absolute file name, BUFFER the buffer visiting it.  BUFFER is killed and
DIRECTORY deleted on every exit path."
  (declare (indent 1) (debug (sexp body)))
  (let ((directory (nth 0 spec)) (file (nth 1 spec)) (buffer (nth 2 spec)))
    `(uwumacs-test-with-temp-directory ,directory
       (let ((,file (expand-file-name "fixture.el" ,directory))
             (,buffer nil))
         (uwumacs-test--write
          ,file (concat ";;; fixture.el -*- lexical-binding: t; -*-\n"
                        "(defun uwumacs-test-fixture-function () 'fixture)\n"))
         (unwind-protect
             (progn (setq ,buffer (uwumacs-test--visit ,file)) ,@body)
           (uwumacs-test--release ,buffer))))))

(defun uwumacs-test--git (directory &rest arguments)
  "Run git with ARGUMENTS in DIRECTORY, signalling on a non-zero exit.
A missing git executable is an error, never a skip: an unexecuted fixture is a
capability limitation that must be reported, not a passing test."
  (let ((executable (executable-find "git")))
    (unless executable
      (error "UwUmacs test fixtures require git on PATH; none found"))
    (with-temp-buffer
      (let* ((default-directory (file-name-as-directory directory))
             (status (apply #'call-process executable nil t nil arguments)))
        (unless (eq status 0)
          (error "git %s failed (%s): %s"
                 (string-join arguments " ") status (buffer-string)))
        (buffer-string)))))

(defmacro uwumacs-test-with-git-fixture (spec &rest body)
  "Run BODY over a real Git working tree holding one committed file.
SPEC is (DIRECTORY FILE BUFFER) as for `uwumacs-test-with-file-fixture'.  The
repository ignores everything except the fixture files so status queries stay
cheap, and commits with an explicit identity so it does not depend on the
developer's global Git configuration."
  (declare (indent 1) (debug (sexp body)))
  (let ((directory (nth 0 spec)) (file (nth 1 spec)) (buffer (nth 2 spec)))
    `(uwumacs-test-with-temp-directory ,directory
       (let ((,file (expand-file-name "tracked.el" ,directory))
             (,buffer nil))
         (uwumacs-test--write
          ,file (concat ";;; tracked.el -*- lexical-binding: t; -*-\n"
                        "(defun uwumacs-test-tracked-function () 'tracked)\n"))
         (uwumacs-test--write (expand-file-name ".gitignore" ,directory)
                              "*\n!.gitignore\n!tracked.el\n")
         (uwumacs-test--git ,directory "init" "--quiet")
         (uwumacs-test--git ,directory "add" "--" ".gitignore" "tracked.el")
         (uwumacs-test--git ,directory
                            "-c" "user.name=UwUmacs Test"
                            "-c" "user.email=uwumacs-test@invalid"
                            "commit" "--quiet" "-m" "fixture")
         (unwind-protect
             (progn (setq ,buffer (uwumacs-test--visit ,file)) ,@body)
           (uwumacs-test--release ,buffer))))))

(defmacro uwumacs-test-with-org-fixture (spec &rest body)
  "Run BODY over a visited temporary Org file with two headings and a source block.
SPEC is (DIRECTORY FILE BUFFER) as for `uwumacs-test-with-file-fixture'."
  (declare (indent 1) (debug (sexp body)))
  (let ((directory (nth 0 spec)) (file (nth 1 spec)) (buffer (nth 2 spec)))
    `(uwumacs-test-with-temp-directory ,directory
       (let ((,file (expand-file-name "fixture.org" ,directory))
             (,buffer nil))
         (uwumacs-test--write
          ,file (concat "#+title: UwUmacs fixture\n"
                        "\n"
                        "* First heading\n"
                        ":PROPERTIES:\n"
                        ":UWUMACS: fixture\n"
                        ":END:\n"
                        "Body text.\n"
                        "\n"
                        "* Second heading\n"
                        "#+begin_src emacs-lisp :tangle no\n"
                        "(ignore 'fixture)\n"
                        "#+end_src\n"))
         (unwind-protect
             (progn (setq ,buffer (uwumacs-test--visit ,file)) ,@body)
           (uwumacs-test--release ,buffer))))))


;;;; Opt-in Meow state

(defun uwumacs-test-meow-state-live-p (state)
  "Return non-nil when STATE's Meow minor mode is genuinely active here."
  (funcall (intern (format "meow-%s-mode-p" state))))

(defun uwumacs-test-enter-meow-state (state)
  "Enter Meow STATE in the current buffer and assert its keymap is live.

Two observed Meow behaviours make the obvious idioms unsafe.  Calling
`(meow-normal-mode 1)' in an already-normal buffer runs
`meow--disable-current-state', which leaves the mode variable nil while
`meow--current-state' still says `normal'; `SPC' then falls through to
`self-insert-command'.  And `meow--switch-state' short-circuits when the
requested state is already `meow--current-state', so it cannot repair that.
Switching through a different state first makes the transition unconditional."
  (unless (bound-and-true-p meow-mode) (meow-mode 1))
  (let ((via (if (eq state 'insert) 'motion 'insert)))
    (meow--switch-state via)
    (meow--switch-state state))
  (unless (uwumacs-test-meow-state-live-p state)
    (error "Could not enter Meow %s state in %s" state (buffer-name)))
  state)

(defmacro uwumacs-test-with-meow-state (state &rest body)
  "Run BODY with Meow STATE genuinely active in the current buffer.

Enables `meow-global-mode' when it is off, enters STATE through
`uwumacs-test-enter-meow-state' (which asserts the state minor mode is live),
and restores the previous global mode and buffer state on every exit path.

The global mode is restored in BOTH directions.  Restoring it only when the
macro turned it on would let a body that disables it leave the editor dead for
every later test in the same process."
  (declare (indent 1) (debug (sexp body)))
  `(let ((uwumacs-test--global (bound-and-true-p meow-global-mode))
         (uwumacs-test--state (bound-and-true-p meow--current-state))
         (uwumacs-test--buffer (current-buffer)))
     (unwind-protect
         (progn
           (unless uwumacs-test--global (meow-global-mode 1))
           (uwumacs-test-enter-meow-state ,state)
           ,@body)
       (if uwumacs-test--global
           (progn
             (unless (bound-and-true-p meow-global-mode) (meow-global-mode 1))
             (when (and uwumacs-test--state (buffer-live-p uwumacs-test--buffer))
               (with-current-buffer uwumacs-test--buffer
                 (uwumacs-test-enter-meow-state uwumacs-test--state))))
         (when (bound-and-true-p meow-global-mode) (meow-global-mode -1))))))

(provide 'uwumacs-test-helper)
