# Literate Emacs configuration implementation plan

Goal: Make nested, explanatory Org chapters under literate/ the maintained source of the existing Emacs-Dots configuration, with generated files deployed relative to the .emacs.d repository root.

Architecture: Org Babel concatenates small named blocks into the existing startup and personal module paths. The pinned Lambda module snapshot remains a separate, documented dependency. A standalone Emacs build tangles in temporary storage, checks the expected output set and Lisp syntax, and compares or writes outputs. Startup reads generated Lisp only.

Constraints: Emacs 30.1+, built-in Org only for tangling, retain Lambda/Meow behavior and existing packages, keep private.el and var/ out of generation, retain license/provenance, preserve dashboard font/centering fixes, no auto-tangle on save, no package installations during tests.

- [x] Build and test a staging-based tangle/check command with an explicit output manifest.
- [x] Author bootstrap, ownership, user-composition, platform, editing, appearance, programming and Org chapters, using small documented blocks in execution order.
- [x] Add literate open/tangle/check commands and route dashboard Config to the entry chapter.
- [x] Verify generated Lisp forms against the previous configuration except the explicitly added literate entry points.
- [x] Verify reproducible tangling, check-mode immutability, drift detection and isolated startup; update reading/deployment/provenance documentation.
- [x] Check ordinary graphical startup and dashboard behavior after deployment.
- [x] Commit the refactor and deploy the verified branch into the existing root checkout, preserving runtime state.

Validation (2026-09-11): 15 generated files match the intended pre-conversion
Lisp forms, with only the new authoring module/require and Config destination
included as intentional behavior changes. The builder regression suite passes;
check mode passes after checkout. All 11 Org documents export and local file
links resolve. The isolated startup check passes, including both dashboard
widgets and final cheat-sheet keybindings. Ordinary graphical Emacs loads the
installed branch; five icon families resolve to Symbols Nerd Font Mono, the
literate subprocess check passes, and 17 dashboard lines center within 0.5 px
at both 640 px and 960 px body widths. No package installation was needed.
The refactor is committed and deployed locally on refactor/literate-config.
