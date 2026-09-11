;;; tangle-tests.el --- Regression tests for the literate builder -*- lexical-binding: t; -*-
;; emacs -Q --batch -l tests/tangle-tests.el -f ert-run-tests-batch-and-exit
(require 'ert)
(require 'cl-lib)
(defvar dots-literate-library-only t)
(load (expand-file-name "../tools/tangle.el" (file-name-directory load-file-name)) nil t)

(defun dots-tangle-test-write (root relative text)
  (let ((file (expand-file-name relative root)))
    (make-directory (file-name-directory file) t)
    (with-temp-file file (insert text))))

(defmacro dots-tangle-test-fixture (&rest body)
  (declare (indent 0))
  `(let ((root (make-temp-file "dots-tangle-test-" t)))
     (unwind-protect
         (progn
           (dots-tangle-test-write root "literate/manifest.json"
             "{\"sources\":[\"test.org\"],\"outputs\":[\"init.el\"]}")
           (dots-tangle-test-write root "literate/test.org"
             "#+begin_src emacs-lisp :tangle ../init.el :mkdirp yes\n(setq fixture-value 42)\n#+end_src\n")
           ,@body)
       (when (file-in-directory-p root temporary-file-directory)
         (delete-directory root t)))))

(ert-deftest dots-tangle-roundtrip-and-no-op ()
  (dots-tangle-test-fixture
    (should (equal (dots-literate-build root t) '("init.el")))
    (let* ((file (expand-file-name "init.el" root))
           (before (file-attribute-modification-time (file-attributes file))))
      (should-not (dots-literate-build root))
      (should-not (dots-literate-build root t))
      (should (equal before (file-attribute-modification-time (file-attributes file)))))))

(ert-deftest dots-tangle-check-preserves-manual-edit ()
  (dots-tangle-test-fixture
    (dots-literate-build root t)
    (dots-tangle-test-write root "init.el" "(setq fixture-value 'manual)\n")
    (should-error (dots-literate-build root))
    (should (equal (dots-literate--read (expand-file-name "init.el" root))
                   "(setq fixture-value 'manual)\n"))))

(ert-deftest dots-tangle-source-edit-requires-explicit-write ()
  (dots-tangle-test-fixture
    (dots-literate-build root t)
    (dots-tangle-test-write root "literate/test.org"
      "#+begin_src emacs-lisp :tangle ../init.el\n(setq fixture-value 43)\n#+end_src\n")
    (should-error (dots-literate-build root))
    (should (string-match-p "42" (dots-literate--read (expand-file-name "init.el" root))))
    (should (equal (dots-literate-build root t) '("init.el")))
    (should-not (dots-literate-build root))))

(ert-deftest dots-tangle-rejects-private-and-traversal-targets ()
  (dots-tangle-test-fixture
    (dolist (target '("lambda-library/lambda-user/private.el" "../outside.el" "var/etc/custom.el"))
      (dots-tangle-test-write root "literate/manifest.json"
        (json-serialize `(:sources ["test.org"] :outputs [,target])))
      (should-error (dots-literate-build root t)))
    (should-not (file-exists-p (expand-file-name "init.el" root)))))

(ert-deftest dots-tangle-rejects-undeclared-output ()
  (dots-tangle-test-fixture
    (dots-tangle-test-write root "literate/test.org"
      "#+begin_src emacs-lisp :tangle ../early-init.el\n(setq fixture-value 42)\n#+end_src\n")
    (should-error (dots-literate-build root t))
    (should-not (file-exists-p (expand-file-name "early-init.el" root)))))

(ert-deftest dots-tangle-validates-all-files-before-writing ()
  (dots-tangle-test-fixture
    (dots-tangle-test-write root "init.el" "(setq fixture-value 'original)\n")
    (dots-tangle-test-write root "literate/manifest.json"
      "{\"sources\":[\"test.org\"],\"outputs\":[\"init.el\",\"early-init.el\"]}")
    (dots-tangle-test-write root "literate/test.org"
      (concat "#+begin_src emacs-lisp :tangle ../init.el\n(setq fixture-value 'new)\n#+end_src\n"
              "#+begin_src emacs-lisp :tangle ../early-init.el\n(setq broken\n#+end_src\n"))
    (should-error (dots-literate-build root t))
    (should (equal (dots-literate--read (expand-file-name "init.el" root))
                   "(setq fixture-value 'original)\n"))
    (should-not (file-exists-p (expand-file-name "early-init.el" root)))))

(ert-deftest dots-tangle-preserves-fragments-strings-and-does-not-evaluate ()
  (dots-tangle-test-fixture
    (let ((dots-tangle-evaluated nil))
      (dots-tangle-test-write root "literate/test.org"
        (concat "#+PROPERTY: header-args:emacs-lisp :tangle ../init.el :padline no :eval never\n"
                "#+begin_src emacs-lisp\n(setq dots-tangle-evaluated\n#+end_src\n"
                "#+begin_src emacs-lisp\n  \"first\n    second\")\n#+end_src\n"))
      (dots-literate-build root t)
      (should-not dots-tangle-evaluated)
      (should (equal (dots-literate--read (expand-file-name "init.el" root))
                     "(setq dots-tangle-evaluated\n  \"first\n    second\")\n")))))

(ert-deftest dots-tangle-rejects-overlapping-chapter-outputs ()
  (dots-tangle-test-fixture
    (dots-tangle-test-write root "init.el" "(setq fixture-value 'original)\n")
    (dots-tangle-test-write root "literate/manifest.json"
      "{\"sources\":[\"test.org\",\"other.org\"],\"outputs\":[\"init.el\"]}")
    (dots-tangle-test-write root "literate/other.org"
      "#+begin_src emacs-lisp :tangle ../init.el\n(setq other-value 1)\n#+end_src\n")
    (should-error (dots-literate-build root t))
    (should (equal (dots-literate--read (expand-file-name "init.el" root))
                   "(setq fixture-value 'original)\n"))))
