;;; init.el  -*- lexical-binding: t; mode: emacs-lisp; coding:utf-8; fill-column: 80 -*-
;; Generated from literate/10-bootstrap.org; edit the Org source, then tangle.
;; Author: Colin McLear
;; Maintainer: Colin McLear
;; Version: 0.3.0

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
;; This is the base init file to load the entire emacs config. For ease of
;; navigation use outline-mode to cycle headlines open and closed (<Tab> and
;; <S-Tab>) to navigate through sections, and "imenu" to locate individual
;; use-package definitions.

;;; Code:
;;;; Startup
;;;;; Use-Package

;; use-package is built-in since Emacs 29

;; Use-Package Settings
(use-package use-package
  :custom
  ;; Don't automatically defer
  (use-package-always-defer nil)
  ;; Report loading details
  (use-package-verbose t)
  ;; This is really helpful for profiling
  (use-package-minimum-reported-time 0)
  ;; Expand normally
  (use-package-expand-minimally nil)
  ;; Unconditional: lambda-emacs handles installation via
  ;; `lem-install-extras' driven by `lem-packages-alist', not via
  ;; use-package's :ensure machinery. Setting this to nil lets
  ;; modules omit :ensure entirely without accidentally triggering
  ;; an install on any form that says nothing about :ensure.
  (use-package-always-ensure nil)
  ;; Navigate use-package declarations w/imenu
  (use-package-enable-imenu-support t))
;;;;; Security
;; Properly verify outgoing ssl connections.
;; See https://glyph.twistedmatrix.com/2015/11/editor-malware.html
(use-package gnutls
  :ensure nil
  :defer 1
  :custom
  (gnutls-verify-error t)
  (gnutls-min-prime-bits 3072))
;;;;; Command Line Switches

;; Conditionally load parts of config depending on command line switches.
;; This allows startup with a clean emacs that still recognizes straight.
;; Helpful for testing packages.
;; Use (straight-use-package) command to selectively load packages.
;; See https://emacs.stackexchange.com/a/34909/11934
;; For function switch see https://stackoverflow.com/a/4065412/6277148

;; NOTE: The variable here doesn't really do anything. It is just useful to keep
;; for a record of switches.
(defvar lem-config-switches
  '("basic"
    "clean"
    "core"
    "test")
  "Custom switches for conditional loading from command line.
  `clean' loads only the `init.el' file w/no personal config; `core'
  loads the set of modules set in `lem-core-modules'; `test' loads
  only a `lem-setup-test.el' file for easy testing.")
(defvar lem--emacs-switches-found nil
  "Custom command-line switches found in `command-line-args' at startup.
