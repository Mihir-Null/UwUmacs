;;; uwumacs-dired.el --- The file manager -*- lexical-binding: t; -*-
;; Generated from literate/64-dired.org; edit the Org source, then tangle.

;; Distilled from Lambda-Emacs by Colin McLear (GPL-3.0-or-later).

;;; Code:

(require 'uwumacs-leader)
(require 'uwumacs-ui)
(setopt dired-kill-when-opening-new-dired-buffer t
        dired-recursive-copies 'always
        dired-recursive-deletes 'always
        dired-dwim-target t
        dired-ls-F-marks-symlinks t
        dired-clean-confirm-killing-deleted-buffers nil
        dired-create-destination-dirs 'ask
        wdired-allow-to-change-permissions t)

(if (eq system-type 'windows-nt)
    (setopt ls-lisp-use-insert-directory-program nil
            ls-lisp-dirs-first t
            dired-listing-switches "-lah")
  (setopt dired-listing-switches
          (if (eq system-type 'gnu/linux) "-lahv --group-directories-first" "-lah")))

(defun uwumacs-dired-up-directory ()
  "Go to the parent directory in this buffer."
  (interactive)
  (find-alternate-file ".."))

(with-eval-after-load 'dired
  (keymap-set dired-mode-map "h" #'uwumacs-dired-up-directory)
  (keymap-set dired-mode-map "l" #'dired-find-file))
(use-package diredfl
  :ensure t
  :hook (dired-mode . diredfl-mode))

(use-package dired-narrow
  :ensure t
  :bind (:map dired-mode-map
         ("/" . dired-narrow)))

(use-package dired-ranger
  :ensure t
  :after dired
  :commands (dired-ranger-copy dired-ranger-move dired-ranger-paste))

(use-package async
  :ensure t
  :after dired
  :config
  (dired-async-mode 1))
(use-package dired-sidebar
  :ensure t
  :commands (dired-sidebar-toggle-sidebar dired-sidebar-show-sidebar)
  :custom
  (dired-sidebar-width 36)
  (dired-sidebar-resize-on-open t)
  (dired-sidebar-should-follow-file t)
  (dired-sidebar-theme (if (uwumacs-icons-available-p) 'nerd-icons 'ascii))
  :config
  (with-eval-after-load 'meow
    (add-to-list 'meow-mode-state-list '(dired-sidebar-mode . motion))))
(with-eval-after-load 'meow
  (add-to-list 'meow-mode-state-list '(dired-mode . motion)))

(uwumacs-define-localleader 'dired-mode
  "c" (cons "copy" #'dired-do-copy)
  "r" (cons "rename / move" #'dired-do-rename)
  "d" (cons "delete" #'dired-do-delete)
  "m" (cons "mark" #'dired-mark)
  "u" (cons "unmark" #'dired-unmark)
  "U" (cons "unmark all" #'dired-unmark-all-marks)
  "t" (cons "toggle marks" #'dired-toggle-marks)
  "+" (cons "new directory" #'dired-create-directory)
  "n" (cons "new file" #'dired-create-empty-file)
  "/" (cons "narrow" #'dired-narrow)
  "w" (cons "edit names (wdired)" #'wdired-change-to-wdired-mode)
  "y" (cons "copy to clipboard" #'dired-ranger-copy)
  "p" (cons "paste" #'dired-ranger-paste)
  "P" (cons "move here" #'dired-ranger-move)
  "s" (cons "sort" #'dired-sort-toggle-or-edit)
  "!" (cons "shell command" #'dired-do-shell-command)
  "z" (cons "compress" #'dired-do-compress-to)
  "(" (cons "toggle details" #'dired-hide-details-mode)
  "g" (cons "refresh" #'revert-buffer)
  "?" (cons "menu" #'casual-dired-tmenu))

(provide 'uwumacs-dired)
;;; uwumacs-dired.el ends here
