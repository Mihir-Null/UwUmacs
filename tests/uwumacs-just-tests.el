;;; uwumacs-just-tests.el --- Justfile recipe runner -*- lexical-binding: t; -*-
;; Run: EMACS_DOTS_TEST_PACKAGES=/path/to/var/elpa emacs -Q --batch -l tests/uwumacs-just-tests.el -f ert-run-tests-batch-and-exit
;; Loads uwumacs-programming.el with package installation disabled; `just' itself
;; is never run, so these pass on a machine that does not have it.

;;; Code:
(require 'ert)
(require 'cl-lib)
(require 'package)
(when-let* ((directory (getenv "EMACS_DOTS_TEST_PACKAGES")))
  (setq package-user-dir directory))
(package-initialize)
(add-to-list 'load-path
             (expand-file-name "../lisp"
                               (file-name-directory (or load-file-name buffer-file-name))))
(require 'use-package)
;; The runner is the subject; nothing here should reach the package archives.
(setq use-package-ensure-function #'ignore)
(require 'uwumacs-programming)

(defmacro uwumacs-just-test-with-project (&rest body)
  "Run BODY with `default-directory' inside a throwaway project holding a justfile.
The justfile sits at the root; BODY starts one directory below it, so a
test that passes has walked up to find it."
  (declare (indent 0))
  `(let ((root (file-name-as-directory (make-temp-file "uwumacs-just" t))))
     (unwind-protect
         (let ((nested (expand-file-name "src/" root)))
           (write-region "default:\n\techo hi\n" nil (expand-file-name "justfile" root))
           (make-directory nested)
           (let ((default-directory nested)) ,@body))
       (delete-directory root t))))

(defun uwumacs-just-test-parent ()
  "The directory above `default-directory', resolved for comparison."
  (file-name-as-directory (file-truename (expand-file-name ".." default-directory))))

(ert-deftest uwumacs-just-root-walks-up-to-the-justfile ()
  (uwumacs-just-test-with-project
    (should (equal (file-name-as-directory (file-truename (uwumacs-just-root)))
                   (uwumacs-just-test-parent)))))

(ert-deftest uwumacs-just-root-is-nil-without-a-justfile ()
  (let ((default-directory (file-name-as-directory (make-temp-file "uwumacs-nojust" t))))
    (unwind-protect (should-not (uwumacs-just-root))
      (delete-directory default-directory t))))

(ert-deftest uwumacs-just-recipes-splits-the-summary ()
  (uwumacs-just-test-with-project
    (cl-letf (((symbol-function 'call-process)
               (lambda (&rest _) (insert "tangle  check\nbuild switch\n") 0)))
      (should (equal (uwumacs-just-recipes (uwumacs-just-root))
                     '("tangle" "check" "build" "switch"))))))

(ert-deftest uwumacs-just-recipes-survives-a-missing-program ()
  (uwumacs-just-test-with-project
    (cl-letf (((symbol-function 'call-process)
               (lambda (&rest _) (error "No such file or directory"))))
      (should-not (uwumacs-just-recipes (uwumacs-just-root))))
    (cl-letf (((symbol-function 'call-process) (lambda (&rest _) 1)))
      (should-not (uwumacs-just-recipes (uwumacs-just-root))))))

(ert-deftest uwumacs-just-compiles-in-the-justfile-directory ()
  (uwumacs-just-test-with-project
    (let (ran directory)
      (cl-letf (((symbol-function 'compile)
                 (lambda (command &rest _)
                   (setq ran command directory default-directory))))
        (uwumacs-just "build"))
      (should (equal ran "just build"))
      (should (equal (file-name-as-directory (file-truename directory))
                     (uwumacs-just-test-parent))))))

(ert-deftest uwumacs-just-honours-the-program-setting ()
  (uwumacs-just-test-with-project
    (let ((uwumacs-just-program "/usr/bin/just") ran)
      (cl-letf (((symbol-function 'compile) (lambda (command &rest _) (setq ran command))))
        (uwumacs-just "check"))
      (should (equal ran "/usr/bin/just check")))))

(ert-deftest uwumacs-just-uses-a-terminal-when-asked ()
  (uwumacs-just-test-with-project
    (let (terminal-command compiled)
      (cl-letf (((symbol-function 'ghostel-compile)
                 (lambda (command &rest _) (setq terminal-command command)))
                ((symbol-function 'compile)
                 (lambda (command &rest _) (setq compiled command))))
        (uwumacs-just "switch" t))
      (should (equal terminal-command "just switch"))
      (should-not compiled))))

(ert-deftest uwumacs-just-refuses-outside-a-project ()
  (let ((default-directory (file-name-as-directory (make-temp-file "uwumacs-nojust" t))))
    (unwind-protect
        (should-error (uwumacs-just "build") :type 'user-error)
      (delete-directory default-directory t))))

(ert-deftest uwumacs-just-is-on-the-project-prefix-map ()
  (require 'project)
  (should (eq (lookup-key project-prefix-map "j") #'uwumacs-just))
  (should (member '(uwumacs-just "Just recipe") project-switch-commands)))

(provide 'uwumacs-just-tests)
;;; uwumacs-just-tests.el ends here
