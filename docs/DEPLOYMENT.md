# Deployment

## Current Windows layout

- Editable complete repository: `C:/Users/walnu/.config/emacs-dots/`.
- Ordinary startup: `C:/Users/walnu/AppData/Roaming/.emacs.d` -> repository.
- Codex packaged startup: `C:/Users/walnu/AppData/Local/Packages/OpenAI.Codex_2p2nqsd0c76g0/LocalCache/Roaming/.emacs.d` -> same repository.
- Start Menu shortcut: Emacs 31.1 `runemacs.exe`, without config arguments.
- Editable portable preferences and startup documentation: `literate/`.
- Generated startup: root `early-init.el` and `init.el`.
- Generated user modules: `lambda-library/lambda-user/*.el` except the local `private.el`.
- Private machine overrides: `lambda-library/lambda-user/private.el` (ignored).
- Installed packages: `var/elpa/` (ignored).
- Persistent saved preferences: `var/etc/custom.el` (ignored, back up).

HOME is not changed. Windows Emacs resolves `~` to AppData/Roaming on this machine; a folder named `.emacs.d` directly under USERPROFILE is not the default unless HOME or the launch arguments select it. Junctions make normal startup use the complete repository without changing home resolution for other Emacs paths.

For a fresh deployment, clone this complete branch into the chosen Emacs init directory, or point the default `.emacs.d` at that clone. The repository includes the framework, so no second Lambda clone/link is needed. First startup may download selected Emacs Lisp packages. Language runtimes and servers are opt-in and not installed here.

## Literate source and generated deployment

Read [the literate guide](../literate/index.org) before editing portable policy.
All code chapters are in `literate/`; targets retain the existing `.emacs.d`
layout beneath the repository root. Run `starter-literate-tangle`, then
`starter-literate-check`, and commit Org plus generated Lisp together. The
standalone `tools/tangle.el` does the same work without loading user startup.
It stages all outputs and validates them before updating changed files. A
failed build before copying leaves the deployed configuration intact; copying
multiple files is not a filesystem-wide atomic transaction.

There is no auto-tangle on save or startup. After a successful rebuild, restart
Emacs to apply changes. Keep `private.el` and `var/` backups independent of Git.

## Settings precedence

1. `early-init.el` establishes framework directories and packages.
2. `lambda-user/early-config.el` selects installation topics before the installer runs.
3. `init.el` loads `lambda-user/config.el`.
4. Base framework modules define variables; `starter-platform` defines portable paths.
5. Optional `private.el` loads once, then portable platform settings are applied.
6. After-init and startup hooks load the remaining editor, language, and UI layers.
7. The framework's deferred Customize loader reads `var/etc/custom.el` when `cus-edit` loads. Saved Customize values can override earlier values; keep portable preferences in tracked source and use Customize for local choices deliberately.

## Verification

In PowerShell, using an existing package installation:

```powershell
emacs -Q --batch -l tools/tangle.el -- --check
emacs -Q --batch -l tests/tangle-tests.el -f ert-run-tests-batch-and-exit
$env:EMACS_DOTS_TEST_PACKAGES = 'C:/Users/walnu/.config/emacs-dots/var/elpa/'
emacs -Q --batch -l tests/verify-config.el
```

The check copies configuration to temporary storage, blocks package installation and archive refresh, and verifies private override ordering, package-topic selection, persistent Customize loading, key startup features, both dashboard documentation links, final cheat-sheet bindings, and personal Elisp syntax. It requires the configured packages to be present; a missing package is a failing check, not an instruction to install it automatically. Graphical appearance and Windows startup resolution require a separate GUI check.

Inside normally started Emacs inspect `user-init-file`, `user-emacs-directory`, `lem-config-file`, and `custom-file`. Windows may retain the junction spelling even after `file-truename`; use `file-equal-p` to verify file identity and inspect junction targets from an unpackaged Windows process. `-Q` and `-q` intentionally bypass normal user configuration.

## Migration and rollback

The migration records exact backup paths and before/after checks in the local audit folder `C:/Users/walnu/Documents/Emacs-Audit-20260910/`. Runtime data is copied, not moved, from the old Lambda directory. The physical desktop startup directory, the old packaged startup junction, and both original configuration repositories are retained in the dated backup directory. The migration discovered that the physical desktop had an independent copy of Lambda's default sample configuration, hidden by Codex's AppData redirection.

To roll back from an unpackaged Windows process: close Emacs and preserve new runtime state/edits. Remove only the two new `.emacs.d` junction entries, leaving their target intact. Move `desktop-emacs.d` from the recorded backup directory back to normal AppData `.emacs.d`. Move archived `lambda-emacs` back to `.config/lambda-emacs`, and move `startup-link-1` back to the Codex-packaged AppData `.emacs.d` location. The archived Lambda user-layer junction already points at the backed-up original dotfiles. This restores the original split configuration for recovery; the consolidated checkout is retained. Do not recursively delete a directory junction or its target.

The original consolidated configuration is published on `main`; subsequent work can be deployed from a reviewed feature branch. Check `git branch --show-current` and `git status` before updating. For the literate refactor, keep its Org sources and generated Lisp on the same revision. To undo only this refactor, switch back to the preceding `fix/fonts-dashboard-cheatsheet` branch after preserving edits; the `.emacs.d` junctions and ignored runtime state do not need to move. The dated backups retain the older pre-consolidation configuration.

## Known inherited limits

Magit is not in Lambda's automatic package list and was absent from this machine at review time; built-in VC remains available. Install Magit deliberately if desired. First provision a fresh package directory with an ordinary interactive Emacs start and restart before using daemon mode: the inherited cold-daemon installer runs after some module configuration, so a brand-new daemon is not a supported first-install validation path here. The migration tests use existing packages; they are not evidence of an offline fresh-package bootstrap.
