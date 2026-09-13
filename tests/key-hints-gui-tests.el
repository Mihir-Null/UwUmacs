;;; key-hints-gui-tests.el --- Rendered Meow hints -*- lexical-binding: t; -*-
;; Load after ordinary graphical startup and run selector "^dots-hints-gui-".
(require 'ert)

(defmacro dots-hints-gui-in-editor (&rest body)
  "Run BODY from a normal-state editor buffer."
  (declare (indent 0) (debug t))
  `(save-window-excursion
     (let ((buffer (generate-new-buffer " *key-hints-test*")))
       (unwind-protect
           (progn
             (switch-to-buffer buffer)
             (emacs-lisp-mode)
             (meow--switch-state 'normal)
             (should (meow-normal-mode-p))
             ,@body)
         (when (buffer-live-p buffer) (kill-buffer buffer))))))

(ert-deftest dots-hints-gui-keypad-renders-physical-prefix ()
  (skip-unless (display-graphic-p))
  (dots-hints-gui-in-editor
    (let ((unread-command-events (list ?f))
          (meow-keypad-describe-delay 0)
          (deadline (+ (float-time) 10))
          (rendered "") timer)
      ;; Start from an empty popup so whatever is captured is provably this
      ;; keypad's rendering and not a leftover from an earlier test.
      (when-let* ((existing (bound-and-true-p which-key--buffer))
                  (buffer (get-buffer existing)))
        (with-current-buffer buffer (let ((inhibit-read-only t)) (erase-buffer))))
      (setq timer
            (run-with-timer
             ;; First attempt at the delay this test always used; only retry
             ;; when the popup is not up yet.  A fixed sleep races the popup on
             ;; a loaded machine, and a miss left `rendered' nil, which turned a
             ;; timing slip into `wrong-type-argument' instead of a clear
             ;; failure.  Any error here must still release the keypad, or the
             ;; run blocks until the watchdog fires.
             0.4 0.1
             (lambda ()
               (condition-case nil
                   (let* ((existing (bound-and-true-p which-key--buffer))
                          (buffer (and existing (get-buffer existing)))
                          (text (and buffer
                                     (with-current-buffer buffer
                                       (buffer-substring-no-properties
                                        (point-min) (point-max))))))
                     (when (or (and text (string-match-p "SPC f" text))
                               (> (float-time) deadline))
                       (unwind-protect (setq rendered (or text ""))
                         (cancel-timer timer)
                         (setq unread-command-events (list 'escape)))))
                 (error (cancel-timer timer)
                        (setq unread-command-events (list 'escape)))))))
      (unwind-protect (call-interactively #'meow-keypad)
        (cancel-timer timer))
      (should (string-match-p "SPC f  \\[next key\\]" rendered))
      (should (string-match-p "find-file" rendered))
      (should-not (string-match-p "C-c C-SPC" rendered))
      (setq dots-hints-gui-menu rendered))))

(ert-deftest dots-hints-gui-mx-renders-physical-annotation ()
  (skip-unless (display-graphic-p))
  (dots-hints-gui-in-editor
    (let ((deadline (+ (float-time) 10))
          (rendered "") timer)
      (unwind-protect
          (condition-case nil
              (minibuffer-with-setup-hook
                  (lambda ()
                    (setq timer
                          (run-with-timer
                           ;; First attempt at the delay this test always used;
                           ;; only retry when Vertico's candidate overlay is not
                           ;; up yet.  A fixed sleep races minibuffer setup, and
                           ;; a miss left `rendered' nil, turning a timing slip
                           ;; into `wrong-type-argument'.  Any error here must
                           ;; still quit the minibuffer, or the run blocks until
                           ;; the watchdog fires.
                           0.3 0.1
                           (lambda ()
                             (condition-case nil
                                 (let* ((window (active-minibuffer-window))
                                        (ready (and window
                                                    (with-current-buffer (window-buffer window)
                                                      (bound-and-true-p vertico--candidates-ov)))))
                                   (when (or ready (> (float-time) deadline))
                                     (unwind-protect
                                         (when ready
                                           (with-current-buffer (window-buffer window)
                                             (insert "consult-line")
                                             (vertico--exhibit)
                                             (setq rendered
                                                   (substring-no-properties
                                                    (or (overlay-get vertico--candidates-ov
                                                                     'before-string)
                                                        "")))))
                                       (cancel-timer timer)
                                       (setq unread-command-events (list ?\C-g)))))
                               (error (cancel-timer timer)
                                      (setq unread-command-events (list ?\C-g))))))))
                (call-interactively #'execute-extended-command))
            (quit nil))
        (when timer (cancel-timer timer)))
      (should (string-match-p "consult-line" rendered))
      (should (string-match-p (regexp-quote "consult-line (SPC s s)") rendered))
      (setq dots-hints-gui-completion rendered))))

(ert-deftest dots-hints-gui-advertised-keys-execute-command ()
  (skip-unless (display-graphic-p))
  (dots-hints-gui-in-editor
    (let ((keys (starter-meow-command-key 'dashboard-open)))
      (should (equal keys "SPC h"))
      (execute-kbd-macro (kbd keys))
      (should (equal (buffer-name) dashboard-buffer-name)))))

(provide 'key-hints-gui-tests)
