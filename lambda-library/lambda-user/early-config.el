;;; early-config.el --- Early user policy -*- lexical-binding: t; -*-
;; Generated from literate/20-user-policy.org; edit the Org source, then tangle.

;;; Commentary:
;; Keep this deliberately small. Lambda's `early-init.el' owns package archives,
;; writable directories, and the bulk of startup policy.

;;; Code:

;; Lambda installs its declared package topics before config.el loads. Limit that
;; list here so disabling a module also avoids installing its unrelated packages.
;; Existing packages are never removed by this policy. Personal modules can still
;; request packages explicitly through use-package :ensure.
(require 'seq)
(setopt lem-load-extras t)
(defconst starter-package-topics
  '(dashboard eshell faces fonts functions org-settings programming shell)
  "Lambda package topics used by the personal configuration.")
(setq lem-packages-alist
      (seq-filter (lambda (entry) (memq (car entry) starter-package-topics))
                  lem-packages-alist))
(setf (alist-get 'windows lem-packages-alist)
      (append (alist-get 'windows lem-packages-alist) '(frames-only-mode)))
;; Warnings are useful while learning. Do not inherit Colin's personal choice to
;; suppress nearly all startup warnings.
(setopt warning-minimum-level :warning)
(provide 'early-config)
;;; early-config.el ends here
