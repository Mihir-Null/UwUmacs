;;; key-hints-tests.el --- Physical Meow hint regressions -*- lexical-binding: t; -*-
;; Run with -Q --batch, EMACS_DOTS_TEST_PACKAGES, -l this-file, -f ert-run-tests-batch-and-exit.
(require 'ert)
(require 'cl-lib)
(require 'package)
(when (getenv "EMACS_DOTS_TEST_PACKAGES")
  (setq package-user-dir (getenv "EMACS_DOTS_TEST_PACKAGES")))
(package-initialize)
(require 'meow)
(require 'marginalia)
(add-to-list 'load-path
             (expand-file-name "../lambda-library/lambda-user"
                               (file-name-directory load-file-name)))
(require 'starter-setup-key-hints nil t)

(defmacro dots-hints-with-leader (&rest body)
  "Run BODY with a small semantic leader map, matching the starter policy."
  (declare (indent 0) (debug t))
  `(let* ((leader (make-sparse-keymap))
          (files (make-sparse-keymap))
          (meow-keymap-alist (list (cons 'leader leader)))
          (meow-keypad-leader-dispatch nil)
          (meow-keypad-start-keys nil)
          (meow-keypad-meta-prefix nil)
          (meow-keypad-ctrl-meta-prefix nil)
          (meow-keypad-literal-prefix nil)
          (meow-normal-mode t)
          (meow-motion-mode nil))
     (define-key leader (kbd "f") files)
     (define-key files (kbd "f") #'find-file)
     ,@body))

(ert-deftest dots-hints-completion-shows-reachable-physical-leader ()
  (dots-hints-with-leader
    (should (fboundp 'starter-meow-command-key))
    (should (equal (starter-meow-command-key 'find-file) "SPC f f"))
    (should (equal (substring-no-properties (marginalia-annotate-binding "find-file"))
                   " (SPC f f)"))))

(ert-deftest dots-hints-control-binding-wins-over-literal-collision ()
  "Meow tries control first; never advertise a shadowed literal binding."
  (dots-hints-with-leader
    (define-key files (kbd "C-f") #'save-buffer)
    (should (fboundp 'starter-meow-command-key))
    (should-not (starter-meow-command-key 'find-file))
    (should (equal (starter-meow-command-key 'save-buffer) "SPC f f"))))

(ert-deftest dots-hints-insert-mode-keeps-native-shortcuts ()
  (dots-hints-with-leader
    (let ((meow-normal-mode nil))
      (should (fboundp 'starter-meow-command-key))
      (should-not (starter-meow-command-key 'find-file))
      (should (string-match-p "C-x C-f" (marginalia-annotate-binding "find-file"))))))

(ert-deftest dots-hints-custom-modifier-policy-does-not-invent-sequences ()
  (dots-hints-with-leader
    (let ((meow-keypad-start-keys '((?f . ?x))))
      (should (fboundp 'starter-meow-command-key))
      (should-not (starter-meow-command-key 'find-file)))))

(ert-deftest dots-hints-prompt-preserves-the-lookup-sequence ()
  (dots-hints-with-leader
    (let ((meow--keypad-keys '((control . "f") (literal . "p")))
          (meow--keypad-help nil)
          (meow--prefix-arg nil))
      (should (fboundp 'starter-meow-keypad-prompt))
      (should (equal (starter-meow-keypad-prompt) "SPC p f"))
      (should (equal (meow--keypad-format-keys) "p C-f")))))

(provide 'key-hints-tests)
