;;; lem-setup-keybindings.el --- summary -*- lexical-binding: t -*-

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

;; Keybindings for 𝛌-Emacs. This has its disadvantages (e.g. separating
;; functions or packages from keybindings) but it also makes it the place to go
;; to deal with all keybindings. I use `bind-key' for setting bindings, which
;; comes with `use-package'. All 𝛌-Emacs keybindings are under the prefix
;; specified by `lem-prefix'.

;;; Code:


;;;; Bind Key
;; Note that bind-key comes with use-package
(use-package bind-key
  :ensure nil
  :config
  (setq bind-key-describe-special-forms nil))

;;;; Personal Keybindings Prefix
(defcustom lem-prefix "C-c C-SPC"
  "Prefix for all personal keybinds."
  :type 'string
  :group 'lambda-emacs)

;;;; Personal Leader Key

(defcustom lem+leader-map (make-sparse-keymap)
  "An overriding keymap for <leader> key, for use with modal keybindings."
  :type 'string
  :group 'lambda-emacs)

;; Use lem-prefix as leader namespace
(bind-keys :prefix-map lem+leader-map
           :prefix lem-prefix)

;;;; Personal Keybindings by Group
;;;;; Buffer Keys
(bind-keys :prefix-map lem+buffer-keys
           :prefix (concat lem-prefix " b")
           ("a" . ibuffer)
           ("b" . consult-buffer)
           ("c" . lem-copy-whole-buffer-to-clipboard )
           ("d" . kill-buffer-and-window             )
           ("e" . lem-create-new-elisp-buffer        )
           ("E" . erase-buffer                       )
           ("f" . reveal-in-osx-finder               )
           ("i" . consult-imenu                      )
           ("j" . lem-jump-in-buffer                 )
           ("k" . lem-kill-this-buffer               )
           ("K" . crux-kill-other-buffers            )
           ("m" . consult-mark                       )
           ("M" . consult-global-mark                )
           ("n" . lem-create-new-buffer              )
           ("N" . lem-new-buffer-new-frame           )
           ("p" . consult-project-buffer             )
           ("r" . revert-buffer                      )
           ("R" . crux-rename-file-and-buffer        )
           ("s" . consult-buffer-other-window        )
           ("S" . lem-spelling-transient            )
           ("t" . tab-bar-new-tab                    )
           ("[" . lem-previous-user-buffer           )
           ("]" . lem-next-user-buffer               )
           ("{" . tab-bar-switch-to-prev-tab         )
           ("}" . tab-bar-switch-to-next-tab         )
           ("<backtab>" . crux-switch-to-previous-buffer))

;;;;; Comment Keybindings
(bind-keys :prefix-map lem+comment-wrap-keys
           :prefix (concat lem-prefix " c")
           ("c" . comment-dwim)
           ("d" . crux-duplicate-and-comment-current-line-or-region)
           ("l" . comment-line)
           ("o" . org-block-wrap)
           ("y" . lem-yaml-wrap))

;;;;; Config Keybindings
;; FIXME: fix goto functions to make them more generic
;; FIXME: fix kill-and-archive so that it creates an archive file
(bind-keys :prefix-map lem+config-keys
           :prefix (concat lem-prefix " C")
           ("a" . lem-setup-kill-and-archive-region     )
           ("c" . lem-goto-custom.el                    )
           ("d" . lem-goto-emacs-dir                    )
           ("e" . lem-goto-early-init.el                )
           ("f" . lem-find-lambda-file                  )
           ("l" . lem-load-config                       )
           ("i" . lem-goto-init.el                      )
           ("I" . lem-load-init-file                    )
           ("o" . lem-goto-org-files                    )
           ("s" . lem-search-lambda-files               ))

;;;;; Compile Keybindings
;; TODO: remove complile-next-makefile in favor of project compile?
(bind-keys :prefix-map lem+compile-keys
           :prefix (concat lem-prefix " M")
           ("m"  . compile                  )
           ("M"  . multi-compile-run        )
           ("e"  . compile-goto-error       )
           ("k"  . lem-compile-next-makefile)
           ("K"  . kill-compilation         )
           ("r"  . recompile                ))

;;;;; Eval Keybindings
(bind-keys :prefix-map lem+eval-keys
           :prefix (concat lem-prefix " e")
           ("b"  . eval-buffer )
           ("c"  . lem-eval-current-form)
           ("e"  . eval-last-sexp)
           ("f"  . eval-defun))

;;;;; File Keybindings
(bind-keys :prefix-map lem+file-keys
           :prefix (concat lem-prefix " f")
           ("b" . consult-bookmark                 )
           ("f" . find-file                        )
           ("l" . consult-locate                   )
           ("o" . crux-open-with                   )
           ("s" . save-buffer                      )
           ("r" . consult-recent-file              )
           ("y" . lem-show-and-copy-buffer-filename))

;;;;; Linting (Flymake)
(bind-keys :prefix-map lem+flymake-keys
           :prefix (concat lem-prefix " F"        )
           ("b" . flymake-start                   )
           ("c" . consult-flymake                 )
           ("d" . flymake-show-buffer-diagnostic  )
           ("p" . flymake-show-project-diagnostics)
           ("P" . package-lint-current-buffer     )
           ("u" . use-package-lint                ))

;;;;; Mail Keybindings
(bind-keys :prefix-map lem+mail-keys
           :prefix (concat lem-prefix " m")
           ("c" . mu4e-compose-new           )
           ("i" . cpm-go-to-mail-inbox       )
           ("k" . mu4e-kill-update-mail      )
           ("m" . cpm-open-email-in-workspace)
           ("s" . mu4e-update-mail-and-index )
           ("u" . cpm-go-to-mail-unread      ))

;;;;; Notes
;; General notes
(bind-keys :prefix-map lem+notes-keys
           :prefix (concat lem-prefix " n")
           ("d"  .  denote)
           ("n"  .  consult-notes)
           ("s"  .  consult-notes-search-in-all-notes)
           ("w"  .  lem-denote-workbook-create-entry))
;; Biblio notes
(bind-keys :prefix-map lem+bib-keys
           :prefix (concat lem-prefix " n b")
           ("a"  .  citar-denote-add-citekey)
           ("c"  .  citar-create-note)
           ("o"  .  citar-open-notes)
           ("O"  .  citar-denote-dwim))

;;;;; Quit Keybindings
(bind-keys :prefix-map lem+quit-keys
           :prefix (concat lem-prefix " q")
           ("d" . lem-kill-emacs-capture-daemon)
           ("q" . save-buffers-kill-emacs      )
           ("Q" . lem-kill-all-emacsen         )
           ("r" . restart-emacs                ))

;;;;; Spelling Keybindings
(bind-keys :prefix-map lem+spelling-keys
           :prefix (concat lem-prefix " S")
           ("b" . consult-flyspell          )
           ("h" . lem-spelling-transient    )
           ("n" . flyspell-correct-next     )
           ("p" . flyspell-correct-previous ))

;;;;; Search Keybindings
(bind-keys :prefix-map lem+search-keys
           :prefix (concat lem-prefix " s")
           ("a" . consult-org-agenda           )
           ;; search current buffer's directory
           ("d" . consult-ripgrep              )
           ;; search with directory input
           ("D" . lem-search-in-input-dir      )
           ("b" . multi-occur                  )
           ("f" . consult-line                 )
           ("h" . consult-org-heading          )
           ("j" . lem-forward-or-backward-sexp )
           ("k" . consult-yank-pop             )
           ("l" . vertico-repeat               )
           ("n" . consult-notes-search-in-all-notes)
           ("r" . vr/query-replace             )
           ("s" . consult-line                 )
           ;; search for next spelling error
           ("S" . lem-flyspell-ispell-goto-next-error)
           ("t" . lem-todo-transient           )
           ("." . consult-line-symbol-at-point ))

;;;;; Toggle Keybindings
(bind-keys :prefix-map lem+toggle-keys
           :prefix (concat lem-prefix " t")
           ("g" . git-gutter-mode             )
           ("d" . dired-sidebar-toggle-sidebar)
           ("e" . toggle-indicate-empty-lines )
           ("E" . eldoc-mode                  )
           ("F" . flymake-mode                )
           ("h" . hl-line-mode                )
           ("H" . hide-mode-line-mode         )
           ("m" . lem-toggle-display-markup   )
           ("n" . display-line-numbers-mode   )
           ("o" . imenu-list-smart-toggle     )
           ("p" . puni-global-mode            )
           ("P" . show-paren-mode             )
           ("r" . rainbow-identifiers-mode    )
           ("s" . flyspell-mode               )
           ("S" . ispell-buffer               )
           ("t" . toggle-dark-light-theme     )
           ("T" . lem-load-theme              )
           ("w" . writeroom-mode              )
           ("z" . zone                        ))

;;;;; User Keybindings
;; NOTE: This keymap is for user-specific keybindings. Define this in your
;; `config.el' file.
(bind-keys :prefix-map lem+user-keys
           :prefix (concat lem-prefix " u"))

