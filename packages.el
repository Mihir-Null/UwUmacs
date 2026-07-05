;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el

;; To install a package:
;;
;;   1. Declare them here in a `package!' statement,
;;   2. Run 'doom sync' in the shell,
;;   3. Restart Emacs.
;;
;; Use 'C-h f package\!' to look up documentation for the `package!' macro.


;; To install SOME-PACKAGE from MELPA, ELPA or emacsmirror:
;; (package! some-package)

;; To install a package directly from a remote git repo, you must specify a
;; `:recipe'. You'll find documentation on what `:recipe' accepts here:
;; https://github.com/radian-software/straight.el#the-recipe-format
;; (package! another-package
;;   :recipe (:host github :repo "username/repo"))

;; If the package you are trying to install does not contain a PACKAGENAME.el
;; file, or is located in a subdirectory of the repo, you'll need to specify
;; `:files' in the `:recipe':
;; (package! this-package
;;   :recipe (:host github :repo "username/repo"
;;            :files ("some-file.el" "src/lisp/*.el")))

;; If you'd like to disable a package included with Doom, you can do so here
;; with the `:disable' property:
;; (package! builtin-package :disable t)

;; You can override the recipe of a built in package without having to specify
;; all the properties for `:recipe'. These will inherit the rest of its recipe
;; from Doom or MELPA/ELPA/Emacsmirror:
;; (package! builtin-package :recipe (:nonrecursive t))
;; (package! builtin-package-2 :recipe (:repo "myfork/package"))

;; Specify a `:branch' to install a package from a particular branch or tag.
;; This is required for some packages whose default branch isn't 'master' (which
;; our package manager can't deal with; see radian-software/straight.el#279)
;; (package! builtin-package :recipe (:branch "develop"))

;; Use `:pin' to specify a particular commit to install.
;; (package! builtin-package :pin "1a2b3c4d5e")


;; Doom's packages are pinned to a specific commit and updated from release to
;; release. The `unpin!' macro allows you to unpin single packages...
;; (unpin! pinned-package)
;; ...or multiple packages
;; (unpin! pinned-package another-pinned-package)
;; ...Or *all* packages (NOT RECOMMENDED; will likely break things)
;; (unpin! t)
(package! evil-tutor)
(package! tldr)
;; nerd-icons, evil-surround, evil-commentary are provided by Doom's :ui doom and :editor (evil +everywhere) modules

;; Org-mode
(package! org-appear)        ; reveals /emphasis/ and *bold* markers only when cursor is on them
(package! org-modern)        ; cleaner org look — unicode bullets, prettier dates, styled keywords
(package! org-fragtog)       ; auto-previews LaTeX fragments in org when cursor leaves them
(package! org-roam-ui)
(package! org-remark)        ; annotate PDFs, webpages, and any text file with margin notes
(package! texfrag)           ; render LaTeX fragments in non-org buffers (text, markdown, etc.)

;; LaTeX / academic
(package! citar)             ; citation picker — integrates with org and LaTeX, works with .bib files

;; ws-butler and doom-themes are provided by Doom's :editor (whitespace +trim) and :ui doom modules

;; ghostel + evil integration (add :recipe if not on MELPA)
(package! ghostel)
(package! evil-ghostel)

;; Agentic coding
(package! claude-code-ide
  :recipe (:host github :repo "manzaltu/claude-code-ide.el"))
(package! shell-maker)
(package! acp)

;; agent-shell + ecosystem plugins
(package! agent-shell)

;; Skills for Claude Agent integration in Emacs (requires claude CLI on PATH)
(package! emacs-skills
  :recipe (:host github :repo "xenodium/emacs-skills"))

;; Mobile/remote: interact with agent-shell sessions from Slack
(package! agent-shell-to-go
  :recipe (:host github :repo "ElleNajt/agent-shell-to-go"))

;; UI
(package! indent-bars)
(package! agent-shell-sidebar
  :recipe (:host github :repo "cmacrae/agent-shell-sidebar"))
(package! agent-shell-hud
  :recipe (:host github :repo "nohzafk/agent-shell-hud"))

;; Session management
(package! agent-shell-bookmark
  :recipe (:host github :repo "dcluna/agent-shell-bookmark"))
(package! agent-shell-workspace
  :recipe (:host github :repo "gveres/agent-shell-workspace"))
(package! agent-shell-manager
  :recipe (:host github :repo "jethrokuan/agent-shell-manager"))
(package! agent-shell-desktop
  :recipe (:host github :repo "timfel/agent-shell-desktop.el"
           :files ("*.el")))

;; Notifications (knockknock is the dep)
(package! knockknock
  :recipe (:host github :repo "konrad1977/knockknock"))
(package! agent-shell-knockknock
  :recipe (:host github :repo "xenodium/agent-shell-knockknock"))

;; Multi-agent coordination
(package! meta-agent-shell
  :recipe (:host github :repo "ElleNajt/meta-agent-shell"))

;; Org integration
(package! ob-agent-shell              ; org-babel src blocks backed by agent-shell
  :recipe (:host github :repo "eddof13/ob-agent-shell"))
(package! agent-shell-org-transcript  ; save sessions as org-roam nodes
  :recipe (:host github :repo "lllShamanlll/agent-shell-org-transcript"))

;; Transcript search and resume
(package! agent-recall
  :recipe (:host github :repo "Marx-A00/agent-recall"))

;; TRAMP: run agent-shell over remote connections
(package! agent-shell-tramp
  :recipe (:host github :repo "junyi-hou/agent-shell-tramp"))

;; Code review interface
(package! agent-review
  :recipe (:host github :repo "nineluj/agent-review"))
