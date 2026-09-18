;;; private.example.el --- Example local overrides -*- lexical-binding: t; -*-
;; Generated from literate/80-maintenance.org; edit the Org source, then tangle.

;; Copy to private.el for account/machine-specific values that should not be committed.
;; init.el loads private.el after the portable platform variables are defined and
;; before the later UI/programming modules consume their policy variables.

;; Identity
;; (setq user-full-name "Your Name"
;;       user-mail-address "you@example.com")

;; Paths
;; These variables are already defined when private.el is loaded, so `setopt' is useful.
;; (setopt uwumacs-project-directory (expand-file-name "~/src/"))
;; (setopt uwumacs-org-directory (expand-file-name "~/Documents/my-org/"))

;; Terminal
;; MSYS2's location, when it is not the normal C:/msys64/.  The platform
;; chapter defines this before private.el loads, so `setopt' works.
;; (setopt uwumacs-msys2-root "D:/Tools/msys64/")
;;
;; Which shell the terminal runs, and where the escape key goes while a
;; full-screen program is drawing (`auto', `terminal' or `meow').
;; (setopt ghostel-shell '("/bin/zsh" "--login"))
;; (setopt uwumacs-terminal-escape 'terminal)
;;
;; Let programs in the terminal write the system clipboard (OSC 52).  Handy
;; over SSH; it also lets anything you `cat' set your clipboard.
;; (setopt ghostel-enable-osc52 t)
;;
;; Route every `compile', `recompile' and `project-compile' through a real
;; terminal instead of Emacs's own compilation buffer.
;; (with-eval-after-load 'ghostel (ghostel-compile-global-mode 1))

;; macOS
;; Modifier keys are applied after this file loads, so `setopt' works here.
;; Swap Command and Option, or give the right Option key to Emacs too:
;; (setopt uwumacs-macos-modifiers '((ns-command-modifier . meta)
;;                                   (ns-option-modifier . super)
;;                                   (ns-right-option-modifier . meta)))

;; Language tooling
;; Eglot is available manually through SPC l e. Automatic startup and external
;; language packages are opt-in because their servers/runtimes are platform-owned.
;; (setq uwumacs-eglot-auto-start-modes '(python-mode python-ts-mode)
;;       uwumacs-language-packages '(nix racket guile))
;; UI
;; `uwumacs-ui' is loaded later, so use `setq' here; its `defcustom' forms will
;; preserve these pre-bound values.
;; (setq uwumacs-theme 'doom-dark+
;;       uwumacs-light-theme 'doom-one-light
;;       uwumacs-font-family "GoogleSansCode Nerd Font"
;;       uwumacs-icons 'auto
;;       uwumacs-nerd-font "Symbols Nerd Font Mono")

;; The primary programming font and the dedicated Nerd Icons symbol font are kept
;; separate. `uwumacs-font-family' changes only the default face family, preserving
;; the platform's existing point size. If the family is absent, the starter keeps the
;; platform default rather than failing startup.
