;;; starter-setup-languages.el --- Optional language examples -*- lexical-binding: t; -*-

;;; Commentary:
;; NOT loaded by default. Uncomment `(require 'starter-setup-languages)' in config.el
;; after reading this file. The point is to demonstrate extending Lambda's general
;; programming layer rather than silently pre-installing an IDE for every language.

;;; Code:

;; Nix has no built-in major mode in Emacs.
(use-package nix-mode
  :ensure t
  :mode "\\.nix\\'")

;; Racket editing + REPL/debugger tooling.
(use-package racket-mode
  :ensure t
  :mode "\\.rkt\\'")

;; Emacs ships Scheme mode; Geiser adds implementation-aware REPL/evaluation support.
(use-package geiser
  :ensure t
  :defer t)

(use-package geiser-guile
  :ensure t
  :after geiser)

;; Eglot is built into modern Emacs. Start it explicitly with M-x eglot initially.
;; Add automatic hooks only after deciding which language servers each platform owns.

(provide 'starter-setup-languages)
;;; starter-setup-languages.el ends here
