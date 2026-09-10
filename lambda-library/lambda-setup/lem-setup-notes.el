;;; lem-setup-notes.el --- packages for notes -*- lexical-binding: t -*-

;; Author: Colin McLear
;; Maintainer: Colin McLear
;; Homepage: https://codeberg.org/Lambda-Emacs/lambda-emacs
;; Keywords: convenience, notes


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

;; This library provides settings fora basic notes workflow using the `Denote' package.

;;; Code:

;;;; Notebook Setup

(defcustom lem-notes-dir nil
  "Set a directory path for notes."
  :group 'lambda-emacs
  :type 'string)

;;;; Denote
;; Simple and deliberate note-taking with Denote
;; https://github.com/protesilaos/denote
;; See also https://systemcrafters.net/live-streams/july-15-2022/

(use-package denote
  :when (and lem-load-extras (locate-library "denote"))
  :commands (denote denote-create-note denote-link-ol-store)
  :custom
  ;; Use org-read-date
  (denote-date-prompt-use-org-read-date t)
  (denote-file-type 'org) ;; use org
  (denote-allow-multi-word-keywords nil) ;; single word keywords only
  ;; Better backlink display
  (denote-link-backlinks-display-buffer-action
   (quote ((display-buffer-reuse-window
            display-buffer-in-side-window)
           (inhibit-same-window . t)
           (side . bottom)
           (slot . 99)
           (window-height . 10))))
  ;; Set default prompts for note creation
  (denote-prompts '(title keywords subdirectory))
  ;; Set multiple keywords as a list of strings
  (denote-known-keywords '("workbook" "project" "idea")))

;; Org-capture note creation with Denote
(with-eval-after-load 'org-capture
  (add-to-list 'org-capture-templates
               '("n" "New note (with Denote)" plain
                 (file denote-last-path)
                 #'denote-org-capture
                 :no-save t
                 :immediate-finish nil
                 :kill-buffer t
                 :jump-to-captured t)))

(defun lem-denote-capture-note ()
  "Create a new note with denote."
  (interactive)
  (org-capture nil "n"))

;; Example note creation function
(defun lem-insert-header-and-time-property ()
  "Insert an org heading with a created time string property."
  (interactive)
  (insert "* ")
  (org-set-property "CREATED" (format-time-string "[%Y-%m-%d %T]")))

(defun lem-denote-workbook-create-entry ()
  "Create an entry tagged \\='workbook\\=' with the date as its title.
Superseded by `lem-denote-log-entry' in the user layer, which writes into
log/ instead. Kept because old entries still live in workbook/."
  (interactive)
  (denote
   (format-time-string "%Y %A %e %B")   ; format like Tuesday 14 June 2022
   '("workbook")
   nil
   ;; `denote-directory' holds a list of trees, so the old
   ;; (concat denote-directory "workbook") is a type error here. The workbook
   ;; belongs to the notes tree, which denote returns as the first entry.
   (expand-file-name "workbook" (car (denote-directories)))
   nil
   nil)
  (lem-insert-header-and-time-property))



;;;; Citar-Denote
;; Integration of denote with citar
(use-package citar-denote
  :when (and lem-load-extras (locate-library "citar-denote"))
  :commands (citar-create-note
             citar-open-notes
             citar-denote-add-citekey)
  :config
  (citar-denote-mode))

;;;; Consult Notes
;; Adapted from https://github.com/minad/consult/wiki/hrm-notes
(use-package consult-notes
  :when (and lem-load-extras (locate-library "consult-notes"))
  :commands (consult-notes
             consult-notes-search-in-all-notes)
  :config
  ;; Without a source, consult-notes shows an empty picker. The denote
  ;; source lists everything under `denote-directory' (~/Documents/notes).
  (consult-notes-denote-mode 1))

(defun lem-notebook ()
  "Open `consult-notes in buffer window rather than minibuffer."
  (interactive)
  (let ((vertico-buffer-display-action
         '(display-buffer-reuse-window)))
    (consult-notes)))


;;; Provide Setup-Notes
(provide 'lem-setup-notes)
;;; lem-setup-notes.el ends here
