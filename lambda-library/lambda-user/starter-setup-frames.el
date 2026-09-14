;;; starter-setup-frames.el --- Desktop-managed Emacs frames -*- lexical-binding: t; -*-
;; Generated from literate/45-frames.org; edit the Org source, then tangle.

;;; Code:
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
  ;; Re-evaluating this file must not overwrite the mode's saved defaults.
  (unless frames-only-mode
    (frames-only-mode 1)))

(provide 'starter-setup-frames)
;;; starter-setup-frames.el ends here
