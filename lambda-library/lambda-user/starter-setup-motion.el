;;; starter-setup-motion.el --- Portable motion feedback -*- lexical-binding: t; -*-

;;; Commentary:
;; Firemacs animates Evil's scrolling in a terminal.  This adaptation instead
;; uses Emacs' pixel-scroll machinery for Meow keyboard motions, Ultra Scroll
;; for high-resolution mouse/trackpad input, and Pulsar for post-jump feedback.

;;; Code:

(require 'pixel-scroll)

(defgroup starter-motion nil
  "Smooth movement and visual location feedback."
  :group 'lambda-emacs)

(defcustom starter-motion-enable-ultra-scroll t
  "Whether to enable Ultra Scroll in graphical frames."
  :type 'boolean)

(defcustom starter-motion-enable-pulsar t
  "Whether to pulse the destination after discontinuous movement."
  :type 'boolean)

(defun starter-motion--interpolate (lines)
  "Pixel-scroll by LINES when possible, with a terminal-safe fallback."
  (if (display-graphic-p)
      (pixel-scroll-precision-interpolate lines nil 1)
    (if (< lines 0)
        (scroll-up-command (abs lines))
      (scroll-down-command lines))))

(defun starter-motion-scroll-half-page-down ()
  "Smoothly scroll down half a window."
  (interactive)
  (starter-motion--interpolate
   (- (max 1 (/ (window-text-height nil (display-graphic-p)) 2)))))

(defun starter-motion-scroll-half-page-up ()
  "Smoothly scroll up half a window."
  (interactive)
  (starter-motion--interpolate
   (max 1 (/ (window-text-height nil (display-graphic-p)) 2))))

(defun starter-motion-scroll-page-down ()
  "Smoothly scroll down one window."
  (interactive)
  (if (display-graphic-p)
      (pixel-scroll-interpolate-down)
    (scroll-up-command)))

(defun starter-motion-scroll-page-up ()
  "Smoothly scroll up one window."
  (interactive)
  (if (display-graphic-p)
      (pixel-scroll-interpolate-up)
    (scroll-down-command)))

(setopt pixel-scroll-precision-interpolate-page t
        pixel-scroll-precision-interpolate-mice t
        scroll-conservatively 3)

(defun starter-motion-enable-for-frame (&optional frame)
  "Enable the graphical scrolling backend for FRAME."
  (with-selected-frame (or frame (selected-frame))
    (when (display-graphic-p)
      (pixel-scroll-precision-mode 1)
      (when (and starter-motion-enable-ultra-scroll
                 (fboundp 'ultra-scroll-mode))
        (ultra-scroll-mode 1)))))

(use-package ultra-scroll
  :ensure t
  :if starter-motion-enable-ultra-scroll
  :config
  (starter-motion-enable-for-frame))

(add-hook 'after-make-frame-functions #'starter-motion-enable-for-frame)

(use-package pulsar
  :ensure t
  :if starter-motion-enable-pulsar
  :custom
  (pulsar-delay 0.045)
  (pulsar-iterations 6)
  :config
  (dolist (command '(avy-goto-char-timer
                     avy-goto-line
                     consult-goto-line
                     consult-imenu
                     consult-line
                     consult-mark
                     consult-ripgrep
                     meow-pop-to-mark
                     meow-unpop-to-mark
                     tab-bar-switch-to-next-tab
                     tab-bar-switch-to-prev-tab
                     tab-line-switch-to-next-tab
                     tab-line-switch-to-prev-tab
                     winner-undo
                     winner-redo))
    (add-to-list 'pulsar-pulse-functions command))
  (add-hook 'next-error-hook #'pulsar-pulse-line)
  (pulsar-global-mode 1))

(provide 'starter-setup-motion)
;;; starter-setup-motion.el ends here
