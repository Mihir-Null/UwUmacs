;;; tests/uwumacs-runner-tests.el --- Guards for the graphical runner -*- lexical-binding: t; -*-
;; Run with -Q --batch, EMACS_DOTS_TEST_PACKAGES,
;;   -l tests/uwumacs-test-helper.el -l this-file -f ert-run-tests-batch-and-exit
;;
;; Cheap batch guards on the two expensive graphical failure modes:
;;
;; * A diagnostic write that reaches `select-safe-coding-system'.  That function
;;   prompts modally in a graphical session and hangs the run, and this
;;   configuration's *Messages* really does contain non-ASCII.  Both writers are
;;   proved here to encode without consulting it.
;; * A runner that reports PASS with nothing executed.  Discovery is proved to
;;   respect its selector and to be sorted, which is what the expected-count gate
;;   in `tests/gui-run.el' relies on.
;;
;; Loading `tests/gui-run.el' here also proves its arming guard: in batch it must
;; define its functions and start no watchdog.

(require 'ert)
(require 'cl-lib)
(require 'uwumacs-test-helper)

(load (expand-file-name "tests/gui-run.el" uwumacs-test-source-directory) nil t)
(load (expand-file-name "tools/observed-keys.el" uwumacs-test-source-directory) nil t)

(defmacro uwumacs-runner-tests-with-file (symbol &rest body)
  "Bind SYMBOL to a temporary file name for BODY, deleting it afterwards."
  (declare (indent 1) (debug (symbolp body)))
  `(let ((,symbol (make-temp-file "uwumacs-runner-test-")))
     (unwind-protect (progn ,@body)
       (when (file-exists-p ,symbol) (delete-file ,symbol)))))


;;;; Arming

