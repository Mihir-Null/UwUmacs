# Self-contained Emacs configuration migration

Goal: Deploy .emacs.d directly from Emacs-Dots while preserving the current editor preferences and runtime state.

Approved design: One repository containing Lambda startup files, a pinned Lambda framework snapshot, and the existing personal layer. Include upstream license and provenance. Keep private settings and runtime files out of Git. Normal Windows and Codex-packaged startup resolve to the same repository through directory junctions. Preserve old roots and state with dated backups.

Constraints: Emacs 30.1+, current Windows Emacs 31.1; PowerShell default, MSYS2 explicit; no language-server/runtime installations; no changes to the independent notes vault; no package upgrades/uninstalls; remote/main publishing initially deferred, then explicitly authorized by the user after migration verification.

- [x] Verify the existing deployment baseline and capture preferences.
- [x] Demonstrate the missing top-level startup files and duplicate private load; prepare repeatable isolated checks.
- [x] Import Lambda startup, framework, assets, and license from exact local revision; record file hashes and local patches.
- [x] Make private.el load once after platform defaults; restrict initial package topics to enabled modules; update README and deployment/rollback documentation.
- [x] Verify syntax, private override ordering, package policy, and isolated startup with existing installed packages and network installation blocked.
- [x] Commit on feat/self-contained-emacs and transfer to the installed checkout with main publishing deferred until separately authorized.
- [x] Back up original roots/runtime data, copy runtime state, and repoint verified startup junctions to the complete Emacs-Dots repository.
- [x] Verify graphical ordinary startup and both Windows launch contexts; record exact final paths, commit, backups, and limitations.

- [x] User authorized main and remote publication after validation; update deployment documentation and publish the verified result.
