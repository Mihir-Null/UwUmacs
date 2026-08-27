;;; early-config.el --- Early user policy -*- lexical-binding: t; -*-

;;; Commentary:
;; Keep this deliberately small. Lambda's `early-init.el' owns package archives,
;; writable directories, and the bulk of startup policy.

;;; Code:

;; Let `use-package' install packages requested by the modules we enable.
;; On Nix this intentionally means: Nix owns Emacs/external executables initially,
;; while Lambda/package.el owns Elisp. Change this only when you deliberately move
;; package ownership into Nix.
(setopt lem-package-ensure-packages t)

;; Warnings are useful while learning. Do not inherit Colin's personal choice to
;; suppress nearly all startup warnings.
(setopt warning-minimum-level :warning)

(provide 'early-config)
;;; early-config.el ends here
