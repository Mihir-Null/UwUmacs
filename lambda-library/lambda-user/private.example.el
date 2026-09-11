;;; private.example.el --- Example local overrides -*- lexical-binding: t; -*-
;; Generated from literate/80-maintenance.org; edit the Org source, then tangle.

;; Copy to private.el for account/machine-specific values that should not be committed.
;; config.el loads private.el after the portable platform variables are defined and
;; before the later UI/programming modules consume their policy variables.

;; Identity
;; (setq user-full-name "Your Name"
;;       user-mail-address "you@example.com")

;; Paths
;; These variables are already defined when private.el is loaded, so `setopt' is useful.
;; (setopt starter-project-directory (expand-file-name "~/src/"))
;; (setopt starter-org-directory (expand-file-name "~/Documents/my-org/"))

;; Terminal
;; `starter-setup-terminal' is loaded later, so pre-bind its installation root with
;; `setq' if MSYS2 is not installed at the normal C:/msys64/ location.
;; (setq starter-msys2-root "D:/Tools/msys64/")

;; Language tooling
;; Eglot is available manually through SPC l e. Automatic startup and external
;; language packages are opt-in because their servers/runtimes are platform-owned.
;; (setq starter-eglot-auto-start-modes '(python-mode python-ts-mode)
;;       starter-language-packages '(nix racket guile))
;; UI
;; `starter-setup-ui' is loaded later, so use `setq' here; its `defcustom' forms will
;; preserve these pre-bound values.
;; (setq starter-ui-theme 'doom-dark+
;;       starter-ui-light-theme 'doom-one-light
;;       starter-ui-font-family "GoogleSansCode Nerd Font"
;;       starter-ui-icons 'auto
;;       starter-ui-nerd-font "Symbols Nerd Font Mono")

;; The primary programming font and the dedicated Nerd Icons symbol font are kept
;; separate. `starter-ui-font-family' changes only the default face family, preserving
;; the platform's existing point size. If the family is absent, the starter keeps the
;; platform default rather than failing startup.
