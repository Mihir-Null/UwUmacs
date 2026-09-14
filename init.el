;;; init.el --- UwUmacs -*- lexical-binding: t; -*-
;; Generated from literate/10-startup.org; edit the Org source, then tangle.

;;; Code:

(add-to-list 'load-path uwumacs-lisp-dir)
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))
(require 'use-package)
(setopt use-package-enable-imenu-support t)

;; Foundation: defaults, platform paths, machine overrides, the look.
(require 'uwumacs-defaults)
(require 'uwumacs-platform)
(let ((private (expand-file-name "private.el" uwumacs-lisp-dir)))
  (when (file-exists-p private)
    (load private nil t)))
(uwumacs-platform-apply)
(require 'uwumacs-ui)
(require 'uwumacs-literate)
(require 'uwumacs-dashboard)

;; Editing: completion, help, files, git, navigation, then Meow and the leader.
(require 'uwumacs-completion)
(require 'uwumacs-help)
(require 'uwumacs-dired)
(require 'uwumacs-vc)
(require 'uwumacs-navigation)
(require 'uwumacs-meow)
(require 'uwumacs-keys)

;; Applications: shells, programming, Org, and finally frame policy.
(require 'uwumacs-shell)
(require 'uwumacs-programming)
(require 'uwumacs-treesit)
(require 'uwumacs-languages)
(require 'uwumacs-terminal)
(require 'uwumacs-org)
(require 'uwumacs-frames)

;;; init.el ends here
