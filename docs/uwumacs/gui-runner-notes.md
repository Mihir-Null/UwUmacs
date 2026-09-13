# Graphical test runner — prototype and findings

Preserved 2026-09-13 from the Phase 1 review session, before scratch cleanup. This is **unreviewed
prototype material**, not a committed runner and not evidence of a passing graphical suite. It exists so P00
does not have to rediscover the hazards below. See [alignment review](../ADRs/alignment-review.md) finding F2.

## Why this is needed

`tests/frames-tests.el` (5 tests) and `tests/key-hints-gui-tests.el` (3 tests) are all gated on
`(skip-unless (display-graphic-p))`. In batch every one of them skips, and `tools/` contains only
`tangle.el` — no graphical runner is committed anywhere in the repository. The graphical baseline therefore
has no reproducible evidence, and plan P00 explicitly requires "repeatable fixtures/runners rather than
depending on old machine-local audit scripts".

## Hazards established by experiment

Each of these cost a failed run; they are the substance of this note.

1. **A modal dialog freezes every timer.** On Windows a modal dialog blocks the Emacs event loop entirely, so
   a watchdog timer cannot rescue a blocked run — the watchdog never fires. Set `use-dialog-box` and
   `use-file-dialog` to nil in the test root, keep the watchdog anyway, and write **per-test progress** so a
   block names the test that caused it. Observed symptom: process alive, CPU flat (0.04s over 20s), constant
   working set, zero output.

2. **Isolation must arm before any configuration code runs.** A first attempt appended the package-directory
   override and the install blocker to the *end* of the copied `early-init.el`. That code was never reached,
   the blocker never armed, and the session began **downloading packages from the network** into the temp
   root (29 entries including `archives/`). A wrapper `early-init.el` that arms the override first and then
   loads the real file as a payload prevents this — verified 0 downloads afterwards.

3. **`--init-directory` does not reproduce `verify-config.el`'s startup.** Even with the wrapper and zero
   downloads, an `--init-directory` start left `meow` and `which-key` unloaded (`package-alist` empty).
   `early-init.el:404` does call `(package-initialize)` explicitly, so a `:before` advice there is the right
   pin point, but the last observed run still did not activate packages. **This is the open problem P00 must
   finish.** `tests/verify-config.el` succeeds because it sets `user-emacs-directory` itself and then loads
   `early-init.el` and `init.el` directly — consider driving the GUI session the same way (load the config
   explicitly inside a graphical Emacs) instead of relying on `--init-directory`.

4. **The runner pattern itself is sound.** Under `emacs -Q` the prototype detects the display, discovers ERT
   tests by prefix, runs them, writes a UTF-8 result and exits only its own process:

   ```
   emacs=31.1 graphic=t frames=1
   discovered=1
     START   dots-frames-smoke-harness
     passed  dots-frames-smoke-harness
   total=1 passed=1 failed=0 skipped=0
   EMACS-DOTS-GUI PASS
   ```

## Safety rules observed

No user Emacs process was running at any point during this work. Every instance started was stopped, all
temporary roots were removed, and afterwards the real `var/elpa` (145 packages) and the working tree were
verified unchanged. A committed runner must keep these properties: never terminate user-owned Emacs
processes, never write to the real `var/`, and never install or refresh packages.

## Prototype: isolated-root builder

Intended location `tests/gui-setup.el`. Prints the root path on its last line.

```elisp
;;; gui-setup.el --- Build an isolated root for graphical tests -*- lexical-binding: t; -*-
;; Run: emacs -Q --batch -l tests/gui-setup.el
;; Prints the isolated root path on the last line. Installs nothing: the
;; generated early-init.el arms the package override BEFORE the real one runs.
(require 'cl-lib)
(defvar dots-gui-source
  (or (getenv "EMACS_DOTS_SOURCE")
      (file-name-directory (directory-file-name (file-name-directory load-file-name)))))
(defvar dots-gui-root (make-temp-file "emacs-dots-gui-" t))
(defvar dots-gui-packages
  (let ((packages (getenv "EMACS_DOTS_TEST_PACKAGES")))
    (unless (and packages (file-directory-p packages))
      (error "Set EMACS_DOTS_TEST_PACKAGES to an existing var/elpa directory"))
    (directory-file-name (expand-file-name packages))))

(copy-file (expand-file-name "init.el" dots-gui-source)
           (expand-file-name "init.el" dots-gui-root))
;; The real early-init becomes a payload loaded by the wrapper below.
(copy-file (expand-file-name "early-init.el" dots-gui-source)
           (expand-file-name "early-init-real.el" dots-gui-root))
(dolist (directory '("lambda-library" "literate" "tools"))
  (copy-directory (expand-file-name directory dots-gui-source)
                  (expand-file-name directory dots-gui-root) nil t))
(make-directory (expand-file-name "var/etc" dots-gui-root) t)
(with-temp-file (expand-file-name "var/etc/custom.el" dots-gui-root) (insert "\n"))
(with-temp-file (expand-file-name "lambda-library/lambda-user/private.el" dots-gui-root)
  (insert "(setopt starter-project-directory (expand-file-name \"test-projects/\" user-emacs-directory))\n"))

(with-temp-file (expand-file-name "early-init.el" dots-gui-root)
  (insert ";;; early-init.el --- isolated graphical test wrapper -*- lexical-binding: t; -*-\n")
  (dolist (form
           `((dolist (fn '(package-install package-vc-install package-refresh-contents))
               (advice-add fn :override
                           (lambda (&rest args)
                             (error "Package installation disabled in graphical test root: %S" args))))
             ;; A modal dialog freezes the event loop and every timer with it.
             (setq use-dialog-box nil
                   use-file-dialog nil
                   inhibit-startup-screen t
                   native-comp-jit-compilation nil
                   native-comp-async-report-warnings-errors nil)
             ;; The config recomputes package-user-dir from user-emacs-directory
             ;; during init, so pin it at every package-initialize instead of once.
             (advice-add 'package-initialize :before
                         (lambda (&rest _)
                           (setq package-user-dir ,dots-gui-packages
                                 package-gnupghome-dir ,(concat dots-gui-packages "/gnupg")
                                 package-archives nil)))
             (setq package-user-dir ,dots-gui-packages
                   package-gnupghome-dir ,(concat dots-gui-packages "/gnupg")
                   package-archives nil)
             (load ,(expand-file-name "early-init-real.el" dots-gui-root) nil t)
             (setq package-user-dir ,dots-gui-packages
                   package-archives nil)))
    (insert (prin1-to-string form) "\n")))
