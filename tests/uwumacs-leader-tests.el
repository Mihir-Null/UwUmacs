;;; uwumacs-leader-tests.el --- Leader and localleader behaviour -*- lexical-binding: t; -*-
;; Run: EMACS_DOTS_TEST_PACKAGES=/path/to/var/elpa emacs -Q --batch -l tests/uwumacs-leader-tests.el -f ert-run-tests-batch-and-exit
;; Loads only Meow and uwumacs-leader.el; the personal configuration is not loaded.

;;; Code:
(require 'ert)
(require 'package)
(when-let* ((directory (getenv "EMACS_DOTS_TEST_PACKAGES")))
  (setq package-user-dir directory))
(package-initialize)
(add-to-list 'load-path
             (expand-file-name "../lisp"
                               (file-name-directory (or load-file-name buffer-file-name))))
(require 'uwumacs-leader)

(keymap-set uwumacs-leader-map "f f" #'find-file)
(uwumacs-leader-enable)
(meow-global-mode 1)

(defmacro uwumacs-test-with-mode (mode state &rest body)
  "Run BODY in a fresh buffer in MODE after switching Meow to STATE."
  (declare (indent 2))
  `(with-temp-buffer
     (funcall ,mode)
     (meow--switch-state ,state)
     ,@body))

(ert-deftest uwumacs-leader-is-a-prefix-in-normal-and-motion ()
  (uwumacs-test-with-mode #'text-mode 'normal
    (should (meow-normal-mode-p))
    ;; `key-binding' merges every active map's prefix, so check identity on
    ;; Meow's own state map and effect on the merged result.
    (should (eq (keymap-lookup meow-normal-state-keymap "SPC") uwumacs-leader-map))
    (should (keymapp (key-binding (kbd "SPC"))))
    (should (eq (key-binding (kbd "SPC f f")) #'find-file)))
  (uwumacs-test-with-mode #'special-mode 'motion
    (should (meow-motion-mode-p))
    (should (eq (keymap-lookup meow-motion-state-keymap "SPC") uwumacs-leader-map))
    (should (eq (key-binding (kbd "SPC f f")) #'find-file))))

(ert-deftest uwumacs-leader-insert-state-still-inserts-spaces ()
  (uwumacs-test-with-mode #'text-mode 'insert
    (should (eq (key-binding (kbd "SPC")) #'self-insert-command))))

(ert-deftest uwumacs-localleader-composes-along-the-mode-lineage ()
  (let ((uwumacs-localleader-alist nil))
    (uwumacs-define-localleader 'prog-mode "c" #'compile "r" #'recompile)
    (uwumacs-define-localleader 'emacs-lisp-mode "e" #'eval-buffer "c" #'byte-compile-file)
    (uwumacs-test-with-mode #'emacs-lisp-mode 'normal
      (should (eq (key-binding (kbd "SPC m e")) #'eval-buffer))
      (should (eq (key-binding (kbd "SPC m c")) #'byte-compile-file))
      (should (eq (key-binding (kbd "SPC m r")) #'recompile))
      (should (member "SPC m e" (mapcar #'key-description (where-is-internal #'eval-buffer)))))
    (uwumacs-test-with-mode #'text-mode 'normal
      (should-not (key-binding (kbd "SPC m")))
      (should-not uwumacs--localleader-alist))))

(ert-deftest uwumacs-localleader-is-gone-in-insert-state ()
  (let ((uwumacs-localleader-alist nil))
    (uwumacs-define-localleader 'prog-mode "c" #'compile)
    (uwumacs-test-with-mode #'emacs-lisp-mode 'insert
      (should (eq (key-binding (kbd "SPC")) #'self-insert-command)))))

(ert-deftest uwumacs-keypad-is-unbound-unless-requested ()
  (should-not (where-is-internal #'meow-keypad uwumacs-leader-map))
  (let ((uwumacs-keypad-key "K"))
    (unwind-protect
        (progn
          (uwumacs-leader-enable)
          (should (eq (keymap-lookup uwumacs-leader-map "K") #'meow-keypad)))
      (keymap-unset uwumacs-leader-map "K" t)))
  (should-not (where-is-internal #'meow-keypad uwumacs-leader-map)))

(ert-deftest uwumacs-leader-enable-is-idempotent ()
  (let ((entries (seq-count (lambda (entry) (eq entry 'uwumacs--localleader-alist))
                            emulation-mode-map-alists)))
    (uwumacs-leader-enable)
    (should (= entries 1))
    (should (= 1 (seq-count (lambda (entry) (eq entry 'uwumacs--localleader-alist))
                            emulation-mode-map-alists)))))

(provide 'uwumacs-leader-tests)
;;; uwumacs-leader-tests.el ends here
