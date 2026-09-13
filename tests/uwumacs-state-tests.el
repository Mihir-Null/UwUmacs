;;; uwumacs-state-tests.el --- Native activation acceptance -*- lexical-binding: t; -*-
(require 'uwumacs-test-helper)
(require 'uwumacs)

(defmacro uwumacs-state-test-with-mode (&rest body)
  (declare (indent 0))
  `(let ((uwumacs-user-leader-map (make-sparse-keymap))
         (uwumacs-user-state-maps nil)
         (uwumacs-map-context-function nil))
     (should (fboundp 'uwumacs-mode))
     (unwind-protect (progn (uwumacs-mode 1) ,@body)
       (uwumacs-mode -1))))

(ert-deftest uwumacs-state-native-normal-motion-and-insert ()
  (with-temp-buffer
    (uwumacs-test-with-meow-state 'normal
      (should (eq (key-binding (kbd "SPC")) 'meow-keypad))
      (uwumacs-state-test-with-mode
        (dolist (state '(normal motion))
          (uwumacs-test-enter-meow-state state)
          (should (keymapp (key-binding (kbd "SPC"))))
          (should (eq (key-binding (kbd "SPC f f")) 'find-file)))
        (uwumacs-test-enter-meow-state 'insert)
        (should (eq (key-binding (kbd "SPC")) 'self-insert-command))
        (let ((last-command-event ?\s)) (self-insert-command 1))
        (should (equal (buffer-string) " "))
        (should (eq (key-binding (kbd "C-c C-SPC f f")) 'find-file))
        (meow-mode -1)
        (should (eq (key-binding (kbd "SPC")) 'self-insert-command))
        (should (eq (key-binding (kbd "C-c C-SPC f f")) 'find-file)))
      (uwumacs-test-enter-meow-state 'normal)
      (should (eq (key-binding (kbd "SPC")) 'meow-keypad)))))

(ert-deftest uwumacs-state-temporary-input-keeps-priority ()
  (with-temp-buffer
    (uwumacs-test-with-meow-state 'normal
      (uwumacs-state-test-with-mode
        (let ((overriding-terminal-local-map (make-sparse-keymap)))
          (define-key overriding-terminal-local-map (kbd "SPC") #'ignore)
          (should (eq (key-binding (kbd "SPC")) #'ignore)))
        (uwumacs-test-enter-meow-state 'beacon)
        (should-not uwumacs--literal-active)
        (should-not uwumacs--alternate-active)
        (with-current-buffer (get-buffer-create " *Minibuf-0*")
          (uwumacs-refresh)
          (should-not uwumacs--literal-active)
          (should-not uwumacs--alternate-active))))))

(ert-deftest uwumacs-state-independent-localleaders-and-mode-reset ()
  (let ((one (generate-new-buffer " uwu-one"))
        (two (generate-new-buffer " uwu-two")))
    (unwind-protect
        (with-current-buffer one
          (uwumacs-test-with-meow-state 'normal
            (uwumacs-state-test-with-mode
              (dolist (pair `((,one . ignore) (,two . forward-char)))
                (with-current-buffer (car pair)
                  (uwumacs-test-enter-meow-state 'normal)
                  (should (keymapp (key-binding (kbd "SPC m"))))
                  (keymap-set uwumacs-localleader-map "x" (cdr pair))))
              ;; Resolve both only after both maps have been mutated.
              (dolist (pair `((,one . ignore) (,two . forward-char)))
                (with-current-buffer (car pair)
                  (should (eq (key-binding (kbd "SPC m x")) (cdr pair)))))
              (should-not (eq (buffer-local-value 'uwumacs-localleader-map one)
                              (buffer-local-value 'uwumacs-localleader-map two)))
              (text-mode)
              (should-not (keymap-lookup uwumacs-localleader-map "x"))
              (should (eq (key-binding (kbd "C-c C-SPC f f")) 'find-file)))))
      (kill-buffer one) (kill-buffer two))))
(ert-deftest uwumacs-state-owned-lifecycle-and-late-buffers ()
  (let ((order-before (when-let* ((orders (get 'emulation-mode-map-alists 'list-order)))
                        (copy-hash-table orders))))
    (uwumacs-state-test-with-mode
      (dotimes (_ 3) (uwumacs-mode 1))
      (should (= 1 (cl-count 'uwumacs--emulation-alist emulation-mode-map-alists)))
      (with-temp-buffer
        (fundamental-mode)
        (should (eq (key-binding (kbd "C-c C-SPC f f")) 'find-file)))
      (uwumacs-mode -1)
      (should-not (memq 'uwumacs--emulation-alist emulation-mode-map-alists))
      (dolist (hook (cons 'after-change-major-mode-hook uwumacs--observation-hooks))
        (should-not (memq 'uwumacs--observe-buffer (symbol-value hook))))
      (should-not (gethash 'uwumacs--emulation-alist
                           (get 'emulation-mode-map-alists 'list-order)))
      (should (= (hash-table-count (get 'emulation-mode-map-alists 'list-order))
                 (if order-before (hash-table-count order-before) 0)))
      (dolist (buffer (buffer-list))
        (with-current-buffer buffer
          (should-not uwumacs--literal-active)
          (should-not uwumacs--alternate-active)))
      (uwumacs-mode 1)
      (with-temp-buffer
        (text-mode)
        (should (eq (key-binding (kbd "C-c C-SPC f f")) 'find-file))))))

(ert-deftest uwumacs-state-customization-is-transactional ()
  (with-temp-buffer
    (uwumacs-test-with-meow-state 'normal
      (uwumacs-state-test-with-mode
        (let ((old-root uwumacs--buffer-leader-map))
          (should-error (uwumacs--set-prefix-option 'uwumacs-localleader-key "f"))
          (should (equal uwumacs-localleader-key "m"))
          (should (eq old-root uwumacs--buffer-leader-map))
          (should-error (uwumacs--set-prefix-option 'uwumacs-leader-key "C-c"))
          (should (equal uwumacs-leader-key "SPC")))
        (unwind-protect
            (progn
              (uwumacs--set-prefix-option 'uwumacs-localleader-key "z")
              (should (keymapp (key-binding (kbd "SPC z"))))
              (should-not (key-binding (kbd "SPC m"))))
          (uwumacs--set-prefix-option 'uwumacs-localleader-key "m"))))))

(ert-deftest uwumacs-state-context-composes-and-refresh-failure-is-atomic ()
  (with-temp-buffer
    (uwumacs-test-with-meow-state 'normal
      (uwumacs-state-test-with-mode
        (setq uwumacs-map-context-function
              (lambda () '(:leader-sources ((:owner context :bindings (("x" ignore "X"))))
                           :localleader-sources ((:owner local :bindings (("r" forward-char "R"))))
                           :state-sources ((normal . ((:owner state :bindings (("z" backward-char "Z")))))))))
        (uwumacs-refresh)
        (should (eq (key-binding (kbd "SPC x")) 'ignore))
        (should (eq (key-binding (kbd "SPC m r")) 'forward-char))
        (should (eq (key-binding (kbd "z")) 'backward-char))
        (let ((map (make-sparse-keymap)))
          (keymap-set map "z" #'ignore)
          (setq uwumacs-user-state-maps `((normal . ,map)))
          (uwumacs-refresh)
          (should (eq (key-binding (kbd "z")) 'ignore)))
        (let ((old uwumacs--buffer-leader-map))
          (setq uwumacs-map-context-function
                (lambda () '(:leader-sources ((:owner bad :bindings (("m x" ignore "Bad")))))))
          (should-error (uwumacs-refresh))
          (should (eq old uwumacs--buffer-leader-map))
          (should (eq (key-binding (kbd "SPC x")) 'ignore)))))))

(ert-deftest uwumacs-state-terminal-buffers-are-excluded ()
  (require 'term)
  (with-temp-buffer
    (term-mode)
    (uwumacs-state-test-with-mode
      (uwumacs-refresh)
      (should-not uwumacs--alternate-active)
      (should-not uwumacs--literal-active))))

(provide 'uwumacs-state-tests)


(ert-deftest uwumacs-state-public-accessor-and-buffer-refresh ()
  (with-temp-buffer
    (uwumacs-state-test-with-mode
      (should (fboundp 'uwumacs-localleader-map))
      (keymap-set uwumacs-localleader-map "x" #'ignore)
      (uwumacs-refresh (current-buffer))
      (should (eq (keymap-lookup (uwumacs-localleader-map (current-buffer)) "x") 'ignore)))))

(ert-deftest uwumacs-state-disabled-customization-reserves-localleader ()
  (let ((old uwumacs-localleader-key))
    (unwind-protect
        (progn
          (should-error (uwumacs--set-prefix-option 'uwumacs-localleader-key "f"))
          (should (equal uwumacs-localleader-key old)))
      (set-default 'uwumacs-localleader-key old))))


(ert-deftest uwumacs-state-global-eat-toggle-does-not-exclude-editors ()
  ;; EAT's public Eshell mode is global; only the buffer's terminal matters.
  (defvar eat-eshell-mode)
  (with-temp-buffer
    (let ((eat-eshell-mode t))
      (uwumacs-state-test-with-mode
        (should (eq (key-binding (kbd "C-c C-SPC f f")) 'find-file))))))

(ert-deftest uwumacs-state-restores-absent-order-metadata ()
  (let ((saved (get 'emulation-mode-map-alists 'list-order)))
    (unwind-protect
        (progn
          (cl-remprop 'emulation-mode-map-alists 'list-order)
          (uwumacs-state-test-with-mode (uwumacs-mode -1))
          (should-not (get 'emulation-mode-map-alists 'list-order)))
      (put 'emulation-mode-map-alists 'list-order saved))))

(ert-deftest uwumacs-state-foundation-context-conflicts-are-transactional ()
  (with-temp-buffer
    (uwumacs-state-test-with-mode
      (let ((old-root uwumacs--buffer-leader-map))
        (setq uwumacs-map-context-function
              (lambda () '(:leader-sources
                           ((:owner contextual :priority 0
                             :bindings (("f f" ignore "Context file")))))))
        (let ((failure (should-error (uwumacs-refresh (current-buffer)))))
          (should (string-match-p "files" (error-message-string failure)))
          (should (string-match-p "contextual" (error-message-string failure))))
        (should (eq old-root uwumacs--buffer-leader-map))
        (should (eq (key-binding (kbd "C-c C-SPC f f")) 'find-file))))))

(ert-deftest uwumacs-state-foundation-context-honors-declared-priority ()
  (with-temp-buffer
    (uwumacs-state-test-with-mode
      (dolist (pair '((-10 . find-file) (10 . ignore)))
        (setq uwumacs-map-context-function
              (lambda () `(:leader-sources
                           ((:owner contextual :priority ,(car pair)
                             :bindings (("f f" ignore "Context file")))))))
        (uwumacs-refresh (current-buffer))
        (should (eq (key-binding (kbd "C-c C-SPC f f")) (cdr pair)))))))

(ert-deftest uwumacs-state-committed-metadata-comes-from-the-map-candidate ()
  (with-temp-buffer
    (uwumacs-state-test-with-mode
      (setq uwumacs-map-context-function
            (lambda () '(:leader-sources
                         ((:owner context :priority 10 :bindings (("f f" ignore "Context"))))
                         :localleader-sources
                         ((:owner local :bindings (("r" forward-char "Local"))))
                         :state-sources
                         ((normal . ((:owner state :bindings (("z" backward-char "State")))))))))
      (uwumacs-refresh (current-buffer))
      (setq uwumacs-map-context-function (lambda () (error "Must not reevaluate provider")))
      (should (boundp 'uwumacs--buffer-metadata))
      (should (equal (uwumacs--binding-metadata "f f" (plist-get uwumacs--buffer-metadata :leader))
                     '(:owner context :label "Context")))
      (should (equal (uwumacs--binding-metadata "r" (plist-get uwumacs--buffer-metadata :localleader))
                     '(:owner local :label "Local")))
      (should (equal (uwumacs--binding-metadata "z" (alist-get 'normal (plist-get uwumacs--buffer-metadata :state)))
                     '(:owner state :label "State")))
      (let ((old uwumacs--buffer-metadata))
        (should-error (uwumacs-refresh (current-buffer)))
        (should (eq old uwumacs--buffer-metadata))))))

(ert-deftest uwumacs-state-public-base-edits-survive-refresh ()
  (let ((uwumacs-leader-map (copy-keymap uwumacs-leader-map)))
    (with-temp-buffer
      (uwumacs-state-test-with-mode
        (keymap-set uwumacs-leader-map "C-M-z" #'ignore)
        (uwumacs-refresh (current-buffer))
        (should (eq (key-binding (kbd "C-c C-SPC C-M-z")) 'ignore))
        (keymap-set uwumacs-leader-map "C-M-z" #'forward-char)
        (uwumacs-refresh (current-buffer))
        (should (eq (key-binding (kbd "C-c C-SPC C-M-z")) 'forward-char))
        (keymap-unset uwumacs-leader-map "C-M-z" t)
        (uwumacs-refresh (current-buffer))
        (should-not (key-binding (kbd "C-c C-SPC C-M-z")))))))

(ert-deftest uwumacs-state-public-base-rebinding-conflicts-and-priorities ()
  (let ((uwumacs-leader-map (make-sparse-keymap)))
    (keymap-set uwumacs-leader-map "f f" #'ignore)
    (with-temp-buffer
      (uwumacs-state-test-with-mode
        (should (eq (key-binding (kbd "C-c C-SPC f f")) 'ignore))
        (let ((old uwumacs--buffer-leader-map))
          (setq uwumacs-map-context-function
                (lambda () '(:leader-sources ((:owner context :priority 0
                                              :bindings (("f f" forward-char "Context")))))))
          (let ((failure (should-error (uwumacs-refresh (current-buffer)))))
            (should (string-match-p "public-base" (error-message-string failure)))
            (should (string-match-p "context" (error-message-string failure))))
          (should (eq old uwumacs--buffer-leader-map)))
        (setq uwumacs-map-context-function
              (lambda () '(:leader-sources ((:owner context :priority 10
                                            :bindings (("f f" forward-char "Context")))))))
        (uwumacs-refresh (current-buffer))
        (should (eq (key-binding (kbd "C-c C-SPC f f")) 'forward-char))
        (keymap-unset uwumacs-leader-map "f f" t)
        (setq uwumacs-map-context-function
              (lambda () '(:leader-sources ((:owner context :priority 0
                                            :bindings (("f f" backward-char "Context")))))))
        (uwumacs-refresh (current-buffer))
        (should (eq (key-binding (kbd "C-c C-SPC f f")) 'backward-char))))))

(ert-deftest uwumacs-state-public-base-submaps-parents-and-native-events ()
  (let* ((parent (make-sparse-keymap))
         (child (make-sparse-keymap "Child"))
         (outer (make-sparse-keymap))
         (uwumacs-leader-map (make-composed-keymap (list outer))))
    (define-key parent [9] #'forward-char)
    (set-keymap-parent child parent)
    (keymap-set child "x" #'ignore)
    (keymap-set outer "z" child)
    (with-temp-buffer
      (uwumacs-state-test-with-mode
        (should (eq (key-binding (kbd "C-c C-SPC z TAB")) 'forward-char))
        (should (eq (key-binding (kbd "C-c C-SPC z x")) 'ignore))
        (should (equal (uwumacs--binding-metadata "z C-i" (plist-get uwumacs--buffer-metadata :leader))
                       '(:owner public-base :label "z TAB")))
        (keymap-set parent "TAB" #'backward-char)
        (uwumacs-refresh (current-buffer))
        (should (eq (key-binding (kbd "C-c C-SPC z TAB")) 'backward-char))
        (keymap-set outer "m" (make-sparse-keymap))
        (should-error (uwumacs-refresh (current-buffer)))))))

(ert-deftest uwumacs-state-public-base-keeps-native-menu-and-live-user-overrides ()
  (let* ((uwumacs-leader-map (make-sparse-keymap))
         (submenu (make-sparse-keymap "Native submenu"))
         (item `(menu-item "Native" ,submenu)))
    (keymap-set submenu "x" #'ignore)
    (define-key uwumacs-leader-map [z] item)
    (with-temp-buffer
      (uwumacs-state-test-with-mode
        (should (eq (key-binding (kbd "C-c C-SPC <z> x")) 'ignore))
        (should (equal (cdr (assoc [z] (uwumacs--native-map-bindings uwumacs-leader-map))) item))
        ;; User maps retain ordinary live native behavior without refresh.
        (keymap-set uwumacs-user-leader-map "<z> x" #'forward-char)
        (should (eq (key-binding (kbd "C-c C-SPC <z> x")) 'forward-char))
        (keymap-unset uwumacs-user-leader-map "<z> x" t)
        (should (eq (key-binding (kbd "C-c C-SPC <z> x")) 'ignore))))))
(ert-deftest uwumacs-state-public-base-retains-only-matching-declaration-priority ()
  (let ((uwumacs-leader-map (make-sparse-keymap))
        (uwumacs--leader-sources nil)
        (uwumacs--leader-metadata nil))
    (uwumacs--replace-leader-definitions
     '((:owner declared :priority 20 :bindings (("z" forward-char "Declared")))))
    (with-temp-buffer
      (uwumacs-state-test-with-mode
        (setq uwumacs-map-context-function
              (lambda () '(:leader-sources ((:owner context :priority 10
                                            :bindings (("z" backward-char "Context")))))))
        (uwumacs-refresh (current-buffer))
        (should (eq (key-binding (kbd "C-c C-SPC z")) 'forward-char))
        (should (equal (uwumacs--binding-metadata "z" (plist-get uwumacs--buffer-metadata :leader))
                       '(:owner declared :label "Declared")))
        (keymap-set uwumacs-leader-map "z" #'ignore)
        (uwumacs-refresh (current-buffer))
        (should (eq (key-binding (kbd "C-c C-SPC z")) 'backward-char))
        (should (equal (uwumacs--binding-metadata "z" (plist-get uwumacs--buffer-metadata :leader))
                       '(:owner context :label "Context")))))))