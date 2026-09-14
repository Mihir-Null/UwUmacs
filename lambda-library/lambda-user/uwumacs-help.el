;;; uwumacs-help.el --- Help, Info and menus -*- lexical-binding: t; -*-
;; Generated from literate/62-help.org; edit the Org source, then tangle.

;; Distilled from Lambda-Emacs by Colin McLear (GPL-3.0-or-later).

;;; Code:

(require 'uwumacs-defaults)
(require 'uwumacs-leader)

(setopt use-file-dialog nil
        use-dialog-box nil
        confirm-nonexistent-file-or-buffer nil
        help-window-select t
        help-at-pt-timer-delay 0.1
        help-at-pt-display-when-idle '(flymake-diagnostic))
(menu-bar-mode -1)
(use-package helpful
  :ensure t
  :bind (([remap display-local-help] . helpful-at-point)
         ([remap describe-function] . helpful-callable)
         ([remap describe-variable] . helpful-variable)
         ([remap describe-symbol] . helpful-symbol)
         ([remap describe-key] . helpful-key)
         ([remap describe-command] . helpful-command)
         ("C-h C-l" . find-library)
         ("C-h C-c" . finder-commentary)))

(use-package elisp-demos
  :ensure t
  :after helpful
  :config
  (advice-add 'helpful-update :after #'elisp-demos-advice-helpful-update))

(use-package info-colors
  :ensure t
  :hook (Info-selection . info-colors-fontify-node))
(use-package transient
  :ensure nil
  :defer t
  :custom
  (transient-levels-file (expand-file-name "transient/levels.el" uwumacs-cache-dir))
  (transient-values-file (expand-file-name "transient/values.el" uwumacs-cache-dir))
  (transient-history-file (expand-file-name "transient/history.el" uwumacs-cache-dir))
  (transient-detect-key-conflicts t)
  (transient-force-fixed-pitch t)
  (transient-display-buffer-action '(display-buffer-in-side-window
                                     (side . top)
                                     (dedicated . t)
                                     (inhibit-same-window . t)
                                     (window-parameters (no-other-window . t)))))
(defvar-keymap uwumacs-help-map
  :doc "Help, documentation and tutorials."
  "h" (cons "home" #'dashboard-open)
  "k" (cons "key" #'helpful-key)
  "f" (cons "function" #'helpful-callable)
  "v" (cons "variable" #'helpful-variable)
  "o" (cons "symbol" #'helpful-symbol)
  "c" (cons "command" #'helpful-command)
  "." (cons "at point" #'helpful-at-point)
  "m" (cons "mode" #'describe-mode)
  "b" (cons "bindings here" #'embark-bindings)
  "B" (cons "all bindings" #'describe-bindings)
  "l" (cons "leader" #'uwumacs-describe-leader)
  "F" (cons "face" #'describe-face)
  "w" (cons "where is" #'where-is)
  "e" (cons "messages" #'view-echo-area-messages)
  "L" (cons "lossage" #'view-lossage)
  "i" (cons "info" #'info)
  "s" (cons "search manuals" #'uwumacs-search-manuals)
  "S" (cons "find source" #'find-function)
  "V" (cons "find variable" #'find-variable)
  "K" (cons "find key" #'find-function-on-key)
  "t" (cons "meow tutor" #'meow-tutor)
  "C" (cons "meow cheatsheet" #'meow-cheatsheet))
(uwumacs-define-localleader 'Info-mode
  "n" (cons "next node" #'Info-next)
  "p" (cons "previous node" #'Info-prev)
  "u" (cons "up" #'Info-up)
  "t" (cons "top" #'Info-top-node)
  "d" (cons "directory" #'Info-directory)
  "g" (cons "go to node" #'Info-goto-node)
  "i" (cons "index" #'Info-index)
  "s" (cons "search" #'Info-search)
  "m" (cons "menu" #'Info-menu)
  "l" (cons "back" #'Info-history-back)
  "r" (cons "forward" #'Info-history-forward))

(uwumacs-define-localleader 'help-mode
  "l" (cons "back" #'help-go-back)
  "r" (cons "forward" #'help-go-forward)
  "s" (cons "source" #'help-view-source)
  "i" (cons "info" #'help-goto-info))

(with-eval-after-load 'helpful
  (uwumacs-define-localleader 'helpful-mode
    "u" (cons "update" #'helpful-update)
    "s" (cons "source" #'helpful-visit-reference)))

(provide 'uwumacs-help)
;;; uwumacs-help.el ends here
