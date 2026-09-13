;;; gui-run.el --- Execute graphical suites in a dedicated instance -*- lexical-binding: t; -*-
;; Loaded by the graphical Emacs that `tools/run-gui-tests.ps1' starts:
;;   emacs --init-directory=<isolated root> -l <isolated root>/tests/gui-run.el
;;
;; Selector driven and suite agnostic: it runs whatever `EMACS_DOTS_GUI_TESTS'
;; names and `EMACS_DOTS_GUI_SELECTOR' matches, so a new suite needs no change
;; here.  Loading this file in batch arms nothing, which is what lets
;; `tests/uwumacs-runner-tests.el' test its writer without starting a run.
;;
;; Environment:
;;   EMACS_DOTS_GUI_RESULT    append-only human-readable progress log (required)
;;   EMACS_DOTS_GUI_STATUS    JSON status file, published atomically (required)
;;   EMACS_DOTS_GUI_TESTS     ";"-separated ERT files to load
;;   EMACS_DOTS_GUI_SELECTOR  regexp matched against test names
;;   EMACS_DOTS_GUI_EXPECT    how many tests the selector must find
;;   EMACS_DOTS_GUI_BUDGET    in-session watchdog, seconds (default 180)
;;   EMACS_DOTS_GUI_AUDIT     destination for the observed-key report
;;   EMACS_DOTS_GUI_LIBRARY   path to tools/observed-keys.el, for the audit
;;
;; Every write binds `coding-system-for-write'.  This configuration's
;; *Messages* contains a lambda glyph and nerd-font icons; an unbound write
;; calls `select-safe-coding-system', which prompts modally in a graphical
;; session and hangs the run.

