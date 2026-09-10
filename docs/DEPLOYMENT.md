# Deployment

## Current Windows layout

- Editable complete repository: `C:/Users/walnu/.config/emacs-dots/`.
- Ordinary startup: `C:/Users/walnu/AppData/Roaming/.emacs.d` -> repository.
- Codex packaged startup: `C:/Users/walnu/AppData/Local/Packages/OpenAI.Codex_2p2nqsd0c76g0/LocalCache/Roaming/.emacs.d` -> same repository.
- Start Menu shortcut: Emacs 31.1 `runemacs.exe`, without config arguments.
- Portable preferences: `lambda-library/lambda-user/`.
- Private machine overrides: `lambda-library/lambda-user/private.el` (ignored).
- Installed packages: `var/elpa/` (ignored).
- Persistent saved preferences: `var/etc/custom.el` (ignored, back up).

HOME is not changed. Windows Emacs resolves `~` to AppData/Roaming on this machine; a folder named `.emacs.d` directly under USERPROFILE is not the default unless HOME or the launch arguments select it. Junctions make normal startup use the complete repository without changing home resolution for other Emacs paths.

For a fresh deployment, clone this complete branch into the chosen Emacs init directory, or point the default `.emacs.d` at that clone. The repository includes the framework, so no second Lambda clone/link is needed. First startup may download selected Emacs Lisp packages. Language runtimes and servers are opt-in and not installed here.

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
$env:EMACS_DOTS_TEST_PACKAGES = 'C:/Users/walnu/.config/emacs-dots/var/elpa/'
emacs -Q --batch -l tests/verify-config.el
```

The check copies configuration to temporary storage, blocks package installation and archive refresh, and verifies private override ordering, package-topic selection, persistent Customize loading, key startup features, and personal Elisp syntax. It requires the configured packages to be present; a missing package is a failing check, not an instruction to install it automatically. Graphical appearance and Windows startup resolution require a separate GUI check.

Inside normally started Emacs inspect `user-init-file`, `user-emacs-directory`, `lem-config-file`, and `custom-file`. `file-truename` resolves junctions. `-Q` and `-q` intentionally bypass normal user configuration.

## Migration and rollback

The migration records exact backup paths and before/after checks in the local audit folder `C:/Users/walnu/Documents/Emacs-Audit-20260910/`. Runtime data is copied, not moved, from the old Lambda directory. The old startup junctions and configuration folders are retained in the dated backup directory.

To roll back: close Emacs, preserve any new runtime state and configuration edits, remove only the two new `.emacs.d` junction entries (not their targets), restore the original junctions and the original `.config/lambda-emacs` folder from the recorded backups. The old user-layer junction must point at the backed-up Emacs-Dots clone when restoring the exact pre-migration configuration. Do not recursively delete a directory junction or its target.

The migration branch is local until explicitly published. The `main` branch and remote repository are not advanced by deployment.

## Known inherited limits

Magit is not in Lambda's automatic package list and was absent from this machine at review time; built-in VC remains available. Install Magit deliberately if desired. First provision a fresh package directory with an ordinary interactive Emacs start and restart before using daemon mode: the inherited cold-daemon installer runs after some module configuration, so a brand-new daemon is not a supported first-install validation path here. The migration tests use existing packages; they are not evidence of an offline fresh-package bootstrap.