;;;;; Version Control (Git) Keybindings
;; git-gutter is referenced by several bindings here but is not declared
;; in `lem-packages-alist'. Autoload the commands we bind so the keymap
;; entries are `commandp'-true even on a cold boot before the user
;; installs git-gutter; pressing the key without git-gutter installed
;; raises `file-missing' (not `void-function'), and once git-gutter is
;; on `package-user-dir' the autoload resolves the actual command.
(autoload 'git-gutter:popup-hunk    "git-gutter" "Show diff hunk in popup." t)
(autoload 'git-gutter:next-hunk     "git-gutter" "Move to next hunk."       t)
(autoload 'git-gutter:previous-hunk "git-gutter" "Move to previous hunk."   t)
(autoload 'git-gutter-mode          "git-gutter" "Toggle git-gutter-mode."  t)
(bind-keys :prefix-map  lem+vc-keys
           :prefix (concat lem-prefix " g")
           ("b" .  magit-blame                 )
           ("c" .  magit-commit                )
           ("d" .  magit-diff                  )
           ("h" .  git-gutter:popup-hunk       )
           ("l" .  magit-log                   )
           ;; show history of selected region
           ("L" .  magit-log-buffer-file       )
           ("n" .  git-gutter:next-hunk        )
           ("p" .  git-gutter:previous-hunk    )
           ;; quick commit file
           ("q" .  vc-next-action              )
           ("r" .  magit-reflog                )
           ("s" .  magit-status                ))

;;;;; Window Keybindings
(bind-keys :prefix-map lem+window-keys
           :prefix (concat lem-prefix " w")
           ("a" .  ace-window                      )
           ("f" .  lem-toggle-window-split         )
           ("c" .  delete-window                   )
           ("d" .  delete-window                   )
           ("h" .  lem-split-window-below-and-focus)
           ("H" .  split-window-below              )
           ("m" .  delete-other-windows            )
           ("o" .  lem-other-window                )
           ("r" .  lem-rotate-windows              )
           ("R" .  lem-rotate-windows-backward     )
           ("t" .  tear-off-window                 )
           ("u" .  winner-undo                     )
           ("U" .  winner-redo                     )
           ("v" .  lem-split-window-right-and-focus)
           ("V" .  split-window-right              )
           ("w" .  ace-window                      )
           ("x" .  lem-window-exchange-buffer      )
           ("-" .  split-window-below              )
           ("_" .  lem-split-window-below-and-focus))

;;;;; Workspace Keybindings
(bind-keys :prefix-map lem+workspace-keys
           :prefix (concat lem-prefix " W")
           ("b"  .  tabspaces-switch-to-buffer)
           ("c"  .  tabspaces-clear-buffers)
           ("d"  .  tabspaces-close-workspace)
           ("k"  .  tabspaces-kill-buffers-close-workspace)
           ("o"  .  tabspaces-open-or-create-project-and-workspace)
           ("p"  .  tabspaces-project-switch-project-open-file)
           ("r"  .  tabspaces-remove-current-buffer)
           ("R"  .  tabspaces-remove-selected-buffer)
           ("s"  .  tabspaces-switch-or-create-workspace))

;;;; Which Key (built-in baseline)
;; EMACS-29+ built-in (which-key was merged into Emacs core in 29,
;; not 28). Raw top-level baseline -- C-6 forbids use-package
;; wrapping of built-in baselines. `which-key-mode' is autoloaded
;; in Emacs 29+, so the bare call resolves without an explicit
;; require.
(setq which-key-show-early-on-C-h t)
(setq which-key-idle-delay 0.75)
(setq which-key-idle-secondary-delay 0.05)
(setq which-key-popup-type 'side-window)
(setq which-key-side-window-max-height 0.5)
(setq which-key-allow-imprecise-window-fit nil)
(setq which-key-side-window-location 'top)
;; ASCII separator. Was U+2192 RIGHTWARDS ARROW; CLAUDE.md forbids
;; multi-byte Unicode in source files (AC-8 byte-vs-char check).
(setq which-key-separator " -> ")
(which-key-mode 1)

;;;; Hydras

;;;; Ediff transient
;; Adapted from the hydra wiki (Emacs#ediff section), ported to
;; transient in Spec 09.
;; Body color was blue (exit on every suffix); :hint nil meant the
;; freeform tabular docstring was the entire UI -- replaced here by
;; transient's standard column groups.

(transient-define-prefix lem-ediff-transient ()
  "Launch an ediff session."
  ["Ediff"
   ["Buffers"
    ("b" "Buffers"          ediff-buffers)
    ("B" "Buffers (3-way)"  ediff-buffers3)
    ("c" "Current file"     ediff-current-file)]
   ["Files"
    ("=" "Files"            ediff-files)
    ("f" "Files"            ediff-files)
    ("F" "Files (3-way)"    ediff-files3)]
   ["VC"
    ("r" "Revisions"        ediff-revision)]
   ["Regions"
    ("l" "Linewise"         ediff-regions-linewise)
    ("w" "Wordwise"         ediff-regions-wordwise)]])

;;;;; Transpose
;; <leader> . binds `transpose-words' (the most common case).
;; `transpose-chars', `transpose-lines', `transpose-sentences',
;; `transpose-paragraphs', `org-transpose-words',
;; `org-transpose-element', and `org-table-transpose-table-at-point'
;; remain accessible via M-x. Spec 09 dropped a wrapping menu; see git
;; history for the prior dispatch macro.
(bind-key (concat lem-prefix " .") #'transpose-words)

;;;;; Rectangle transient
;; Suffixes stay on press; "g" exits. Setup/teardown:
;; `rectangle-mark-mode' is enabled on entry, `deactivate-mark' fires
;; on every exit path via a one-shot `transient-exit-hook'. Ported in
;; Spec 09 -- see git history for the prior macro-based dispatch
;; implementation including its ASCII-art docstring.

(defun lem-rectangle-toggle-region ()
  "Toggle `rectangle-mark-mode' based on current region state.
Used by `lem-rectangle-transient' as the \"r\" suffix; replaces
an inline branching lambda from the prior implementation."
  (interactive)
  (if (region-active-p)
      (deactivate-mark)
    (rectangle-mark-mode 1)))

(transient-define-prefix lem-rectangle-transient ()
  "Rectangle editing."
  ["Rectangle"
   ["Move"
    ("k" "Up"    rectangle-previous-line :transient t)
    ("j" "Down"  rectangle-next-line     :transient t)
    ("h" "Left"  rectangle-backward-char :transient t)
    ("l" "Right" rectangle-forward-char  :transient t)]
   ["Edit"
    ("d" "Kill"   kill-rectangle           :transient t)
    ("y" "Yank"   yank-rectangle           :transient t)
    ("w" "Copy"   copy-rectangle-as-kill   :transient t)
    ("o" "Open"   open-rectangle           :transient t)
    ("t" "Type"   string-rectangle         :transient t)
    ("c" "Clear"  clear-rectangle          :transient t)]
   ["Mark"
    ("e" "Exchange"     rectangle-exchange-point-and-mark :transient t)
    ("N" "Number lines" rectangle-number-lines            :transient t)
    ("r" "Toggle region" lem-rectangle-toggle-region      :transient t)]
   [""
    ("u" "Undo" undo                :transient t)
    ("g" "Quit" transient-quit-one)]]
  (interactive)
  (rectangle-mark-mode 1)
  (let (cleanup)
    (setq cleanup
          (lambda ()
            (when (region-active-p)
              (deactivate-mark))
            (remove-hook 'transient-exit-hook cleanup)))
    (add-hook 'transient-exit-hook cleanup))
  (transient-setup 'lem-rectangle-transient))

;; TODO: Add org and markdown keybindings
;;; End keybindings
(provide 'lem-setup-keybindings)

;;; lem-setup-keybindings.el ends here
