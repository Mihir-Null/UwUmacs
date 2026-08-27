;;; private.example.el --- Example local overrides -*- lexical-binding: t; -*-

;; Copy to private.el for account/machine-specific values that should not be committed.
;; config.el loads private.el after the portable variables are defined and before
;; `starter-platform-apply' consumes them.

;; Identity
;; (setq user-full-name "Your Name"
;;       user-mail-address "you@example.com")

;; Paths
;; (setopt starter-project-directory (expand-file-name "~/src/"))
;; (setopt starter-org-directory (expand-file-name "~/Documents/my-org/"))

;; Cross-platform fonts are intentionally not guessed in starter-platform.el.
;; Set Lambda's font variables here once you decide on installed fonts.
