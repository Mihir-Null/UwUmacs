;;; private.example.el --- Example local overrides -*- lexical-binding: t; -*-

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

;; UI
;; `starter-setup-ui' is loaded later, so use `setq' here; its `defcustom' forms will
;; preserve these pre-bound values.
;; (setq starter-ui-theme 'doom-dark+
;;       starter-ui-light-theme 'doom-one-light
;;       starter-ui-icons 'auto
;;       starter-ui-nerd-font "Symbols Nerd Font Mono")

;; A patched primary programming font is separate from Nerd Icons. Lambda's font
;; variables can also be set here once you decide which fonts should be present on
;; each machine.
