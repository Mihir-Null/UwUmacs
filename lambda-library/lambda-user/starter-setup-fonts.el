;;; starter-setup-fonts.el --- Fonts before dashboard rendering -*- lexical-binding: t; -*-

;;; Commentary:
;; Resolve fonts before dashboard and icon consumers initialize.  Keep Nerd
;; glyph mappings confined to the ranges maintained by nerd-icons.

;;; Code:

(require 'seq)

(defgroup starter-ui nil
  "Presentation defaults for the Lambda learning configuration."
  :group 'lambda-emacs)

(defcustom starter-ui-font-family "GoogleSansCode Nerd Font"
  "Preferred editing font family; retain the platform default if absent."
  :type 'string)

(defcustom starter-ui-icons 'auto
  "Whether to render Nerd Font icons.
With `auto', require a graphical frame and an installed icon font.
Use t for a terminal configured with a Nerd Font, or nil to disable icons."
  :type '(choice (const auto) (const t) (const nil)))

(defcustom starter-ui-nerd-font "Symbols Nerd Font Mono"
  "Font family used for Nerd Icons."
  :type 'string)

(defun starter-ui-resolve-font-family ()
  "Resolve the requested editing font, including its Windows family alias."
  (when (display-graphic-p)
    (seq-find
     (lambda (family) (find-font (font-spec :family family)))
     (if (equal starter-ui-font-family "GoogleSansCode Nerd Font")
         (list starter-ui-font-family "GoogleSansCode NF")
       (list starter-ui-font-family)))))

(defun starter-ui-font-available-p ()
  "Return non-nil when the requested editing font is installed."
  (and (starter-ui-resolve-font-family) t))

(defun starter-ui-icons-available-p ()
  "Return non-nil when the starter should render Nerd Font icons."
  (pcase starter-ui-icons
    ('t t)
    ('nil nil)
    ('auto (and (display-graphic-p)
                (find-font (font-spec :family starter-ui-nerd-font))
                t))))

(defun starter-ui-apply-icon-font (&optional frame)
  "Map Nerd glyph ranges to the configured font in graphical FRAME."
  (with-selected-frame (or frame (selected-frame))
    (when (and (display-graphic-p)
               (starter-ui-icons-available-p)
               (find-font (font-spec :family starter-ui-nerd-font)))
      (nerd-icons-set-font starter-ui-nerd-font (selected-frame)))))

(defun starter-ui-apply-font (&optional frame)
  "Apply the editing and icon fonts to FRAME, preserving the point size."
  (with-selected-frame (or frame (selected-frame))
    (when (display-graphic-p)
      (when-let* ((family (starter-ui-resolve-font-family)))
        (setopt lem-ui-default-font (list :family family))
        ;; The Custom setter skips unchanged values; new daemon frames still
        ;; need the requested family even when another frame set it earlier.
        (set-face-attribute 'default (selected-frame) :family family))
      (starter-ui-apply-icon-font))))

(require 'nerd-icons)
(setq nerd-icons-font-family starter-ui-nerd-font)

;; Lambda's deferred hook prepends the icon font for all Unicode.  Replace it
;; before setting the editing font, and use nerd-icons' own specific ranges.
(remove-hook 'after-setting-font-hook #'lem-font--init-nerd-icons-fonts)
(add-hook 'after-setting-font-hook #'starter-ui-apply-icon-font)
(add-hook 'after-make-frame-functions #'starter-ui-apply-font)
(starter-ui-apply-font)

(provide 'starter-setup-fonts)
;;; starter-setup-fonts.el ends here
