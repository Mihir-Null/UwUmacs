;;; uwumacs-state-gui-tests.el --- Real command-loop state checks -*- lexical-binding: t; -*-
(load (expand-file-name "uwumacs-test-helper.el" (file-name-directory load-file-name)) nil t)
(load (expand-file-name "uwumacs-state-tests.el" (file-name-directory load-file-name)) nil t)

(ert-deftest uwumacs-state-gui-native-command-loop ()
  (should (display-graphic-p))
  (save-window-excursion
    (let ((buffer (generate-new-buffer " *uwumacs-state-gui*")))
      (unwind-protect
          (progn
            (switch-to-buffer buffer)
            (emacs-lisp-mode)
            (uwumacs-test-with-meow-state 'normal
              (uwumacs-state-test-with-mode
                (keymap-set uwumacs-localleader-map "x" #'forward-char)
                (insert "abcdef")
                (goto-char (point-min))
                (execute-kbd-macro (kbd "C-u 2 SPC m x"))
                (should (= (point) 3))
                (uwumacs-test-enter-meow-state 'insert)
                (execute-kbd-macro (kbd "SPC"))
                (should (equal (buffer-string) "ab cdef"))
                (execute-kbd-macro (kbd "C-c C-SPC m x"))
                (should (= (point) 5)))))
        (when (buffer-live-p buffer) (kill-buffer buffer))))))

(defvar uwumacs-state-gui-dispatch-count 0)

(ert-deftest uwumacs-state-gui-eat-transition-precedes-next-key-lookup ()
  "A native EAT transition must block the immediately following leader command."
  (should (display-graphic-p))
  (save-window-excursion
    (let ((original (selected-frame))
          (before (frame-list))
          (buffer (generate-new-buffer " *uwumacs-eat-transition*"))
          (uwumacs-state-gui-dispatch-count 0)
          process)
      (unwind-protect
          (progn
            (require 'eat)
            (require 'eshell)
            (switch-to-buffer buffer)
            (eshell-mode)
            (setq-local eat--eshell-invocation-directory default-directory)
            (setq process (make-pipe-process :name "uwumacs-eat-fixture"
                                             :buffer buffer :noquery t))
            (use-local-map (copy-keymap (current-local-map)))
            (keymap-set (current-local-map) "<f8>"
                        (lambda () (interactive)
                          (eat--eshell-setup-proc-and-term process)
                          (should-not uwumacs--alternate-active)))
            (uwumacs-state-test-with-mode
              (keymap-set uwumacs-user-leader-map "x"
                          (lambda () (interactive)
                            (cl-incf uwumacs-state-gui-dispatch-count)))
              (uwumacs-refresh (current-buffer))
              (execute-kbd-macro (kbd "C-c C-SPC x"))
              (should (= uwumacs-state-gui-dispatch-count 1))
              (setq uwumacs-state-gui-dispatch-count 0)
              ;; F8 invokes real EAT setup, which publishes its execution hook.
              ;; No test manually runs an observation hook or refreshes flags.
              (condition-case failure
                  (execute-kbd-macro (kbd "<f8> C-c C-SPC x"))
                ;; EAT may reject this modified prefix.  Native rejection is
                ;; valid; invoking the UwUmacs command is not.
                (user-error
                 (unless (equal (error-message-string failure)
                                "Keyboard macro terminated by a command ringing the bell")
                   (signal (car failure) (cdr failure)))))
              (should eat-terminal)
              (should (= uwumacs-state-gui-dispatch-count 0))
              (eat--eshell-cleanup)
              (execute-kbd-macro (kbd "C-c C-SPC x"))
              (should (= uwumacs-state-gui-dispatch-count 1))))
        (when (process-live-p process) (delete-process process))
        (when (buffer-live-p buffer) (kill-buffer buffer))
        (select-frame original)
        (dolist (frame (seq-difference (frame-list) before))
          (when (frame-live-p frame) (delete-frame frame t)))))))
