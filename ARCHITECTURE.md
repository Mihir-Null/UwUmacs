# UwUmacs — architecture and decisions

Single source of truth for the design. Updated 2026-09-14 at the end of the review-driven refactor. The learner-facing explanation lives in [`literate/index.org`](literate/index.org); this file is for whoever changes the design.

## 1. Intent (the user's words)

UwUmacs is a user-friendly, batteries-included, opinionated and extensible Emacs configuration for one person, built on a small sane starter kit (Lambda-Emacs, Colin McLear's config) plus liked packages. It is Meow-first: selection → extension → action, with visual hints. It prefers spawning frames over windows so the desktop window manager manages them. Its main thrust is to be for Meow what Doom/evil-collection are for Evil: retire the Meow keypad, replace on-screen hints and internal keymaps with real literal maps, and integrate the initial package set with the Meow grammar in a clean, extensible way. It must stay learner-friendly: discoverable actions, visual hints, simple to modify and extend, with a heavily explanatory, tutorialised, wiki-style literate config.

## 2. Shape

```
early-init.el, init.el   generated from literate/10-startup.org (86 lines together)
literate/*.org           19 chapters + index + manifest.json; the source of truth
lisp/uwumacs-*.el        21 generated modules (2,789 lines); keybindings.org; themes/; private.el
tests/                   tangle-tests (8), uwumacs-leader-tests (6), verify-config, frames-tests (5, GUI)
tools/tangle.el          stages, validates and copies generated outputs (125 lines)
var/                     packages, caches, custom.el; ignored
```

Startup is a flat list of `require`s in `init.el`, ordered by dependency: defaults → platform → `private.el` → UI → literate commands → dashboard → completion → help → Dired → VC → navigation → Meow → keys → shells → programming → Tree-sitter → languages → terminals → Org → frames. There are no staged hooks; modes that need `after-init-hook` add themselves.

Before the refactor the same configuration was 853 lines of vendored Lambda startup, 9,913 lines of vendored Lambda modules (17 never loaded), 2,384 lines of user modules, a 954-line prototype core that was never loaded, 3,740 lines of tests and tooling, and 14,307 lines of process documentation. Net change against `main`: 122 files, +6,338 / −15,531.

## 3. The Meow layer

**Leader.** `SPC` is bound to `uwumacs-leader-map`, an ordinary keymap, in Meow's Normal and Motion state maps through Meow's own `meow-normal-define-key` / `meow-motion-define-key`. Because it is a real keymap, `C-h k`, `C-h b`, `where-is`, which-key and Marginalia see the physical keys with no adapter. `C-c C-SPC` opens the same map from Insert state and non-Meow buffers. `meow-keypad` is not bound; `uwumacs-keypad-key` binds it under the leader when set. (`literate/41-leader.org`)

**Localleader.** Meow has no per-mode state maps, so `SPC m` uses one buffer-local entry in `emulation-mode-map-alists`, keyed on `meow-normal-mode` / `meow-motion-mode`, whose map is composed along `derived-mode-all-parents` (most specific first). A `prog-mode` menu is inherited by every language; `emacs-lisp-mode` overrides the keys it redefines. `uwumacs-define-localleader` is one form per mode. The leader map must leave `m` unbound. (`literate/41-leader.org`)

**Integrations.** Each package chapter states which Meow state its buffers start in (`meow-mode-state-list`) and defines its localleader with labelled entries, evil-collection style but literate. Application buffers (Dired, Magit, Help, Info, the agenda, the dashboard) start in Motion so their own keys keep working; shells and commit messages start in Insert.

**Keys.** `literate/42-keys.org` is the single owner of the tree: labelled group keymaps for buffers, files, search, VC, windows/frames, workspaces, code, eval, language server, diagnostics, insert, open, toggle, config, help, quit and a reserved user group. `SPC p` is Emacs's own `project-prefix-map`. The chapter carries the migration table from the old keys. `lisp/keybindings.org` is the learner cheat sheet; the startup verifier checks every `SPC` row in it against the live map.

## 4. Decisions

User decisions (2026-09-14):

1. Extract the vendored Lambda tree fully into own literate chapters rather than trim it.
2. Literal `SPC` leader; the keypad bound to nothing by default, with `uwumacs-keypad-key` as the opt-in.
3. This file is the only decision record; the ADR folder, validator, inventory, progress ledger and catalogue were deleted.
4. `early-init.el` and `init.el` are our own short files, tangled from a chapter.
5. The GUI test runner was deleted; `tests/frames-tests.el` stays runnable by hand.
6. First integrations: Magit, Dired, Org, EAT and Eshell, Vertico/Consult/Embark, Help and Info.
7. The result lands as a pull request into `main`, superseding branch `uwumacs`.

Agent decisions, with the reason:

- **No registry, no transactions.** `with-eval-after-load`, hooks and `derived-mode-p` are the lazy-readiness and specificity mechanisms Emacs already has. The prototype's descriptor validation, readiness states and reentrancy guards solved problems the native design does not have.
- **Buffer-local emulation entry over a `menu-item :filter`.** Both work; only the emulation entry is visible to `where-is`, which Marginalia uses for M-x annotations.
- **Motion state for Magit and Dired** (was Normal for Magit). In Normal state Meow's grammar shadows Magit's `s`, `u`, `c`; Motion keeps the package's keys and adds only `j`/`k` and the leader.
- **UI loads first.** Theme and fonts before the first frame is drawn; the old two-theme startup (Lambda's dark fallback, then Sonokai) is gone. Theme-dependent faces hang on Emacs 29's `enable-theme-functions`.
- **Packages declared where used** with `:ensure t`; `init.el` refreshes archives once when none are cached. `embark-consult`, previously assumed to install transitively and absent, is now declared and installed. `kind-icon` dropped so `nerd-icons-corfu` is the one Corfu formatter.
- **Tangle with tracked outputs** kept: startup never tangles, a clone works, and `tools/tangle.el` (125 lines) is proportionate.
- **Frames mean full buffers, not panels.** The user's frames preference covers buffers you read or edit; sidebars, menus, gutters and the minibuffer stay inside each frame. `dired-sidebar` and `imenu-list` are kept as side windows and `diff-hl` is the git gutter (all under `SPC t`).
- **Dropped for good reasons:** icomplete fallback, `completion-preview`, the vertico-buffer internals override, the hand-rolled Info picker (`consult-info`), the help transient (a keymap shows in which-key), `peep-dired`, `vdiff-magit`, `git-gutter`, `mu4e`/`denote`/`citar` keys (not installed), `svg-tag-mode`, `reveal-mode`, `lambda-themes`, macOS appearance sync, Fuco's Lisp indent override, `multi-compile`, Homebrew and iTerm helpers, Colin's personal Org file openers and export helpers, `desktop`, time stamps, `anaphora`/`csetq`/`deftoggle`.
- **Added after the first trial (2026-09-14):** `org-modern` and `org-appear` (hidden markers shown at point), `avy` under `SPC j`, `meow-tree-sitter` things (`f` function, `a` class, `t` test, `y` entry, `,` parameter, `/` comment; the angle-bracket thing moved to `<`), `vundo` on `SPC b u`, `keycast` on `SPC t k`/`K`, Casual's menus on `?` in every localleader and `C-o` in the built-ins' own maps, and spell checking wired to `hunspell`/`aspell` on `PATH` or MSYS2's hunspell.
- **GNU ELPA needs a native gpg.** Emacs verifies the signed GNU ELPA index with the `gpg` that `gpgconf` reports; on Windows that is Git for Windows' MSYS `gpg`, which cannot open a Windows keyring directory, so the import yields nothing and every signature fails as "no public key" while the archive silently disappears. `epg` honours `epg-gpg-program` only when set through Customize and otherwise takes the first `gpg` on `exec-path`, so `early-init.el` puts Gpg4win's directory (the documented Windows dependency) first on `exec-path` and `PATH` when it is installed, and skips the check on Windows without it or anywhere without `gpg`. Verified: with that in place both GNU archives verify from a fresh keyring.
- **Licence is GPL-3.0-or-later**, matching the sources the code is distilled from; the old MIT file from Colin's tooling is replaced.
- **Kept from Lambda**, attributed per module header: sane defaults, scrolling and mouse settings, persistent scratch, the completion stack configuration, Helpful/Info setup, Dired extensions, Magit settings, project/tab/workspace setup with workspace-filtered buffers, Org display and agenda defaults, programming aids, Eshell settings and aliases, Tramp, the highlighting packages.

## 5. Verification

Batch, from the repository root (`EMACS_DOTS_TEST_PACKAGES` points at an existing `var/elpa`):

```sh
emacs -Q --batch -l tools/tangle.el -- --check
emacs -Q --batch -l tests/tangle-tests.el -f ert-run-tests-batch-and-exit
emacs -Q --batch -l tests/uwumacs-leader-tests.el -f ert-run-tests-batch-and-exit
emacs -Q --batch -l tests/verify-config.el
```

All four pass at every commit on this branch. The verifier starts the real configuration in an isolated copy with installation forbidden and asserts: `private.el` loads once and its overrides survive, `custom.el` loads from `var/etc`, every module feature is present, `SPC` is `uwumacs-leader-map` in both Meow state maps, `SPC l` and `SPC s l` owners, the dashboard's two buttons open the guide and the cheat sheet, theme toggling never stacks themes, and every cheat-sheet `SPC` row resolves to its command.

Not verified here, for the user to check on the real host:

- A graphical startup and the five frame tests (`M-x ert RET ^dots-frames- RET`).
- First start on a fresh clone (package installation path).
- Emacs 30.1: the stated floor; only 31.1 exists on this machine.

## 6. Open items

- `main` carries the physical-hint adapter (PR #4). This branch removes it; merging makes the literal leader the deployed behaviour.
- Installed packages that nothing declares any more remain in `var/elpa/` (for example `kind-icon`, `peep-dired`, `svg-tag-mode`, `lambda-themes`, the macOS, mail, notes, citation and LLM packages). Prune with `M-x package-autoremove` when convenient.
- Beacon state is untouched by the leader (as intended); `SPC` in Beacon is Meow's default.
- `uwumacs-leader-alt-key` is fixed at `C-c C-SPC` in the keys chapter; make it an option if it ever needs to change.

## 7. Extending

- **A key:** `(keymap-set uwumacs-leader-map "u x" #'my-command)` in `private.el`, or a group in `42-keys.org`. Labels: `(cons "label" #'command)`.
- **A mode menu:** `(uwumacs-define-localleader 'python-mode "r" (cons "run" #'python-shell-send-buffer))` next to the package.
- **A package:** a chapter with a `use-package … :ensure t` block, a Meow section, a manifest entry and a `require` in the startup chapter.

## 8. Refactor log

All on branch `dev/uwumacs-config-review-dc1bee`, each commit verified with the four batch checks.

| Commit | Step |
|---|---|
| `c0e7c97` | Delete the prototype core, GUI runner, unloaded Lambda modules and the process layer (−22,383 lines) |
| `cad3cf4` | Literal leader and localleaders (`41-leader.org`); hint adapter retired; editing chapter rewritten |
| `fc58c61` | Defaults chapter replaces eight Lambda modules |
| `81bb5f5` | Completion and help chapters; `embark-consult` installed; one Corfu formatter |
| `ddb2723` | Dired, VC and navigation chapters; Magit and Dired in Motion with localleaders |
| `6c694a4` | Shells, Org and programming chapters |
| `6bca85f` | Appearance chapter merges fonts, theme, mode line and faces |
| `8785b63` | Keys chapter owns the whole tree; Lambda's last modules gone |
| `0eea287` | Own 86-line startup replaces Lambda's bootstrap and the composition root |
| `210f91a` | `lisp/` and `uwumacs-*` names throughout |
| `cd0127a` | Sidebars restored and `diff-hl` gutter added after the user clarified that frames apply to full buffers, not panels |
| (next) | Org polish, avy, meow-tree-sitter, vundo, keycast, Casual menus, spelling wiring, gpg dependency, GPL-3.0-or-later licence |