(princ (format "%s\n" dots-gui-root))
```

## Prototype: in-session executor

Intended location `tests/gui-run.el`. Loaded by the graphical Emacs.

```elisp
;;; gui-run.el --- Execute graphical suites in a dedicated instance -*- lexical-binding: t; -*-
;; Appends UTF-8 progress so a hang names the test that blocked, then exits.
(require 'ert)
(defvar dots-gui-result (or (getenv "EMACS_DOTS_GUI_RESULT") "gui-result.txt"))
(defvar dots-gui-tests (or (getenv "EMACS_DOTS_GUI_TESTS") ""))
(defvar dots-gui-prefix (or (getenv "EMACS_DOTS_GUI_SELECTOR") "^dots-"))
(defvar dots-gui-budget (string-to-number (or (getenv "EMACS_DOTS_GUI_BUDGET") "120")))

(defun dots-gui--append (fmt &rest args)
  (let ((coding-system-for-write 'utf-8-unix))
    (write-region (apply #'format fmt args) nil dots-gui-result t 'silent)))

(defun dots-gui--finish (status)
  (dots-gui--append "EMACS-DOTS-GUI %s\n" status)
  (let ((confirm-kill-emacs nil) (kill-emacs-hook nil))
    (kill-emacs (if (equal status "PASS") 0 1))))

(defun dots-gui-execute ()
  (dots-gui--append "emacs=%s graphic=%S frames=%d\n"
                    emacs-version (display-graphic-p) (length (frame-list)))
  (condition-case err
      (progn
        (unless (display-graphic-p) (error "Not a graphical display"))
        (dolist (file (split-string dots-gui-tests ";" t)) (load file nil t))
        (let ((names (sort (let (acc)
                             (mapatoms (lambda (s)
                                         (when (and (ert-test-boundp s)
                                                    (string-match-p dots-gui-prefix (symbol-name s)))
                                           (push s acc))))
                             acc)
                           (lambda (a b) (string< (symbol-name a) (symbol-name b)))))
              (passed 0) (failed 0) (skipped 0))
          (dots-gui--append "discovered=%d\n" (length names))
          (dolist (name names)
            (dots-gui--append "  START   %s\n" name)
            (let ((result (ert-run-test (ert-get-test name))))
              (cond
               ((ert-test-skipped-p result)
                (setq skipped (1+ skipped)) (dots-gui--append "  SKIPPED %s\n" name))
               ((ert-test-passed-p result)
                (setq passed (1+ passed)) (dots-gui--append "  passed  %s\n" name))
               (t (setq failed (1+ failed))
                  (dots-gui--append "  FAILED  %s\n" name)))))
          (dots-gui--append "total=%d passed=%d failed=%d skipped=%d\n"
                            (length names) passed failed skipped)
          (dots-gui--finish (cond ((> failed 0) "FAIL")
                                  ((> skipped 0) "INCOMPLETE-SKIPPED")
                                  ((= (length names) 0) "NO-TESTS")
                                  (t "PASS")))))
    (error (dots-gui--append "ERROR %s\n" (error-message-string err))
           (dots-gui--finish "ERROR"))))

;; Hard watchdog: a blocked prompt must not hang the run forever.
(run-with-timer dots-gui-budget nil
                (lambda ()
                  (dots-gui--append "WATCHDOG fired after %ss\n" dots-gui-budget)
                  (dots-gui--finish "TIMEOUT")))
(add-hook 'emacs-startup-hook
          (lambda () (run-with-idle-timer 3 nil #'dots-gui-execute)))
```

## Invocation used

```powershell
$env:EMACS_DOTS_TEST_PACKAGES = 'C:/Users/walnu/.config/emacs-dots/var/elpa'
$root = & $uwuEmacs -Q --batch -l tests/gui-setup.el | Select-Object -Last 1
$env:EMACS_DOTS_GUI_RESULT   = 'gui-result.txt'
$env:EMACS_DOTS_GUI_TESTS    = 'C:/Users/walnu/.config/emacs-dots/tests/frames-tests.el'
$env:EMACS_DOTS_GUI_SELECTOR = '^dots-frames-'
& $uwuEmacs --init-directory=$root -l tests/gui-run.el
```

## Definition of done for P00

A committed runner that reports **5/5 frame tests and 3/3 graphical hint tests executed with zero skips**, on
an ordinary graphical startup, exiting only its own process and leaving the user's `var/` untouched. Anything
less is recorded as a capability limitation, not as a pass.
