;;; starter-setup-languages.el --- Selective language tooling -*- lexical-binding: t; -*-
;; Generated from literate/60-programming.org; edit the Org source, then tangle.

;;; Commentary:
;; Supply a small built-in Eglot command surface without assuming which language
;; servers each machine owns.  Language packages and automatic LSP startup remain
;; explicit opt-ins that can be set in private.el before this module loads.

;;; Code:

(defgroup starter-languages nil
  "Selective language tooling for the starter configuration."
  :group 'lambda-emacs)
(defcustom starter-language-packages nil
  "Optional language packages to install and configure.

Supported values are `nix', `racket', and `guile'.  Built-in modes and Eglot do
not need to be listed here."
  :type '(set (const nix) (const racket) (const guile))
  :group 'starter-languages)
(defcustom starter-eglot-auto-start-modes nil
  "Major modes in which `eglot-ensure' should run automatically.

The default is nil: start Eglot explicitly with `starter-eglot' or `M-x eglot'
until the language server for a mode is deliberately installed on each machine."
  :type '(repeat symbol)
  :group 'starter-languages)
(use-package eglot
  :ensure nil
  :commands (eglot eglot-ensure eglot-shutdown eglot-reconnect
                   eglot-rename eglot-code-actions eglot-format
                   eglot-format-buffer eglot-find-declaration
                   eglot-find-implementation eglot-find-typeDefinition)
  :custom
  (eglot-autoshutdown t))
(defvar starter--eglot-auto-start-hooks nil
  "Mode hooks currently managed by `starter-eglot-apply-auto-start-modes'.")
(defun starter-eglot-apply-auto-start-modes ()
  "Apply `starter-eglot-auto-start-modes' to their corresponding hooks."
  (interactive)
  (dolist (hook starter--eglot-auto-start-hooks)
    (remove-hook hook #'eglot-ensure))
  (setq starter--eglot-auto-start-hooks nil)
  (dolist (mode starter-eglot-auto-start-modes)
    (let ((hook (intern (format "%s-hook" mode))))
      (add-hook hook #'eglot-ensure)
      (push hook starter--eglot-auto-start-hooks))))
(defun starter-eglot ()
  "Interactively start or manage Eglot for the current project."
  (interactive)
  (require 'eglot)
  (call-interactively #'eglot))

(starter-eglot-apply-auto-start-modes)
;; Keep non-built-in language modes deliberate.  Set
;; `starter-language-packages' in private.el before startup to enable these.
(when (memq 'nix starter-language-packages)
  (use-package nix-mode
    :ensure t
    :mode "\\.nix\\'"))
(when (memq 'racket starter-language-packages)
  (use-package racket-mode
    :ensure t
    :mode "\\.rkt\\'"))
(when (memq 'guile starter-language-packages)
  (use-package geiser
    :ensure t
    :defer t)
  (use-package geiser-guile
    :ensure t
    :after geiser))
(provide 'starter-setup-languages)
;;; starter-setup-languages.el ends here
