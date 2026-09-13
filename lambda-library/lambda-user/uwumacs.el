;;; uwumacs.el --- Literal leader maps for Meow -*- lexical-binding: t; -*-
;; Generated from literate/41-uwumacs-core.org; edit the Org source, then tangle.

;;; Code:

(defgroup uwumacs nil
  "Literal, discoverable command maps that coexist with Meow."
  :group 'editing
  :prefix "uwumacs-")

(require 'uwumacs-maps)
(require 'uwumacs-integration-core)

(uwumacs--replace-leader-definitions uwumacs-integration-core-map-sources)

(provide 'uwumacs)
;;; uwumacs.el ends here
