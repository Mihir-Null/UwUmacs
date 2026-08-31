;;; early-config.el --- Early user policy -*- lexical-binding: t; -*-

;;; Commentary:
;; Keep this deliberately small. Lambda's `early-init.el' owns package archives,
;; writable directories, and the bulk of startup policy.

;;; Code:

;; Let `use-package' install packages requested by the modules we enable.
;; On Nix this intentionally means: Nix owns Emacs/external executables initially,
;; while Lambda/package.el owns Elisp. Change this only when you deliberately move
;; package ownership into Nix.
(setopt lem-package-ensure-packages t)

;; Warnings are useful while learning. Do not inherit Colin's personal choice to
;; suppress nearly all startup warnings.
(setopt warning-minimum-level :warning)

;;;; Native Windows frame geometry
;; FancyWM and similar Windows tilers assign windows exact pixel rectangles.
;; Native Emacs otherwise advertises character-grid sizing hints and may round
;; externally requested frame sizes.  This must be decided before the graphical
;; frame is created, which is why it belongs in early-config.el.
(when (eq system-type 'windows-nt)
  (setq frame-resize-pixelwise t
        window-resize-pixelwise t)

  ;; Emacs 29+ uses double-buffered rendering on Windows.  It is normally a
  ;; visual improvement, but can produce stale/fragmented regions during rapid
  ;; external resize/reposition cycles.  Prefer correctness under a tiling WM.
  (add-to-list 'default-frame-alist '(inhibit-double-buffering . t))
  (add-to-list 'initial-frame-alist '(inhibit-double-buffering . t)))

(provide 'early-config)
;;; early-config.el ends here