(require 'ert)
(require 'cl-lib)

(defvar dots-gui-result (or (getenv "EMACS_DOTS_GUI_RESULT") "gui-result.txt"))
(defvar dots-gui-status (or (getenv "EMACS_DOTS_GUI_STATUS") "gui-status.json"))
(defvar dots-gui-tests (or (getenv "EMACS_DOTS_GUI_TESTS") ""))
(defvar dots-gui-prefix (or (getenv "EMACS_DOTS_GUI_SELECTOR") "^dots-"))
(defvar dots-gui-expect (and (getenv "EMACS_DOTS_GUI_EXPECT")
                             (string-to-number (getenv "EMACS_DOTS_GUI_EXPECT"))))
(defvar dots-gui-budget (string-to-number (or (getenv "EMACS_DOTS_GUI_BUDGET") "180")))
(defvar dots-gui-audit (getenv "EMACS_DOTS_GUI_AUDIT"))
(defvar dots-gui-library (getenv "EMACS_DOTS_GUI_LIBRARY"))
(defvar dots-gui-counts nil
  "Plist of run counters, published in the status file.")

(defun dots-gui--append (fmt &rest args)
  "Append FMT formatted with ARGS to the progress log, as UTF-8.
Appending BEFORE each test is what makes a hang name the test that blocked it."
  (let ((coding-system-for-write 'utf-8-unix))
    (write-region (apply #'format fmt args) nil dots-gui-result t 'silent)))

(defun dots-gui--publish (status)
  "Publish STATUS and the current counters atomically to `dots-gui-status'.
The parent polls for this file, so it must never be readable half-written."
  (let* ((coding-system-for-write 'utf-8-unix)
         (temporary (concat dots-gui-status ".tmp")))
    (with-temp-file temporary
      (insert (json-serialize
               (append (list :status status
                             :emacs emacs-version
                             :graphic (if (display-graphic-p) t :false))
                       dots-gui-counts))))
    (rename-file temporary dots-gui-status t)))

(defun dots-gui--finish (status)
  "Record STATUS, publish it and exit only this process.
Neither write may stop the parent learning the result.  A logging failure that
escaped here would leave this process alive with no status until the parent
deadline, which is the recovery path with the least evidence behind it."
  (ignore-errors (dots-gui--append "EMACS-DOTS-GUI %s\n" status))
  (ignore-errors (dots-gui--publish status))
  (let ((confirm-kill-emacs nil) (kill-emacs-hook nil))
    (kill-emacs (if (equal status "PASS") 0 1))))

(defun dots-gui--preflight ()
  "Return a list of reasons this root is not a faithful graphical session."
  (let (failures)
    (unless (display-graphic-p) (push "Not a graphical display" failures))
    (when (bound-and-true-p dots-gui-blocked-installs)
      (push (format "Package operations were attempted: %S" dots-gui-blocked-installs)
            failures))
    (let ((shared (getenv "EMACS_DOTS_TEST_PACKAGES")))
      (unless (and shared (file-directory-p package-user-dir)
                   (file-equal-p package-user-dir shared))
        (push (format "package-user-dir is %S, expected %S" package-user-dir shared)
              failures)))
    (when (null package-activated-list)
      (push "No packages were activated" failures))
    (let ((local (expand-file-name "var/elpa/" user-emacs-directory)))
      (when (and (file-directory-p local)
                 (directory-files local nil directory-files-no-dot-files-regexp t))
        (push (format "Packages were written into the isolated root %S" local) failures)))
    (unless (bound-and-true-p meow-global-mode)
      (push "meow-global-mode is off: the editor did not finish loading" failures))
    (unless (bound-and-true-p which-key-mode)
      (push "which-key-mode is off: the editor did not finish loading" failures))
    (nreverse failures)))

(defun dots-gui--invariants ()
  "Return the cross-test invariants as a plist snapshot."
  (list :frames (length (frame-list))
        :meow (and (bound-and-true-p meow-global-mode) t)
        :frames-only (and (bound-and-true-p frames-only-mode) t)))

(defun dots-gui--invariant-drift (before after)
  "Describe how the invariant snapshot AFTER differs from BEFORE, or nil."
  (let (drift)
    (cl-loop for (key label) in '((:frames "frame count")
                                  (:meow "meow-global-mode")
                                  (:frames-only "frames-only-mode"))
             unless (equal (plist-get before key) (plist-get after key))
             do (push (format "%s %S -> %S" label
                              (plist-get before key) (plist-get after key))
                      drift))
    (and drift (string-join (nreverse drift) ", "))))

(defun dots-gui--discover ()
  "Return the ERT tests matching `dots-gui-prefix', sorted by name."
  (sort (let (acc)
          (mapatoms (lambda (symbol)
                      (when (and (ert-test-boundp symbol)
                                 (string-match-p dots-gui-prefix (symbol-name symbol)))
                        (push symbol acc))))
          acc)
        (lambda (a b) (string< (symbol-name a) (symbol-name b)))))

(defun dots-gui--run-suite ()
  "Load and run the requested suite.  Return a status string."
  (dolist (file (split-string dots-gui-tests ";" t)) (load file nil t))
  (let ((names (dots-gui--discover))
        (baseline (dots-gui--invariants))
        (passed 0) (failed 0) (skipped 0) (violations 0))
    (dots-gui--append "discovered=%d expected=%s\n" (length names)
                      (or dots-gui-expect "any"))
    (if (and dots-gui-expect (/= (length names) dots-gui-expect))
        (progn
          (setq dots-gui-counts (list :total (length names) :expected dots-gui-expect))
          "UNEXPECTED-COUNT")
      (dolist (name names)
        (dots-gui--append "  START   %s\n" name)
        (let ((result (ert-run-test (ert-get-test name))))
          (cond
           ((ert-test-skipped-p result)
            (setq skipped (1+ skipped)) (dots-gui--append "  SKIPPED %s\n" name))
           ((ert-test-passed-p result)
            (setq passed (1+ passed)) (dots-gui--append "  passed  %s\n" name))
           (t (setq failed (1+ failed))
              (dots-gui--append "  FAILED  %s\n    %s\n" name
                                (condition-case nil
                                    (ert-test-result-with-condition-condition result)
                                  (error "no condition recorded"))))))
        (let ((drift (condition-case err
                         (dots-gui--invariant-drift baseline (dots-gui--invariants))
                       (error (format "invariant check errored: %S" err)))))
          (when drift
            (setq violations (1+ violations))
            (dots-gui--append "  INVARIANT %s after %s\n" drift name)
            (setq baseline (dots-gui--invariants)))))
      (dots-gui--append "total=%d passed=%d failed=%d skipped=%d invariant-violations=%d\n"
                        (length names) passed failed skipped violations)
      (setq dots-gui-counts (list :total (length names) :passed passed :failed failed
                                  :skipped skipped :violations violations
                                  :expected (or dots-gui-expect (length names))))
      (cond ((> failed 0) "FAIL")
            ((> skipped 0) "INCOMPLETE-SKIPPED")
            ((> violations 0) "INVARIANT-VIOLATION")
            ((= (length names) 0) "NO-TESTS")
            (t "PASS")))))

(defun dots-gui--run-audit ()
  "Write the observed-key report.  Return a status string."
  (unless (and dots-gui-library (file-readable-p dots-gui-library))
    (error "EMACS_DOTS_GUI_LIBRARY does not name a readable file: %S" dots-gui-library))
  (load dots-gui-library nil t)
  (let ((errors (uwumacs-observed-keys-write dots-gui-audit)))
    (dots-gui--append "audit=%s errors=%d\n" dots-gui-audit (length errors))
    (dolist (message errors) (dots-gui--append "  AUDIT-ERROR %s\n" message))
    (if errors "FAIL" "PASS")))

(defun dots-gui--run ()
  "Run the preflight and whatever work this invocation was configured to do.
Return the status string; the caller publishes it and exits.

A run that executed nothing is never a pass.  `EMACS_DOTS_GUI_EXPECT' is
otherwise consulted only inside `dots-gui--run-suite', so a suite whose test
file is empty, misspelled or absent would skip that gate completely and leave
the status at its initial value -- a green run in which no test existed."
  (let ((failures (dots-gui--preflight))
        (executed nil)
        (status "PASS"))
    (dolist (failure failures) (dots-gui--append "  PREFLIGHT %s\n" failure))
    (when failures (setq status "ERROR"))
    (when (and (equal status "PASS")
               dots-gui-expect (> dots-gui-expect 0)
               (string-empty-p dots-gui-tests))
      (dots-gui--append "  ERROR %d tests expected but EMACS_DOTS_GUI_TESTS is empty\n"
                        dots-gui-expect)
      (setq dots-gui-counts (list :total 0 :expected dots-gui-expect))
      (setq status "ERROR"))
    (when (and (equal status "PASS") (not (string-empty-p dots-gui-tests)))
      (setq executed t status (dots-gui--run-suite)))
    (when (and (equal status "PASS") dots-gui-audit)
      (setq executed t status (dots-gui--run-audit)))
    (if (and (equal status "PASS") (not executed)) "NO-TESTS" status)))

(defun dots-gui-execute ()
  "Run this invocation's work, publish the result and exit only this process."
  (ignore-errors
    (dots-gui--append "emacs=%s graphic=%S frames=%d pkgs=%d home=%S\n"
                      emacs-version (display-graphic-p) (length (frame-list))
                      (length package-activated-list) (getenv "HOME")))
  (dots-gui--finish
   (condition-case err
       (dots-gui--run)
     (error (ignore-errors
              (dots-gui--append "ERROR %s\n" (error-message-string err)))
            "ERROR"))))

(defun dots-gui--watchdog ()
  "Give up on a blocked run.  Only rescues cases where timers still run."
  (dots-gui--append "WATCHDOG fired after %ss\n" dots-gui-budget)
  (dots-gui--finish "TIMEOUT"))

;; Arm only in a real session.  Loading this file in batch defines the writer
;; and the helpers so they can be tested, and starts nothing.
(unless noninteractive
  (run-with-timer dots-gui-budget nil #'dots-gui--watchdog)
  (add-hook 'emacs-startup-hook
            (lambda () (run-with-idle-timer 3 nil #'dots-gui-execute))))

(provide 'gui-run)
