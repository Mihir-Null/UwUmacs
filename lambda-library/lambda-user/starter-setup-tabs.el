;;; starter-setup-tabs.el --- Firemacs-style grouped buffer strip -*- lexical-binding: t; -*-

;;; Commentary:
;; Recreate Firemacs' per-window, grouped, MRU-oriented buffer strip with Emacs
;; 30's built-in tab-line.  Lambda's tab-bar/tabspaces remain the separate,
;; canonical project/workspace layer.

;;; Code:

(require 'seq)
(require 'subr-x)
(require 'tab-line)

(defgroup starter-tabs nil
  "Grouped buffer tabs layered under Lambda workspaces."
  :group 'starter-ui)

(defcustom starter-tabs-enable-buffer-strip t
  "Whether to display grouped buffer tabs in each editing window."
  :type 'boolean)

(defcustom starter-tabs-name-width 24
  "Maximum displayed width of a buffer tab name."
  :type 'natnum)

(defun starter-tabs-buffer-group (&optional buffer)
  "Return the Firemacs-style group name for BUFFER."
  (with-current-buffer (or buffer (current-buffer))
    (cond
     ((derived-mode-p 'dired-mode 'magit-mode 'help-mode 'Info-mode
                      'compilation-mode 'special-mode)
      "Tools")
     ((derived-mode-p 'eshell-mode 'shell-mode 'term-mode 'comint-mode)
      "Terminal")
     ((derived-mode-p 'conf-mode)
      "Config")
     ((derived-mode-p 'org-mode 'markdown-mode 'text-mode)
      "Docs")
     ((derived-mode-p 'prog-mode)
      "Code")
     (t "Buffers"))))

(defun starter-tabs--visible-buffer-p (buffer)
  "Return non-nil when BUFFER belongs in the visible tab strip."
  (and (buffer-live-p buffer)
       (not (string-prefix-p " " (buffer-name buffer)))
       (not (member (buffer-name buffer) '("*Messages*" "*Completions*")))
       (or (not (bound-and-true-p tabspaces-mode))
           (not (fboundp 'tabspaces--local-buffer-p))
           (tabspaces--local-buffer-p buffer))))

(defun starter-tabs-buffer-list ()
  "Return visible buffers in Emacs' most-recently-used order."
  (seq-filter #'starter-tabs--visible-buffer-p (buffer-list)))

(defun starter-tabs-tab-name (buffer &optional _buffers)
  "Return a compact, tooltip-bearing label for BUFFER."
  (with-current-buffer buffer
    (let* ((full-name (buffer-name buffer))
           (name (truncate-string-to-width
                  full-name starter-tabs-name-width nil nil "…"))
           (modified (if (buffer-modified-p buffer) " ●" ""))
           (icon (when (and (fboundp 'starter-ui-icons-available-p)
                            (starter-ui-icons-available-p)
                            (fboundp 'nerd-icons-icon-for-buffer))
                   (concat (nerd-icons-icon-for-buffer) " "))))
      (propertize (format " %s%s%s " (or icon "") name modified)
                  'help-echo (or buffer-file-name full-name)))))

(when starter-tabs-enable-buffer-strip
  (setopt tab-line-tabs-function #'tab-line-tabs-buffer-groups
          tab-line-tabs-buffer-list-function #'starter-tabs-buffer-list
          tab-line-tabs-buffer-group-function #'starter-tabs-buffer-group
          ;; `buffer-list' already supplies MRU order; do not alphabetize it.
          tab-line-tabs-buffer-group-sort-function nil
          tab-line-tabs-buffer-groups-sort-function nil
          tab-line-tab-name-function #'starter-tabs-tab-name
          tab-line-close-button-show nil
          tab-line-new-button-show nil
          tab-line-switch-cycling t)

  (add-to-list 'tab-line-exclude-modes 'completion-list-mode)
  (global-tab-line-mode 1)

  ;; Standard cross-platform tab cycling, including Windows GUI events.
  (global-set-key (kbd "C-<tab>") #'tab-line-switch-to-next-tab)
  (global-set-key (kbd "C-S-<tab>") #'tab-line-switch-to-prev-tab)
  (global-set-key (kbd "C-<iso-lefttab>") #'tab-line-switch-to-prev-tab))

(when (fboundp 'starter-ui-apply-firemacs-faces)
  (starter-ui-apply-firemacs-faces))

(provide 'starter-setup-tabs)
;;; starter-setup-tabs.el ends here
