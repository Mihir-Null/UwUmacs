;;;; lem-setup-fonts.el ---Setup for fonts           -*- lexical-binding: t; -*-
;; Copyright (C) 2022
;; SPDX-License-Identifier: GPL-3.0-or-later
;; Author: Colin McLear

;;; Commentary:
;;
;;; Code:

;;;; Check Fonts
;; See https://emacsredux.com/blog/2021/12/22/check-if-a-font-is-available-with-emacs-lisp/
(defun lem-font-available-p (font-name)
  "Check if font is available from system installed fonts."
  (member font-name (font-family-list)))

;;;; Set Default & Variable Pitch Fonts
(defun lem-ui--set-default-font (spec)
  "Set the default font based on SPEC.
SPEC is expected to be a plist with the same key names
as accepted by `set-face-attribute'."
  (when spec
    (apply 'set-face-attribute 'default nil spec)))

(defun lem-ui--set-variable-width-font (spec)
  "Set the default font based on SPEC.
SPEC is expected to be a plist with the same key names
as accepted by `set-face-attribute'."
  (when spec
    (apply 'set-face-attribute 'variable-pitch nil spec)))

(defcustom lem-ui-default-font nil
  "The configuration of the `default' face.
Use a plist with the same key names as accepted by `set-face-attribute'."
  :group 'lambda-emacs
  :type '(plist :key-type: symbol)
  :tag "Lambda-Emacs Default font"
  :set (lambda (sym val)
         (let ((prev-val (if (boundp 'lem-ui-default-font)
                             lem-ui-default-font
                           nil)))
           (set-default sym val)
           (when (and val (not (eq val prev-val)))
             (lem-ui--set-default-font val)))))

(defcustom lem-ui-variable-width-font nil
  "The configuration of the `default' face.
Use a plist with the same key names as accepted by `set-face-attribute'."
  :group 'lambda-emacs
  :type '(plist :key-type: symbol)
  :tag "Lambda-Emacs Variable width font"
  :set (lambda (sym val)
         (let ((prev-val (if (boundp 'lem-ui-variable-width-font)
                             lem-ui-variable-width-font
                           nil)))
           (set-default sym val)
           (when (and val (not (eq val prev-val)))
             (lem-ui--set-variable-width-font val)))))

;;;; Set Symbol & Emoji Fonts
(use-package fontset
  :ensure nil
  :custom
  ;; Set this to nil to set symbols entirely separately
  ;; Need it set to `t` in order to display org-modern-indent faces properly
  (use-default-font-for-symbols t)
  :config
  ;; Use symbola for proper symbol glyphs, but have some fallbacks
  (cond ((lem-font-available-p "Symbola")
         (set-fontset-font
          t 'symbol "Symbola" nil))
        ((lem-font-available-p "Apple Symbols")
         (set-fontset-font
          t 'symbol "Apple Symbols" nil))
        ((lem-font-available-p "Symbol")
         (set-fontset-font
          t 'symbol "Symbol" nil))
        ((lem-font-available-p "Segoe UI Symbol")
         (set-fontset-font
          t 'symbol "Segoe UI Symbol" nil)))
  ;; Use Apple emoji
  ;; NOTE that emoji here may need to be set to unicode to get color emoji
  (when (and (>= emacs-major-version 28)
             (lem-font-available-p "Apple Color Emoji"))
    (set-fontset-font t 'emoji
                      '("Apple Color Emoji" . "iso10646-1") nil 'prepend))
  ;; Fall back font for missing glyph
  (defface fallback '((t :family "Fira Code"
                         :inherit fringe)) "Fallback")
  (set-display-table-slot standard-display-table 'truncation
                          (make-glyph-code ?… 'fallback))
  (set-display-table-slot standard-display-table 'wrap
                          (make-glyph-code ?↩ 'fallback)))


;; Set default line spacing. If the value is an integer, it indicates
;; the number of pixels below each line. A decimal number is a scaling factor
;; relative to the current window's default line height. The setq-default
;; function sets this for all buffers. Otherwise, it only applies to the current
;; open buffer
(setq-default line-spacing 0.1)

;;;; Font Lock
(use-package font-lock
  :ensure nil
  :defer 1
  :custom
  ;; Max font lock decoration (set nil for less)
  (font-lock-maximum-decoration t)
  ;; No limit on font lock
  (font-lock-maximum-size nil))

;;;; Scale Text
;; When using `text-scale-increase', this sets each 'step' to about one point size.
(setopt text-scale-mode-step 1.08)
(bind-key* "s-=" #'text-scale-increase)
(bind-key* "s--" #'text-scale-decrease)
(bind-key* "s-0" #'text-scale-adjust)

;;;; Icons
;; Check for icons FIXME: this should be less verbose but haven't been able to
;; get a `dolist` function working ¯\_(ツ)_/¯

;; nerd-icons uses a SINGLE patched font ("Symbols Nerd Font Mono")
;; rather than the six separate fonts all-the-icons shipped.
(defun lem-font--icon-check ()
  "Report whether the Nerd Font for `nerd-icons' glyphs is present.
Deliberately does NOT auto-install the font.  In a terminal the
glyphs are rendered by the terminal emulator's own font (e.g. a
Nerd Font configured in the terminal), not by Emacs.  A GUI frame
needs the font installed at the OS level -- run
`M-x nerd-icons-install-fonts' once, by hand."
  (cond ((lem-font-available-p "Symbols Nerd Font Mono")
         (message "Nerd Font for icons already installed!"))
        ((display-graphic-p)
         (message "GUI frame: run M-x nerd-icons-install-fonts to display icon glyphs."))
        (t
         (message "Terminal frame: icon glyphs render via the terminal font."))))

(defun lem-font--init-nerd-icons-fonts ()
  "Map the single Nerd Font for icon glyphs in GUI frames.
A no-op in a TTY, where the terminal font handles the glyphs."
  (when (and (display-graphic-p) (fboundp 'set-fontset-font))
    (set-fontset-font t 'unicode
                      (font-spec :family "Symbols Nerd Font Mono")
                      nil 'prepend)))

(use-package nerd-icons
  ;; nerd-icons renders in TTY frames, so -- unlike the old all-the-icons
  ;; gate -- this omits the (display-graphic-p) condition.
  :when (and lem-load-extras (locate-library "nerd-icons"))
  :commands (nerd-icons-octicon
             nerd-icons-faicon
             nerd-icons-mdicon
             nerd-icons-sucicon
             nerd-icons-wicon
             nerd-icons-codicon
             nerd-icons-devicon
             nerd-icons-flicon
             nerd-icons-icon-for-file
             nerd-icons-icon-for-dir
             nerd-icons-icon-for-mode)
  :init
  (add-hook 'after-setting-font-hook #'lem-font--icon-check)
  :custom
  ;; Adjust this as necessary per user font
  (nerd-icons-scale-factor 1.0)
  :config
  (add-hook 'after-setting-font-hook #'lem-font--init-nerd-icons-fonts))

;; icons for dired
(use-package nerd-icons-dired
  :when (and lem-load-extras (locate-library "nerd-icons-dired"))
  :defer t
  :commands nerd-icons-dired-mode
  :init
  (add-hook 'dired-mode-hook 'nerd-icons-dired-mode))

;; Completion Icons
(use-package nerd-icons-completion
  ;; On MELPA proper, so it installs through `lem-packages-alist' like
  ;; everything else -- no fork or package-vc-install hack needed.
  :when (and lem-load-extras (locate-library "nerd-icons-completion"))
  :hook (emacs-startup . nerd-icons-completion-mode)
  :config
  (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup))


(provide 'lem-setup-fonts)
;;; lem-setup-fonts.el ends here
