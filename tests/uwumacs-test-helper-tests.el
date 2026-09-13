;;; tests/uwumacs-test-helper-tests.el --- Fixtures for the UwUmacs suites -*- lexical-binding: t; -*-
;; Run with -Q --batch, EMACS_DOTS_TEST_PACKAGES,
;;   -l tests/uwumacs-test-helper.el -l this-file -f ert-run-tests-batch-and-exit
;;
;; These tests exercise `tests/uwumacs-test-helper.el' itself: the two documented
;; loader decisions, the file/Git/Org temporary fixtures including their cleanup,
;; and the opt-in Meow state macro.  The state tests are the negative control
;; alignment review F1 requires: `SPC' must already be `meow-keypad' in a
;; genuinely live Normal state before any UwUmacs layer exists, otherwise a later
;; fixture that asserts `SPC f f' runs `find-file' is only proving that a keymap
;; was added to an empty slot.

(require 'ert)
(require 'cl-lib)
(require 'org)
(require 'uwumacs-test-helper)

(defmacro uwumacs-helper-tests-with-buffer (symbol &rest body)
  "Bind SYMBOL to a fresh named Emacs Lisp buffer for BODY, then kill it."
  (declare (indent 1) (debug (symbolp body)))
  `(let ((,symbol (generate-new-buffer "uwumacs-helper-tests")))
     (unwind-protect (with-current-buffer ,symbol (emacs-lisp-mode) ,@body)
       (when (buffer-live-p ,symbol) (kill-buffer ,symbol)))))


;;;; Loader contract

(ert-deftest uwumacs-helper-loads-meow-and-resolves-the-user-load-path ()
  "The helper activates packages, loads Meow and puts the real generated
`lambda-user' directory on `load-path'."
  (should (featurep 'meow))
  (should (file-directory-p uwumacs-test-user-directory))
  (should (cl-some (lambda (entry)
                     (and (stringp entry) (file-directory-p entry)
                          (file-equal-p entry uwumacs-test-user-directory)))
                   load-path))
  (should (locate-library "starter-setup-key-hints")))

(ert-deftest uwumacs-helper-leaves-the-editor-untouched-until-asked ()
  "Loading the helper must not enable Meow globally or load the completion stack.
This is the documented decision; a suite that wants a live leader opts in with
`uwumacs-test-with-meow-state', and a suite that wants Marginalia requires it."
  (should-not (bound-and-true-p meow-global-mode))
  (should-not (boundp 'lem+leader-map))
  (should-not (featurep 'marginalia))
  (uwumacs-helper-tests-with-buffer buffer
    (should (eq (key-binding (kbd "SPC")) 'self-insert-command))))


;;;; Temporary-directory fixtures

(ert-deftest uwumacs-helper-temp-directory-is-removed-after-an-error ()
  "`uwumacs-test-with-temp-directory' cleans up on the error path too."
  (let (root)
    (should-error
     (uwumacs-test-with-temp-directory directory
       (setq root directory)
       (should (file-directory-p root))
       (error "deliberate failure inside the fixture")))
    (should root)
    (should-not (file-exists-p root))))

(ert-deftest uwumacs-helper-file-fixture-is-visited-then-cleaned-up ()
  "The file fixture yields a buffer really visiting a real file, and removes it."
  (let (root path)
    (uwumacs-test-with-file-fixture (directory file buffer)
      (setq root directory path file)
      (should (file-regular-p file))
      (should (buffer-live-p buffer))
      (with-current-buffer buffer
        (should (file-equal-p buffer-file-name file))
        (should (derived-mode-p 'emacs-lisp-mode))
        (should (string-match-p "uwumacs-test-fixture-function" (buffer-string)))))
    (should-not (file-exists-p path))
    (should-not (file-exists-p root))
    (should-not (get-file-buffer path))))

(ert-deftest uwumacs-helper-git-fixture-is-a-repository-to-emacs ()
  "The Git fixture is a repository from Emacs' point of view, and deletes
cleanly despite the read-only object files Git writes under `.git/' on Windows."
  (let (root)
    (uwumacs-test-with-git-fixture (directory file buffer)
      (setq root directory)
      (should (file-directory-p (expand-file-name ".git" directory)))
      (should (eq (vc-backend file) 'Git))
      (with-current-buffer buffer
        (should (eq (vc-backend buffer-file-name) 'Git))
        (should (equal (vc-state file 'Git) 'up-to-date)))
      (should (string-match-p
               "fixture"
               (uwumacs-test--git directory "log" "--oneline" "--no-decorate"))))
    (should-not (file-exists-p root))))

(ert-deftest uwumacs-helper-org-fixture-has-real-org-structure ()
  "The Org fixture parses as Org: two headings and a readable property drawer."
  (let (root)
    (uwumacs-test-with-org-fixture (directory file buffer)
      (setq root directory)
      (with-current-buffer buffer
        (should (derived-mode-p 'org-mode))
        (should (= (length (org-map-entries #'point)) 2))
        (goto-char (point-min))
        (org-next-visible-heading 1)
        (should (equal (org-entry-get (point) "UWUMACS") "fixture"))))
    (should-not (file-exists-p root))))


;;;; Opt-in Meow state

(ert-deftest uwumacs-helper-normal-state-makes-spc-run-meow-keypad ()
  "Negative control for alignment review F1.
In a genuinely live Normal state, before any UwUmacs layer exists, `SPC' is
`meow-keypad'.  The macro must also restore the global mode afterwards."
  (uwumacs-helper-tests-with-buffer buffer
    (should-not (bound-and-true-p meow-global-mode))
    (should (eq (key-binding (kbd "SPC")) 'self-insert-command))
    (uwumacs-test-with-meow-state 'normal
      (should (meow-normal-mode-p))
      (should (eq meow--current-state 'normal))
      (should (eq (key-binding (kbd "SPC")) 'meow-keypad)))
    (should-not (bound-and-true-p meow-global-mode))
    (should (eq (key-binding (kbd "SPC")) 'self-insert-command))))

(ert-deftest uwumacs-helper-insert-state-does-not-reach-the-leader ()
  "The complementary control: Insert state leaves `SPC' self-inserting."
  (uwumacs-helper-tests-with-buffer buffer
    (uwumacs-test-with-meow-state 'insert
      (should (meow-insert-mode-p))
      (should (eq (key-binding (kbd "SPC")) 'self-insert-command))
      (should-not (where-is-internal 'meow-keypad (current-active-maps))))))

(ert-deftest uwumacs-helper-state-fixture-repairs-a-double-activation ()
  "`uwumacs-test-enter-meow-state' recovers from the documented Meow trap.
Re-enabling an already-active state minor mode deactivates its keymap while
`meow--current-state' still reports the state, so a fixture built on
`(meow-normal-mode 1)' would pass while the leader is dead."
  (uwumacs-helper-tests-with-buffer buffer
    (uwumacs-test-with-meow-state 'normal
      (should (eq (key-binding (kbd "SPC")) 'meow-keypad))
      (meow-normal-mode 1)
      (should (eq meow--current-state 'normal))
      (should-not (meow-normal-mode-p))
      (should (eq (key-binding (kbd "SPC")) 'self-insert-command))
      (uwumacs-test-enter-meow-state 'normal)
      (should (meow-normal-mode-p))
      (should (eq (key-binding (kbd "SPC")) 'meow-keypad)))))

(provide 'uwumacs-test-helper-tests)
