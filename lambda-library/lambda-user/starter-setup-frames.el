;;; starter-setup-frames.el --- Desktop-managed Emacs frames -*- lexical-binding: t; -*-
;; Generated from literate/45-frames.org; edit the Org source, then tangle.

;;; Code:
(defun starter-frames-display-magit (original buffer)
  "Display Magit BUFFER in an OS frame, or use ORIGINAL outside frame mode."
  (if (and (bound-and-true-p frames-only-mode) (display-graphic-p))
      (display-buffer buffer
                      '((display-buffer-reuse-window display-buffer-pop-up-frame)
                        (reusable-frames . t)))
    (funcall original buffer)))
(use-package frames-only-mode
  :when (and lem-load-extras (locate-library "frames-only-mode"))
  :demand t
  :custom
  (frames-only-mode-use-windows-for-completion t)
  :config
  (setq frames-only-mode-configuration-variables
        (seq-remove (lambda (setting)
                      (memq (car setting)
                            '(magit-commit-show-diff magit-bury-buffer-function)))
                    frames-only-mode-configuration-variables))
  (add-to-list 'frames-only-mode-configuration-variables
               '(popper-display-control nil))
  (frames-only-mode-remap-common-window-split-keybindings)
  (define-key frames-only-mode-mode-map
              [remap lem-split-window-below-and-focus] #'make-frame-command)
  (define-key frames-only-mode-mode-map
              [remap lem-split-window-right-and-focus] #'make-frame-command)
  (advice-add 'lem-display-magit-in-other-window
              :around #'starter-frames-display-magit)
  ;; Re-evaluating this file must not overwrite the mode's saved defaults.
  (unless frames-only-mode
    (frames-only-mode 1)))

(provide 'starter-setup-frames)
;;; starter-setup-frames.el ends here