Populated by a single scan at load time: each known switch
(\"-minimal\", \"-test\", \"-vanilla\", \"-default\") present in
`command-line-args' is recorded here and deleted from
`command-line-args' exactly once, so Emacs's own option processing
does not signal \"Unknown option\" after init.")
(dolist (switch '("-minimal" "-test" "-vanilla" "-default"))
  (when (member switch command-line-args)
    (push switch lem--emacs-switches-found)
    (setq command-line-args (delete switch command-line-args))))
(defun lem--emacs-switches (switch)
  "Non-nil if command line argument SWITCH was passed.
Consults `lem--emacs-switches-found', the snapshot recorded when the
switch was removed from `command-line-args' at load time, so it is
safe to call any number of times per switch."
  (member switch lem--emacs-switches-found))
;;;;; Emacs Build Version
;; When built with https://codeberg.org/mclearc/build-emacs-macos, Emacs has
;; git-version patch to include git sha1 in emacs-version string.
;; Load it only when the running build actually provides it on its load-path.
;; Checking a hardcoded Emacs.app path with `file-exists-p' breaks other builds
;; (e.g. a homebrew daemon) whose load-path omits that site-lisp: the file
;; exists on disk so the guard passes, but `require' cannot find it.
(when (locate-library "emacs-git-version")
  (require 'emacs-git-version))
(defun lem-emacs-version ()
  "A convenience function to print the emacs-version in the echo-area/*messages* buffer and put
emacs-version string on the kill ring."
  (interactive)
  (let ((emacs (emacs-version)))
    (message (emacs-version))
    (kill-new emacs)))
;;;;; Outline Navigation
;; Navigate elisp files easily. Outline is a built-in library and we can easily
;; configure it to treat elisp comments as headings.
(use-package outline
  :ensure nil
  :hook (prog-mode . outline-minor-mode)
  :bind (:map outline-minor-mode-map
         ("<tab>"   . outline-cycle)
         ("S-<tab>" . outline-cycle-buffer)
         ("M-j"     . outline-move-subtree-down)
         ("M-k"     . outline-move-subtree-up)
         ("M-h"     . outline-promote)
         ("M-l"     . outline-demote))
  :config
  (add-hook 'emacs-lisp-mode-hook
            (lambda ()
              ;; prevent `outline-level' from being overwritten by `lispy'
              (setq-local outline-level #'outline-level)
              ;; setup heading regexp specific to `emacs-lisp-mode'
              (setq-local outline-regexp ";;;\\(;* \\)")
              ;; heading alist allows for subtree-like folding
              (setq-local outline-heading-alist
                          '((";;; " . 1)
                            (";;;; " . 2)
                            (";;;;; " . 3)
                            (";;;;;; " . 4)
                            (";;;;;;; " . 5))))))
;;;;; Load Configuration Modules
;; Lambda-Emacs loads a series of lisp-libraries or 'modules'. Which modules are
;; loaded is left to the user to set in `config.el', though if there is no
;; `config.el' file a default set of modules will be loaded.

(defun lem--default-modules ()
  "Load a default configuration for 𝛌-Emacs.
Skips modules listed in `(lem-gui-only-modules)' when
`lem-headless-host' is non-nil."
  (message "
;; ======================================================
;; *Loading default setup of 𝛌-Emacs Modules*
;; ======================================================")
  (measure-time
   (cl-dolist (mod (cl-remove-if
                    (lambda (m)
                      (and lem-headless-host
                           (memq m (lem-gui-only-modules))))
                    (list
                    ;; Core modules
                    'lem-setup-libraries
                    'lem-setup-settings
                    'lem-setup-functions
                    'lem-setup-server
                    'lem-setup-scratch
                    ;; UI modules
                    'lem-setup-frames
                    'lem-setup-windows
                    'lem-setup-buffers
                    'lem-setup-fonts
                    'lem-setup-faces
                    'lem-setup-colors
                    'lem-setup-completion
                    'lem-setup-keybindings
                    'lem-setup-help
                    'lem-setup-modeline
                    'lem-setup-theme
                    'lem-setup-splash

                    ;; Navigation & Search modules
                    'lem-setup-navigation
                    'lem-setup-dired
                    'lem-setup-search

                    ;; Project & Tab/Workspace modules
                    'lem-setup-vc
                    'lem-setup-projects
                    'lem-setup-tabs

                    ;; Org modules
                    'lem-setup-org-base
                    'lem-setup-org-settings
                    ;; Writing modules
                    'lem-setup-writing
                    'lem-setup-notes
                    'lem-setup-citation

                    ;; Shell & Terminal
                    'lem-setup-shell
                    'lem-setup-eshell

                    ;; Programming modules
                    'lem-setup-programming)))
     (require mod))))
(defun lem--minimal-modules ()
  "Load 𝛌-Emacs with a minimal set of modules.
Skips modules listed in `(lem-gui-only-modules)' when
`lem-headless-host' is non-nil, matching `lem--default-modules'."
  (message "
;; ======================================================
;; *Loading 𝛌-Emacs, with minimal modules*
;; ======================================================")
  (measure-time
   (cl-dolist (mod (cl-remove-if
                    (lambda (m)
                      (and lem-headless-host
                           (memq m (lem-gui-only-modules))))
                    (list
                     ;; Core modules
                     'lem-setup-libraries
                     'lem-setup-settings
                     'lem-setup-functions
                     'lem-setup-server
                     'lem-setup-scratch
                     ;; UI modules
                     'lem-setup-frames
                     'lem-setup-windows
                     'lem-setup-buffers
                     'lem-setup-completion
                     'lem-setup-keybindings
                     'lem-setup-help
                     'lem-setup-modeline
                     'lem-setup-splash

                     ;; Navigation & Search modules
                     'lem-setup-navigation
                     'lem-setup-dired
                     'lem-setup-search)))
     (require mod))))
;;;; Defensive headless-host warning
;; Installed BEFORE the module-loading cond so the hook is in
;; place even if the cond's body errors out (e.g. an external
;; package missing in the test sandbox). The function no-ops
;; when `lem-headless-host' is nil; on a headless host it emits
;; a prominent warning if a client creates a graphical frame
;; (GUI-only modules were skipped at load time, so fonts,
;; mode-line, and faces are unconfigured in such a frame).
(require 'server)
(defun lem--warn-gui-frame-on-headless ()
  "Warn if a server client created a GUI frame on a headless host."
  (when (and lem-headless-host
             (display-graphic-p))
    (display-warning
     'lambda-emacs
     (concat "GUI client frame created on a host where "
             "lem-headless-host is t. GUI modules were not "
             "loaded; fonts, mode-line, and faces are "
             "unconfigured. Unset lem-headless-host and "
             "restart Emacs to recover.")
     :error)))
(add-hook 'server-after-make-frame-hook #'lem--warn-gui-frame-on-headless)
;; Conditionally load configuration files based on command-line switches,
;; presence of user-config file, or the default set of modules.
(cond
 ;; Load a subset of modules only, ignore other configuration.
 ((lem--emacs-switches "-minimal")
  (message "*Loading a subset of 𝛌-Emacs modules *only*, ignoring personal user configuration.*")
  (lem--minimal-modules))

 ;; Load test module only. This is useful for testing a specific package
 ;; against vanilla/default emacs settings.
 ((lem--emacs-switches "-test")
  (message "*Loading test module only*")
  (require 'lem-setup-test))

 ;; -vanilla is deprecated. Its original behavior was "load only
 ;; lem-setup-icomplete"; that file was deleted in Spec 03 once the
 ;; icomplete baseline was moved inline into lem-setup-completion.el.
 ;; The switch is rerouted to the -minimal branch and preserved as a
 ;; test hook; a deprecation message is emitted so muscle-memory
 ;; users see the rename without a hard break.
 ((lem--emacs-switches "-vanilla")
  (message "*-vanilla is deprecated; using -minimal instead*")
  (lem--minimal-modules))
 ;; Load user's personal config file (if it exists) and hasn't been bypassed
 ;; by a command-line switch to load the default libraries.
 ((and (not (lem--emacs-switches "-default"))
       (file-exists-p lem-config-file))
  (message "*Loading 𝛌-Emacs & user config*")
  (load lem-config-file 'noerror))

 ;; Load default config
 ((lem--emacs-switches "-default")
  (message "*Loading 𝛌-Emacs default modules")
  (lem--default-modules)
  ;; MacOS settings - defer load until after init. Skipped on
  ;; headless hosts: `lem-setup-macos' is in `lem-gui-only-set'
  ;; and the dispatcher's filter already excludes it, but this
  ;; deferred require fires outside the dispatcher and would
  ;; bypass the filter without the explicit guard.
  (when (and sys-mac (not lem-headless-host))
    (message "*Load MacOS settings...*")
    (measure-time
     (run-with-idle-timer 1 nil
                          (function require)
                          'lem-setup-macos nil t))))
 ;; No user config file exists: create one from the shipped default
 ;; and load it. Historically this branch called yes-or-no-p and
 ;; discarded the answer (always proceeding), so the prompt offered
 ;; no real consent. Removed for batch-safety and honesty.
 ((when (not (file-exists-p lem-config-file))
    (progn
      (with-temp-file lem-config-file
        (insert-file lem-default-config-file))
      (load-file lem-config-file))))
 ;; Load default modules
 (t
  (message "*Loading 𝛌-Emacs default configuration files.*")
  (lem--default-modules)
  ;; MacOS settings - deferred; see the `-default' branch comment
  ;; above for why the headless guard is needed here.
  (when (and sys-mac (not lem-headless-host))
    (message "*Load MacOS settings...*")
    (measure-time
     (run-with-idle-timer 1 nil
                          (function require)
                          'lem-setup-macos nil t)))))
;;;; After Startup
;; reset file-name-handler-alist
(add-hook 'emacs-startup-hook (lambda ()
                                (setq file-name-handler-alist lem-file-name-handler-alist)
                                ;; reset garbage collection
                                (setq gc-cons-threshold 800000)
                                ;; Startup time
                                (message (format ";; ======================================================\n;; Emacs ready in %.2f seconds with %d garbage collections.\n;; ======================================================"
                                                 (float-time
                                                  (time-subtract after-init-time before-init-time)) gcs-done))
                                (put 'narrow-to-page 'disabled nil)))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-vc-selected-packages
   '((claudemacs :url "https://github.com/cpoile/claudemacs" :branch "main")
     (org-modern-indent :url "https://github.com/jdtsmith/org-modern-indent")
     (org-devonthink :url "https://github.com/lasvice/org-devonthink" :branch
		     "master")
     (pulsing-cursor :url "https://github.com/jasonjckn/pulsing-cursor" :branch
		     "main")
     (bibtex-capf :url "https://codeberg.org/mclear-tools/bibtex-capf.git" :branch
		  "main")
     (zotxt-emacs :url "https://github.com/egh/zotxt-emacs.git" :branch "master"))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
