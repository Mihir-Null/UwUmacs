;;; early-init.el --- Before the first frame -*- lexical-binding: t; -*-
;; Generated from literate/10-startup.org; edit the Org source, then tangle.

;;; Code:

(defvar uwumacs-lisp-dir (expand-file-name "lisp/" user-emacs-directory)
  "Directory of the generated configuration modules.")

(defvar uwumacs-var-dir (expand-file-name "var/" user-emacs-directory)
  "Directory for everything Emacs writes on its own.  Ignored by Git.")

(defvar uwumacs-cache-dir (expand-file-name "cache/" uwumacs-var-dir)
  "Directory for caches that can be deleted at any time.")

(defvar uwumacs-etc-dir (expand-file-name "etc/" uwumacs-var-dir)
  "Directory for state worth keeping: saved customizations, shell history.")

(setq package-user-dir (expand-file-name "elpa/" uwumacs-var-dir)
      package-gnupghome-dir (expand-file-name "gnupg/" package-user-dir)
      package-enable-at-startup nil)
(setopt package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
                           ("nongnu" . "https://elpa.nongnu.org/nongnu/")
                           ("melpa" . "https://melpa.org/packages/")))
;; GNU ELPA signs its archive index and Emacs verifies it with gpg (Gpg4win
;; on Windows).  Without a gpg program the check fails and the whole archive
;; silently disappears, so skip the check rather than lose the archive.
(unless (executable-find "gpg")
  (setq package-check-signature nil))

(when (featurep 'native-compile)
  (startup-redirect-eln-cache (expand-file-name "eln-cache/" uwumacs-cache-dir))
  (setopt native-comp-async-report-warnings-errors 'silent))

(setq gc-cons-threshold most-positive-fixnum)
(add-hook 'emacs-startup-hook (lambda () (setq gc-cons-threshold (* 64 1024 1024))))

(setopt frame-inhibit-implied-resize t
        inhibit-startup-screen t
        initial-scratch-message nil
        load-prefer-newer t)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)

(when (eq system-type 'windows-nt)
  (setq w32-get-true-file-attributes nil
        inhibit-compacting-font-caches t))

;;; early-init.el ends here
