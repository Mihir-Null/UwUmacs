;;; uwumacs-leader.el --- A literal leader and localleaders for Meow -*- lexical-binding: t; -*-
;; Generated from literate/41-leader.org; edit the Org source, then tangle.

;;; Commentary:
;; SPC becomes an ordinary prefix keymap in Meow's Normal and Motion states,
;; and every major mode gets its own map under SPC m.  Everything is a native
;; keymap, so C-h k, C-h b, which-key and Marginalia see the real keys.

;;; Code:

(require 'meow)

(defgroup uwumacs nil
  "UwUmacs: a literal, discoverable leader for Meow."
  :group 'convenience
  :prefix "uwumacs-")

(defcustom uwumacs-leader-key "SPC"
  "Key that opens `uwumacs-leader-map' in Meow's Normal and Motion states."
  :type 'key)

(defcustom uwumacs-localleader-key "m"
  "Key below the leader that opens the current major mode's localleader map."
  :type 'key)

(defcustom uwumacs-keypad-key nil
  "Optional key below the leader that starts Meow's keypad translation loop.
Nil leaves `meow-keypad' unbound; it stays available as a command."
  :type '(choice (const :tag "Unbound" nil) key))
(defvar uwumacs-leader-map (make-sparse-keymap)
  "The leader map, opened by `uwumacs-leader-key' in Normal and Motion states.
Add a command with `keymap-set'.  Add a labelled group with
  (keymap-set uwumacs-leader-map \"f\" (cons \"files\" my-file-map)).")
(defvar uwumacs-localleader-alist nil
  "Alist of (MAJOR-MODE . KEYMAP) localleader maps.
Maps compose along the mode's parents, most specific first, so a map for
`prog-mode' is inherited by every programming mode.")

(defvar-local uwumacs--localleader-alist nil
  "This buffer's emulation-map entry: its composed localleader under the leader.")

(defun uwumacs-localleader-map (&optional mode)
  "Return the composed localleader keymap for MODE, or nil if none applies.
MODE defaults to the current major mode."
  (let ((maps (delq nil (mapcar (lambda (parent)
                                  (alist-get parent uwumacs-localleader-alist))
                                (derived-mode-all-parents (or mode major-mode))))))
    (when maps (make-composed-keymap maps))))

(defun uwumacs--install-localleader ()
  "Point this buffer's emulation entry at its localleader, if it has one."
  (setq uwumacs--localleader-alist
        (when-let* ((local (uwumacs-localleader-map))
                    (wrapper (define-keymap
                               uwumacs-leader-key
                               (define-keymap uwumacs-localleader-key
                                 (cons "mode" local)))))
          `((meow-normal-mode . ,wrapper) (meow-motion-mode . ,wrapper)))))

(defun uwumacs-refresh-localleaders ()
  "Recompute the localleader of every live buffer."
  (dolist (buffer (buffer-list))
    (with-current-buffer buffer (uwumacs--install-localleader))))

(defun uwumacs-define-localleader (mode &rest definitions)
  "Give MODE a localleader built from DEFINITIONS and refresh live buffers.
DEFINITIONS are `define-keymap' arguments: KEY DEFINITION pairs, where a
definition may be (cons \"label\" COMMAND) to label it for which-key.
Calling this again for MODE replaces its map."
  (declare (indent 1))
  (setf (alist-get mode uwumacs-localleader-alist) (apply #'define-keymap definitions))
  (uwumacs-refresh-localleaders)
  mode)
(defun uwumacs-describe-leader ()
  "Describe the leader bindings, including this buffer's localleader."
  (interactive)
  (let ((map (make-sparse-keymap)))
    (set-keymap-parent map uwumacs-leader-map)
    (when-let* ((local (uwumacs-localleader-map)))
      (keymap-set map uwumacs-localleader-key (cons "mode" local)))
    (describe-keymap map)))

(defun uwumacs-leader-enable ()
  "Bind the leader in Meow's Normal and Motion states and start localleaders.
Safe to call more than once."
  (meow-normal-define-key (cons uwumacs-leader-key uwumacs-leader-map))
  (meow-motion-define-key (cons uwumacs-leader-key uwumacs-leader-map))
  (when uwumacs-keypad-key
    (keymap-set uwumacs-leader-map uwumacs-keypad-key #'meow-keypad))
  (add-to-list 'emulation-mode-map-alists 'uwumacs--localleader-alist)
  (add-hook 'after-change-major-mode-hook #'uwumacs--install-localleader)
  (uwumacs-refresh-localleaders))

(provide 'uwumacs-leader)
;;; uwumacs-leader.el ends here
