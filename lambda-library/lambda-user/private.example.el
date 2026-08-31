;;; private.example.el --- Example local overrides -*- lexical-binding: t; -*-

;; Copy to private.el for account/machine-specific values.  `private.el' is
;; ignored by Git and loads before the user presentation modules.

;; Identity
;; (setq user-full-name "Your Name"
;;       user-mail-address "you@example.com")

;; Paths
;; (setopt starter-project-directory (expand-file-name "~/src/"))
;; (setopt starter-org-directory (expand-file-name "~/Documents/my-org/"))

;; Theme, native frame chrome, and icons
;; (setq starter-ui-theme 'doom-dark+
;;       starter-ui-light-theme 'doom-one-light
;;       starter-ui-accent "#ff5a36"
;;       starter-ui-icons 'auto
;;       starter-ui-nerd-font "Symbols Nerd Font Mono"
;;       starter-ui-enable-menu-bar t
;;       starter-ui-enable-tool-bar t)

;; Discoverability and motion
;; (setq starter-discoverability-posframes t
;;       starter-discoverability-eldoc-hover t
;;       starter-discoverability-casual-menus t
;;       starter-motion-enable-ultra-scroll t
;;       starter-motion-enable-pulsar t)

;; Buffer strip
;; (setq starter-tabs-enable-buffer-strip t
;;       starter-tabs-name-width 24)

;; Lambda font variables can be set here once the chosen fonts are installed on
;; every machine.  A patched primary programming font is separate from the Nerd
;; Icons symbol font.
