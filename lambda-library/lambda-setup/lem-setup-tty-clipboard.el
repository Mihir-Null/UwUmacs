;;; lem-setup-tty-clipboard.el --- TTY clipboard via OSC52 -*- lexical-binding: t -*-

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

;; Bridge the kill ring to the system clipboard accessible from the
;; user's current device. In a graphic frame this means the host's
;; native clipboard (via `gui-select-text'). In a tty frame it means
;; the outer terminal's clipboard, reached via the OSC52 escape
;; sequence forwarded by tmux's clipboard passthrough. The same
;; function handles both directions through a single dispatch on the
;; frame that displays the source buffer at kill time.

;; The module is intentionally small. Loading it installs
;; `lem--osc52-cut-function' as `interprogram-cut-function'; nothing
;; else needs to know it is here.

;;; Code:

(defcustom lem-osc52-max-region-bytes 100000
  "Maximum kill size, in raw region bytes, that may be written to
the terminal clipboard via OSC52. Larger kills remain in the local
kill ring and emit a single message; nothing is sent to the
terminal.

The value is measured pre-encoding. Base64 inflates the wire form
by roughly 4/3 plus a small constant from the OSC52 framing
(`\\e]52;c;...\\e\\\\'). When the kill happens inside tmux, every
ESC byte in that wire form is doubled by the tmux passthrough
wrapper, which inflates again.

Terminal limits vary widely. Apple Terminal caps OSC52 sequences
near 4 KB; Blink Shell and iTerm2 are more permissive. The default
of 100000 raw bytes targets a Blink workflow with tmux. Lower the
value if a different terminal will receive the sequence."
  :type 'integer
  :group 'lambda-emacs)

(defun lem--osc52-emit (text frame)
  "Encode TEXT and send the OSC52 sequence to FRAME's terminal.

If `(string-bytes TEXT)' exceeds `lem-osc52-max-region-bytes',
the function emits a single message and returns without writing
to the terminal stream."
  (if (> (string-bytes text) lem-osc52-max-region-bytes)
      (message
       "lem-osc52: region too large for terminal clipboard (%d bytes, limit %d)"
       (string-bytes text) lem-osc52-max-region-bytes)
    (let* ((bytes (encode-coding-string text 'utf-8 t))
           (b64   (base64-encode-string bytes t))
           (raw   (concat "\e]52;c;" b64 "\e\\"))
           (seq   (if (getenv "TMUX")
                      (concat "\ePtmux;"
                              (replace-regexp-in-string "\e" "\e\e" raw)
                              "\e\\")
                    raw)))
      (send-string-to-terminal seq (frame-terminal frame)))))

(defun lem--osc52-cut-function (text)
  "Replacement for `interprogram-cut-function'.

Dispatches TEXT per frame type. Resolves the frame from the
window that displays the current buffer. On a graphic frame
(`(framep f)' is `ns', `mac', `pgtk', or `x') the function calls
`gui-select-text' so the native system clipboard receives the
write. On a tty frame the function emits an OSC52 sequence on
that frame's terminal stream. With no resolvable frame it logs a
one-line message and returns. In `--batch' (`noninteractive' is
non-nil) it is a no-op."
  (unless noninteractive
    (let* ((win   (get-buffer-window (current-buffer) t))
           (frame (window-frame win))
           (kind  (framep frame)))
      (cond
       ((memq kind '(ns mac pgtk x))
        (gui-select-text text))
       ((eq kind t)
        (lem--osc52-emit text frame))
       (t
        (message "lem-osc52: kill stayed local (no live frame)"))))))

(setq interprogram-cut-function 'lem--osc52-cut-function)

(provide 'lem-setup-tty-clipboard)
;;; lem-setup-tty-clipboard.el ends here
