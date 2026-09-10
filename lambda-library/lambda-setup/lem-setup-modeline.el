;;; lem-setup-modeline.el --- summary -*- lexical-binding: t -*-

;; Author: Colin McLear
;; This file is not part of GNU Emacs

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.


;;; Commentary:

;; Setup for modeline.

;;; Code:

;;;; Lambda Line
(use-package lambda-line
  ;; :vc form pinned to the Lambda-Emacs/lambda-line v0.5.0 tag on
  ;; Codeberg. That release adds optional nerd-icons prefix glyphs and
  ;; fixes the clock icon appearing without opt-in (issue #30), the
  ;; visual bell repaint/restore, and a pdf-view nil funcall. It still
  ;; carries the colored git diff counts, the built-in evil state
  ;; indicator, and the earlier all-the-icons fix (0ca6b32 dropped an
  ;; unused all-the-icons require + Package-Requires entry). Without
  ;; this pin, a user running lambda-line on a host
  ;; without all-the-icons installed would crash at load time even
  ;; with the locate-library gate, because earlier commits of
  ;; lambda-line had an unconditional (require 'all-the-icons) at
  ;; top-level.
  ;;
  :when lem-load-extras
  :vc (:url "https://codeberg.org/Lambda-Emacs/lambda-line"
       :rev "v0.5.0")
  :custom
  (lambda-line-abbrev t)
  (lambda-line-position 'top)
  (lambda-line-hspace "  ")
  (lambda-line-prefix t)
  (lambda-line-prefix-padding nil)
  (lambda-line-status-invert nil)
  (lambda-line-gui-ro-symbol  " ⨂")  ;; ⬤◯⨂ⓧ
  (lambda-line-gui-mod-symbol " ⬤") ;; ⨀⬤ ◉
  (lambda-line-gui-rw-symbol  " ◯")  ;; ◉ ◎ ⬤◯
  (lambda-line-vc-symbol "⎇ ")  ;; Git branch symbol
  (lambda-line-space-top +.50)
  (lambda-line-space-bottom -.50)
  (lambda-line-symbol-position 0.1)
  (lambda-line-word-count-enabled t)
  :custom-face
  (lambda-line-visual-bell ((t (:background "red3"))))
  :config
  (lambda-line-mode)
  (lambda-line-visual-bell-config)
  ;; lem-setup-modeline runs before lem-setup-theme in the base
  ;; module batch, so `(lambda-line-mode)' caches its formats with
  ;; default faces -- before lambda-themes' face overrides have
  ;; been applied by the macOS system-appearance dispatch in
  ;; lem-setup-theme.el. On a daemon there's no frame redisplay
  ;; between the two events, so the first connecting client sees
  ;; the stale state (modeline at the bottom in default colours).
  ;; Re-toggle on every theme load -- including the initial system
  ;; apply and every macOS Light/Dark flip -- so the cache rebuilds
  ;; against the now-current theme.
  (add-hook 'lem-after-load-theme-hook
            (lambda ()
              (when (bound-and-true-p lambda-line-mode)
                (lambda-line-mode -1)
                (lambda-line-mode 1)))))

;;;; Hide Modeline
(use-package hide-mode-line
  :when (and lem-load-extras (locate-library "hide-mode-line"))
  :commands hide-mode-line-mode)

;;; Provide:
(provide 'lem-setup-modeline)
;;; lem-setup-modeline.el ends here
