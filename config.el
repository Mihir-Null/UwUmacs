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

(setq doom-font (font-spec :family "GohuFont 14 Nerd Font Mono" :size 16.0 :weight 'medium))
(setq doom-variable-pitch-font (font-spec :family "GohuFont 14 Nerd Font Mono" :size 16.0 :weight 'medium))
(setq doom-big-font (font-spec :family "GohuFont 14 Nerd Font Mono" :size 16.0 :weight 'medium))
(use-package! nerd-icons
  :config
  (setq nerd-icons-font-family "GohuFont 14 Nerd Font Mono"))
(add-to-list 'initial-frame-alist '(fullscreen . maximized))
(add-to-list 'default-frame-alist '(internal-border-width . 8))

(after! doom-ui
  (window-divider-mode 1)
  (setq window-divider-default-right-width 2
        window-divider-default-bottom-width 2
        window-divider-default-places t))

(custom-set-faces!
  `(window-divider             :foreground ,(doom-color 'base4))
  `(window-divider-first-pixel :foreground ,(doom-color 'base4))
  `(window-divider-last-pixel  :foreground ,(doom-color 'base4))
  `(internal-border            :background ,(doom-color 'base4)))

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
  (defvar my/org-roam-extra-dirs
    '("~/vault/roam/qec")
    "Extra note directories folded into the global org-roam index.")
  (defun my/org-roam-extra-files ()
    "Return declared extra Org files for the global org-roam index."
    (delete-dups
     (mapcan
      (lambda (dir)
        (let ((expanded (expand-file-name dir)))
          (when (file-directory-p expanded)
            (directory-files-recursively expanded "\\.org\\'"))))
      my/org-roam-extra-dirs)))
  (defun my/org-roam-list-files-include-extra-dirs (files)
    "Append `my/org-roam-extra-dirs' to org-roam FILES."
    (delete-dups
     (append files (my/org-roam-extra-files))))
  (advice-remove 'org-roam-list-files
                 #'my/org-roam-list-files-include-extra-dirs)
  (advice-add 'org-roam-list-files :filter-return
              #'my/org-roam-list-files-include-extra-dirs)
  (setq org-roam-capture-templates
        '(("d" "default" plain
           (file "~/vault/metadata/org-roam-capture/default.org")
           :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+date: %U\n#+filetags:\n")
           :unnarrowed t)

          ("r" "research" plain
           (file "~/vault/metadata/org-roam-capture/research.org")
           :target (file+head "research/%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+date: %U\n#+filetags: :research:\n")
           :unnarrowed t)

          ("p" "paper" plain
           (file "~/vault/metadata/org-roam-capture/paper.org")
           :target (file+head "papers/%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+date: %U\n#+filetags: :paper:\n")
           :unnarrowed t)

          ("m" "meeting" plain
           (file "~/vault/metadata/org-roam-capture/meeting.org")
           :target (file+head "meetings/%<%Y%m%d>-${slug}.org"
                              "#+title: ${title}\n#+date: %U\n#+filetags: :meeting:\n")
           :unnarrowed t)

          ("c" "concept" plain
           (file "~/vault/metadata/org-roam-capture/concept.org")
           :target (file+head "concepts/${slug}.org"
                              "#+title: ${title}\n#+date: %U\n#+filetags: :concept:\n")
           :unnarrowed t)

          ("P" "project" plain
           (file "~/vault/metadata/org-roam-capture/project.org")
           :target (file+head "projects/${slug}.org"
                              "#+title: ${title}\n#+date: %U\n#+filetags: :project:\n")
           :unnarrowed t)

          ("C" "coursework" plain
           (file "~/vault/metadata/org-roam-capture/coursework.org")
           :target (file+head "coursework/%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+date: %U\n#+filetags: :coursework:\n")
           :unnarrowed t)

          ("l" "daily log" plain
           (file "~/vault/metadata/org-roam-capture/log.org")
           :target (file+head "log/%<%Y-%m-%d>.org"
                              "#+title: %<%Y-%m-%d %A>\n#+date: %U\n#+filetags: :log:\n")
           :unnarrowed t)

          ("t" "planning / booking" plain
           (file "~/vault/metadata/org-roam-capture/planning.org")
           :target (file+head "planning/%<%Y%m%d>-${slug}.org"
                              "#+title: ${title}\n#+date: %U\n#+filetags: :planning:\n")
           :unnarrowed t)

          ("w" "review" plain
           (file "~/vault/metadata/org-roam-capture/review.org")
           :target (file+head "reviews/%<%Y-%m-%d>-${slug}.org"
                              "#+title: ${title}\n#+date: %U\n#+filetags: :review:\n")
           :unnarrowed t)

          ("A" "annotation reading" plain
           (file "~/vault/metadata/org-roam-capture/annotation.org")
           :target (file+head "papers/%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+date: %U\n#+filetags: :annotation:reading:\n")
           :unnarrowed t)

          ("n" "person / contact" plain
           (file "~/vault/metadata/org-roam-capture/person.org")
           :target (file+head "people/${slug}.org"
                              "#+title: ${title}\n#+date: %U\n#+filetags: :person:\n")
           :unnarrowed t))))

(use-package! texfrag
  :hook ((markdown-mode . texfrag-mode)
         (rst-mode      . texfrag-mode)))

(use-package! org-fragtog
  :hook (org-mode . org-fragtog-mode))

(use-package! org-remark
  :after org
  :init
  (org-remark-global-tracking-mode +1)
  :config
  (setq org-remark-notes-file-name "~/vault/annotations.org")
  :bind (("C-c r m" . org-remark-mark)
         ("C-c r o" . org-remark-open)
         ("C-c r n" . org-remark-next)
         ("C-c r p" . org-remark-prev)
         ("C-c r d" . org-remark-delete)
         ("C-c r v" . org-remark-view)))

(use-package! claude-code-ide
  :bind ("C-c C-'" . claude-code-ide-menu) ; Set your favorite keybinding
  :config
  (claude-code-ide-emacs-tools-setup)) ; Optionally enable Emacs MCP tools

(load! "custom/vault-silos")

(use-package! evil-ghostel
  :after (ghostel evil)
  :hook (ghostel-mode . evil-ghostel-mode))

(use-package! indent-bars
  :custom
  (indent-bars-treesit-support t)
  (indent-bars-no-descend-lists t)
  (indent-bars-treesit-ignore-blank-lines-types '("module"))
  (indent-bars-treesit-scope '((python function_definition class_definition for_statement
                                if_statement with_statement while_statement)))
  (indent-bars-color-by-depth '(:palette ("red" "orange" "yellow" "green" "cyan" "blue" "violet") :blend 0.5))
  (indent-bars-highlight-current-depth '(:blend 0.7))
  :hook (prog-mode . indent-bars-mode))

(after! projectile
  (setq projectile-project-search-path '(("~/" . 4))))

(setq projectile-files-cache-expire 60)

;; ─── Agent-Shell ecosystem ────────────────────────────────────────────────────

(setq agent-shell-prefer-viewport-interaction t)

;; Notifications — init knockknock first so agent-shell-knockknock can depend on it
(use-package! knockknock
  :config
  (knockknock-init))

(use-package! agent-shell-knockknock
  :after (agent-shell knockknock)
  :hook (agent-shell-mode . agent-shell-knockknock-mode))

;; Session persistence across Emacs restarts
(use-package! agent-shell-desktop
  :after agent-shell
  :config
  (agent-shell-desktop-mode 1))

;; Unified workspace UI hub (replaces sidebar + manager + hud)
(use-package! agent-shell-workspace
  :after agent-shell
  :bind ("C-c a w" . agent-shell-workspace-toggle))

;; Transcript → vault org-roam nodes
;; Must load before agent-shell-tramp; tramp loads after so its path resolver
;; handles remote sessions without clobbering the org conversion for local ones.
(use-package! agent-shell-org-transcript
  :after agent-shell
  :config
  (setq agent-shell-org-transcript-directory
        (expand-file-name "agents-general/" org-roam-directory)))

;; Transcript search — extra-transcript-dirs bypasses the .agent-shell/transcripts
;; default path so agent-recall finds the org files written by org-transcript.
(use-package! agent-recall
  :after agent-shell
  :hook (agent-shell-mode . agent-recall-track-sessions)
  :config
  (setq agent-recall-extra-transcript-dirs
        (list (expand-file-name "agents-general/" org-roam-directory)))
  (global-agent-recall-transcript-mode 1))

;; Org-babel agent-shell source blocks
(use-package! ob-agent-shell
  :after (agent-shell org)
  :config
  (add-to-list 'org-babel-load-languages '(agent-shell . t))
  (org-babel-do-load-languages 'org-babel-load-languages
                                org-babel-load-languages))

;; Org-link type for live session buffers (supersedes agent-shell-bookmark's ol)
(use-package! agent-shell-links
  :demand t
  :config
  (agent-shell-links-bookmark-setup)
  (with-eval-after-load 'ol
    (org-link-set-parameters
     "agent-shell"
     :follow #'agent-shell-links-org-follow
     :store #'agent-shell-links-org-store)))

;; Multi-agent coordination — vault paths for heartbeat and logs
;; meta-agent-shell-start and meta-agent-shell-heartbeat-start are left to manual
;; invocation; add them here if you want them on every Emacs startup.
(use-package! meta-agent-shell
  :after agent-shell
  :config
  (setq meta-agent-shell-heartbeat-file
        (expand-file-name "roam/agents-general/meta-heartbeat.org" "~/vault/"))
  (setq meta-agent-shell-config-file
        (expand-file-name "roam/agents-general/meta-config.org" "~/vault/"))
  (setq meta-agent-shell-log-directory
        (expand-file-name ".agent-shell/meta-logs/" "~/vault/")))

;; TRAMP remote sessions — loads after org-transcript so its function override
;; takes priority for local sessions; TRAMP sessions use the tramp transcript dir.
(use-package! agent-shell-tramp
  :after (agent-shell acp agent-shell-org-transcript)
  :config
  (setq agent-shell-tramp-transcript-directory
        (expand-file-name ".agent-shell/transcripts/" "~"))
  (agent-shell-tramp-mode 1))

;; Slack remote control — set tokens via ~/.doom.d/.env; call
;; (agent-shell-to-go-setup) interactively once credentials are in place.
(use-package! agent-shell-to-go
  :after agent-shell
  :config
  (setq agent-shell-to-go-env-file (expand-file-name ".env" doom-user-dir))
  (setq agent-shell-to-go-todo-directory
        (expand-file-name "roam/inbox/" "~/vault/")))

;; AI code review
(use-package! agent-review
  :after (acp agent-shell))
