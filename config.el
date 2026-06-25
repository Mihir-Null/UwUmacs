;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

(setq doom-font (font-spec :family "GohuFont 14 Nerd Font Mono" :size 16.0))
(setq doom-variable-pitch-font (font-spec :family "GohuFont 14 Nerd Font" :size 16.0))
(setq doom-big-font (font-spec :family "GohuFont 11 Nerd Font" :size 16.0))
(use-package! nerd-icons
	      :config
	      (setq nerd-icons-font-family "GohuFont 11 Nerd Font Mono"))
;;(add-to-list 'initial-frame-alist '(fullscreen . maximized))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-dark+)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type `relative)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/vault/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `with-eval-after-load' block, otherwise Doom's defaults may override your
;; settings. E.g.
;;
;;   (with-eval-after-load 'PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look them up).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

(after! org-roam
  (setq org-roam-directory "~/vault/roam/")
  (setq org-roam-capture-templates
        '(("d" "default" plain
           (file "~/vault/templates/roam/default.org")
           :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+date: %U\n#+filetags:\n")
           :unnarrowed t)

          ("r" "research" plain
           (file "~/vault/templates/roam/research.org")
           :target (file+head "research/%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+date: %U\n#+filetags: :research:\n")
           :unnarrowed t)

          ("p" "paper" plain
           (file "~/vault/templates/roam/paper.org")
           :target (file+head "papers/%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+date: %U\n#+filetags: :paper:\n")
           :unnarrowed t)

          ("m" "meeting" plain
           (file "~/vault/templates/roam/meeting.org")
           :target (file+head "meetings/%<%Y%m%d>-${slug}.org"
                              "#+title: ${title}\n#+date: %U\n#+filetags: :meeting:\n")
           :unnarrowed t)

          ("c" "concept" plain
           (file "~/vault/templates/roam/concept.org")
           :target (file+head "concepts/${slug}.org"
                              "#+title: ${title}\n#+date: %U\n#+filetags: :concept:\n")
           :unnarrowed t)

          ("P" "project" plain
           (file "~/vault/templates/roam/project.org")
           :target (file+head "projects/${slug}.org"
                              "#+title: ${title}\n#+date: %U\n#+filetags: :project:\n")
           :unnarrowed t)

          ("C" "coursework" plain
           (file "~/vault/templates/roam/coursework.org")
           :target (file+head "coursework/%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+date: %U\n#+filetags: :coursework:\n")
           :unnarrowed t)

          ("l" "daily log" plain
           (file "~/vault/templates/roam/log.org")
           :target (file+head "log/%<%Y-%m-%d>.org"
                              "#+title: %<%Y-%m-%d %A>\n#+date: %U\n#+filetags: :log:\n")
           :unnarrowed t)

          ("t" "planning / booking" plain
           (file "~/vault/templates/roam/planning.org")
           :target (file+head "planning/%<%Y%m%d>-${slug}.org"
                              "#+title: ${title}\n#+date: %U\n#+filetags: :planning:\n")
           :unnarrowed t)

          ("w" "review" plain
           (file "~/vault/templates/roam/review.org")
           :target (file+head "reviews/%<%Y-%m-%d>-${slug}.org"
                              "#+title: ${title}\n#+date: %U\n#+filetags: :review:\n")
           :unnarrowed t)

          ("n" "person / contact" plain
           (file "~/vault/templates/roam/person.org")
           :target (file+head "people/${slug}.org"
                              "#+title: ${title}\n#+date: %U\n#+filetags: :person:\n")
           :unnarrowed t))))

(use-package! claude-code-ide
	:bind ("C-c C-'" . claude-code-ide-menu) ; Set your favorite keybinding
	:config
	(claude-code-ide-emacs-tools-setup)) ; Optionally enable Emacs MCP tools

(use-package evil-ghostel
	     :after (ghostel evil)
	     :hook (ghostel-mode . evil-ghostel-mode))
