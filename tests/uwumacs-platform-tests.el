;;; uwumacs-platform-tests.el --- Platform policy per operating system -*- lexical-binding: t; -*-
;; Run: emacs -Q --batch -l tests/uwumacs-platform-tests.el -f ert-run-tests-batch-and-exit
;; Needs no packages: the platform module depends only on Emacs's own libraries.
;; `system-type' is a plain variable, so each test binds it to the platform it
;; exercises and the branches for every operating system run on any machine.
(require 'ert)
(require 'cl-lib)
(add-to-list 'load-path
             (expand-file-name "../lisp/" (file-name-directory load-file-name)))
(require 'uwumacs-platform)

;; Variables that only exist on macOS builds or once shell.el is loaded must
;; be declared special here, or `let' would bind them lexically and the
;; module's `setq' would miss them.
(defvar explicit-shell-file-name)
(defvar ns-command-modifier)
(defvar ns-option-modifier)
(defvar ns-right-option-modifier)
(defvar ns-use-native-fullscreen)

(defmacro uwumacs-platform-test-with (system executables &rest body)
  "Run BODY as SYSTEM with only EXECUTABLES findable and no global side effects."
  (declare (indent 2))
  `(let ((system-type ,system)
         (process-environment (copy-sequence process-environment))
         (default-frame-alist (copy-sequence default-frame-alist))
         (enable-theme-functions nil)
         (saved-global-map (current-global-map))
         shell-file-name explicit-shell-file-name shell-command-switch
         delete-by-moving-to-trash trash-directory
         ns-command-modifier ns-option-modifier ns-right-option-modifier
         ns-use-native-fullscreen)
     (cl-letf (((symbol-function 'executable-find)
                (lambda (name &rest _)
                  (and (member name ,executables) (concat "/mock/bin/" name)))))
       (unwind-protect
           (progn (use-global-map (make-sparse-keymap))
                  ,@body)
         (use-global-map saved-global-map)))))

(ert-deftest uwumacs-platform-macos-sets-shell-and-modifiers ()
  (uwumacs-platform-test-with 'darwin '("zsh")
    (uwumacs-platform-apply)
    (should (equal shell-command-switch "-c"))
    (should (equal explicit-shell-file-name "/mock/bin/zsh"))
    (should (eq ns-command-modifier 'super))
    (should (eq ns-option-modifier 'meta))
    (should (eq ns-right-option-modifier 'none))
    (should-not ns-use-native-fullscreen)
    (should (eq (keymap-lookup (current-global-map) "s-Z") #'undo-redo))
    (should (eq (keymap-lookup (current-global-map) "s-q") #'uwumacs-delete-frame-or-quit))
    (should (eq (keymap-lookup (current-global-map) "C-s-f") #'toggle-frame-fullscreen))
    (should (memq #'uwumacs--macos-sync-titlebar enable-theme-functions))))

(ert-deftest uwumacs-platform-macos-modifiers-are-customizable ()
  (uwumacs-platform-test-with 'darwin '("zsh")
    (let ((uwumacs-macos-modifiers '((ns-command-modifier . meta)
                                     (ns-option-modifier . super))))
      (uwumacs-platform-apply)
      (should (eq ns-command-modifier 'meta))
      (should (eq ns-option-modifier 'super))
      ;; Not listed, so untouched.
      (should-not ns-right-option-modifier))))

(ert-deftest uwumacs-platform-macos-sets-a-utf8-locale-only-when-missing ()
  (uwumacs-platform-test-with 'darwin '("zsh")
    (setenv "LANG" nil)
    (uwumacs-platform-apply)
    (should (equal (getenv "LANG") "en_US.UTF-8")))
  (uwumacs-platform-test-with 'darwin '("zsh")
    (setenv "LANG" "de_DE.UTF-8")
    (uwumacs-platform-apply)
    (should (equal (getenv "LANG") "de_DE.UTF-8"))))

(ert-deftest uwumacs-platform-macos-trash-prefers-native-then-tool-then-directory ()
  (uwumacs-platform-test-with 'darwin '("trash")
    (cl-letf (((symbol-function 'system-move-file-to-trash) #'ignore))
      (should (eq (uwumacs--macos-configure-trash) 'native))
      (should delete-by-moving-to-trash)))
  (uwumacs-platform-test-with 'darwin '("trash")
    (cl-letf (((symbol-function 'system-move-file-to-trash) nil))
      (should (eq (uwumacs--macos-configure-trash) 'trash-command))
      (should (eq (symbol-function 'system-move-file-to-trash) #'uwumacs--macos-trash))
      (should-not trash-directory)))
  (uwumacs-platform-test-with 'darwin '()
    (cl-letf (((symbol-function 'system-move-file-to-trash) nil))
      (should (eq (uwumacs--macos-configure-trash) 'directory))
      (should (equal trash-directory "~/.Trash"))
      (should delete-by-moving-to-trash))))

(ert-deftest uwumacs-platform-macos-titlebar-sync-is-quiet-without-a-display ()
  (uwumacs-platform-test-with 'darwin '()
    (cl-letf (((symbol-function 'display-graphic-p) #'ignore))
      (should-not (uwumacs--macos-sync-titlebar))
      (should-not (assq 'ns-appearance default-frame-alist)))))

(ert-deftest uwumacs-platform-windows-leaves-macos-settings-alone ()
  (uwumacs-platform-test-with 'windows-nt '("pwsh.exe")
    (uwumacs-platform-apply)
    (should (equal shell-command-switch "-Command"))
    (should-not ns-command-modifier)
    (should-not delete-by-moving-to-trash)
    (should-not (keymap-lookup (current-global-map) "s-q"))))

(ert-deftest uwumacs-platform-linux-leaves-macos-settings-alone ()
  (uwumacs-platform-test-with 'gnu/linux '("bash")
    (uwumacs-platform-apply)
    (should (equal shell-command-switch "-c"))
    (should (equal explicit-shell-file-name "/mock/bin/bash"))
    (should-not ns-command-modifier)
    (should-not (keymap-lookup (current-global-map) "s-q"))))

(defun uwumacs-platform-test-reveal (system file)
  "Return the command `uwumacs-reveal-in-file-manager' runs for FILE on SYSTEM."
  (let ((system-type system) (buffer-file-name file) command)
    (cl-letf (((symbol-function 'call-process)
               (lambda (program &rest args) (setq command (cons program (nthcdr 3 args))) 0))
              ((symbol-function 'file-directory-p) #'ignore))
      (uwumacs-reveal-in-file-manager)
      command)))

(ert-deftest uwumacs-platform-reveal-uses-each-desktops-file-manager ()
  (let ((file (expand-file-name "notes/todo.org" temporary-file-directory)))
    (should (equal (uwumacs-platform-test-reveal 'darwin file)
                   (list "open" "-R" file)))
    (should (equal (uwumacs-platform-test-reveal 'windows-nt file)
                   (list "explorer.exe" (concat "/select," (subst-char-in-string ?/ ?\\ file)))))
    (should (equal (uwumacs-platform-test-reveal 'gnu/linux file)
                   (list "xdg-open" (file-name-directory file))))))

;;; uwumacs-platform-tests.el ends here