(ert-deftest uwumacs-runner-loading-in-batch-arms-nothing ()
  "`tests/gui-run.el' must define its writer without starting a run."
  (should (featurep 'gui-run))
  (should (fboundp 'dots-gui-execute))
  (should-not (cl-find-if (lambda (timer)
                            (eq (timer--function timer) #'dots-gui--watchdog))
                          timer-list)))


;;;; Diagnostic writes never consult select-safe-coding-system

(ert-deftest uwumacs-runner-progress-log-encodes-without-prompting ()
  "An unbound write of non-ASCII progress would prompt modally and hang the run."
  (uwumacs-runner-tests-with-file file
    (let ((dots-gui-result file)
          (coding-system-for-write 'us-ascii-unix))
      (cl-letf (((symbol-function 'select-safe-coding-system)
                 (lambda (&rest _) (error "Unexpected encoding selection"))))
        (dots-gui--append "  START   %s\n" "λ → 🦄")))
    (with-temp-buffer
      (let ((coding-system-for-read 'utf-8-unix))
        (insert-file-contents file))
      (should (string-match-p "λ → 🦄" (buffer-string))))))

(ert-deftest uwumacs-runner-status-is-published-atomically ()
  "The parent polls for the status file, so it must appear complete or not at all."
  (uwumacs-runner-tests-with-file file
    (let ((dots-gui-status file)
          (dots-gui-counts (list :total 3 :passed 3 :failed 0))
          (coding-system-for-write 'us-ascii-unix))
      (cl-letf (((symbol-function 'select-safe-coding-system)
                 (lambda (&rest _) (error "Unexpected encoding selection"))))
        (dots-gui--publish "PASS"))
      (should-not (file-exists-p (concat file ".tmp")))
      (let ((published (with-temp-buffer
                         (insert-file-contents file)
                         (json-parse-buffer :object-type 'plist))))
        (should (equal (plist-get published :status) "PASS"))
        (should (equal (plist-get published :total) 3))
        (should (equal (plist-get published :passed) 3))))))


;;;; Discovery cannot silently find nothing

(ert-deftest uwumacs-runner-discovery-is-selector-scoped-and-sorted ()
  "A mistyped selector must not look like a green run, so discovery is exact."
  (let ((names '(uwumacs-runner--probe-b uwumacs-runner--probe-a
                 uwumacs-runner--other-c)))
    (unwind-protect
        (progn
          (dolist (name names)
            (ert-set-test name (make-ert-test :name name :body #'ignore)))
          (let ((dots-gui-prefix "^uwumacs-runner--probe-"))
            (should (equal (dots-gui--discover)
                           '(uwumacs-runner--probe-a uwumacs-runner--probe-b))))
          (let ((dots-gui-prefix "^uwumacs-runner--"))
            (should (= (length (dots-gui--discover)) 3))))
      (dolist (name names) (ert-delete-test name)))))

(ert-deftest uwumacs-runner-a-run-that-executed-nothing-is-never-a-pass ()
  "`EMACS_DOTS_GUI_EXPECT' is otherwise consulted only inside the suite runner,
so a suite whose test file is empty, misspelled or absent would skip that gate
entirely and publish a green run in which no test existed."
  (cl-letf (((symbol-function 'dots-gui--preflight) (lambda () nil))
            ((symbol-function 'dots-gui--append) (lambda (&rest _) nil))
            ((symbol-function 'dots-gui--run-suite) (lambda () "PASS"))
            ((symbol-function 'dots-gui--run-audit) (lambda () "PASS")))
    ;; Tests were expected and none could be loaded.
    (let ((dots-gui-tests "") (dots-gui-expect 5) (dots-gui-audit nil))
      (should (equal (dots-gui--run) "ERROR")))
    ;; Nothing was asked for at all, so nothing was proved.
    (dolist (expect '(0 nil))
      (let ((dots-gui-tests "") (dots-gui-expect expect) (dots-gui-audit nil))
        (should (equal (dots-gui--run) "NO-TESTS"))))
    ;; The two shapes that really do execute something stay green.
    (let ((dots-gui-tests "suite.el") (dots-gui-expect 5) (dots-gui-audit nil))
      (should (equal (dots-gui--run) "PASS")))
    (let ((dots-gui-tests "") (dots-gui-expect 0) (dots-gui-audit "observed-keys.json"))
      (should (equal (dots-gui--run) "PASS")))
    ;; A preflight failure still wins over everything else.
    (cl-letf (((symbol-function 'dots-gui--preflight) (lambda () '("no display"))))
      (let ((dots-gui-tests "suite.el") (dots-gui-expect 5) (dots-gui-audit nil))
        (should (equal (dots-gui--run) "ERROR"))))))

(ert-deftest uwumacs-runner-invariant-drift-is-reported ()
  "Cross-test pollution between graphical tests must be named, not absorbed."
  (let ((before (list :frames 1 :meow t :frames-only t)))
    (should-not (dots-gui--invariant-drift before (copy-sequence before)))
    (should (string-match-p
             "frames-only-mode"
             (dots-gui--invariant-drift before (list :frames 1 :meow t :frames-only nil))))
    (should (string-match-p
             "frame count"
             (dots-gui--invariant-drift before (list :frames 2 :meow t :frames-only t))))))


;;;; The observed-key generator

(ert-deftest uwumacs-observed-entries-are-sorted-and-classified ()
  "Keymap order is unstable across builds, and `event-modifiers' mislabels keys.
Uppercase letters and TAB are plain keys; only a modifier prefix in the key
description makes an entry unreachable from Meow's keypad."
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "x") #'ignore)
    (define-key map (kbd "b") #'ignore)
    (define-key map (kbd "C") #'ignore)
    (define-key map (kbd "TAB") #'ignore)
    (define-key map (kbd "!") #'ignore)
    (define-key map (kbd "C-b") #'ignore)
    (let* ((entries (uwumacs-observed-keys--entries map))
           (keys (mapcar (lambda (entry) (plist-get entry :key)) entries)))
      (should (equal keys (sort (copy-sequence keys) #'string<)))
      (should (equal (sort (copy-sequence keys) #'string<)
                     '("!" "C" "C-b" "TAB" "b" "x")))
      (dolist (expected '(("x" . t) ("b" . t) ("C" . t) ("TAB" . t)
                          ("!" . t) ("C-b" . :false)))
        (let ((entry (cl-find (car expected) entries
                              :key (lambda (e) (plist-get e :key)) :test #'equal)))
          (should entry)
          (should (eq (plist-get entry :literal) (cdr expected))))))))

(ert-deftest uwumacs-observed-walk-finds-modified-and-shadowed-leaves ()
  "The leader walk must name both damage classes P05 has to repair: a key no
plain keyboard can type, and a plain key stolen by the C- form the keypad sends
first at depth two or more.  The first key after SPC is literal, so a top-level
plain key is never shadowed."
  (let ((leader (make-sparse-keymap))
        (files (make-sparse-keymap))
        (project (make-sparse-keymap))
        (extended (make-sparse-keymap)))
    (define-key leader (kbd "f") files)
    (define-key files (kbd "f") #'find-file)
    (define-key leader (kbd "p") project)
    (define-key project (kbd "b") #'ignore)
    (define-key project (kbd "C-b") #'ignore-errors)
    (define-key project (kbd "C-x") extended)
    (define-key extended (kbd "s") #'ignore)
    (let* ((walk (uwumacs-observed-keys--walk leader "" 0))
           (damaged (cdr walk)))
      (should (= (car walk) 7))
      (should (equal (mapcar (lambda (entry) (plist-get entry :map_key)) damaged)
                     '("p C-b" "p C-x" "p b")))
      (let ((shadowed (cl-find "p b" damaged
                               :key (lambda (e) (plist-get e :map_key)) :test #'equal)))
        (should (equal (plist-get shadowed :literal) t))
        (should (equal (plist-get shadowed :keypad_resolves_to) "ignore-errors"))
        (should (string-match-p "shadowed" (plist-get shadowed :reason))))
      (let ((modified (cl-find "p C-x" damaged
                               :key (lambda (e) (plist-get e :map_key)) :test #'equal)))
        (should (equal (plist-get modified :literal) :false))
        (should (string-match-p "no keypad prefix" (plist-get modified :reason)))))))

(ert-deftest uwumacs-observed-report-writes-utf8-json-without-prompting ()
  "The audit write must not reach `select-safe-coding-system' either, and the
report must be machine-readable with its capture block attached."
  (uwumacs-runner-tests-with-file file
    (let ((coding-system-for-write 'us-ascii-unix))
      (cl-letf (((symbol-function 'select-safe-coding-system)
                 (lambda (&rest _) (error "Unexpected encoding selection"))))
        (should-not (uwumacs-observed-keys-write file))))
    (let ((report (with-temp-buffer
                    (let ((coding-system-for-read 'utf-8-unix))
                      (insert-file-contents file))
                    (json-parse-buffer :object-type 'plist))))
      (should (equal (plist-get report :schema) uwumacs-observed-keys-schema))
      (should (plist-get report :capture))
      (should (equal (plist-get (plist-get report :emacs) :batch) t))
      ;; Without the configuration loaded these sections must say so rather than
      ;; quietly reporting an empty leader.
      (should (eq (plist-get (plist-get report :leader) :observable) :false))
      (should (equal (plist-get report :errors) [])))))

(provide 'uwumacs-runner-tests)
