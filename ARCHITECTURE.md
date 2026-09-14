# UwUmacs / Emacs-Dots — architecture (observed state, 2026-09-13)

This file describes what is actually in the repository, not what the plans say should be. Interfaces are marked *(observed)*: descriptive, not contracts. It was written by reverse-engineering the tree at `90b763f` (branch `uwumacs`) and will be revised once the classification below is signed off.

## 1. Intent (user's words, 2026-09-13 — confirm)

UwUmacs is a user-friendly, batteries-included, opinionated and extensible Emacs configuration for one person, built on a small sane starter kit (Lambda-Emacs, Colin McLear's config) plus liked packages. It is Meow-first: selection → extension → action, with visual hints. It prefers spawning frames over windows so the desktop window manager manages them. Its main thrust is to be for Meow what Doom/evil-collection are for Evil: retire the Meow keypad, replace on-screen hints and internal keymaps with real literal maps, and integrate the initial package set with the Meow grammar in a clean, extensible way. It must stay learner-friendly: discoverable actions, visual hints, simple to modify and extend, with a heavily explanatory, tutorialised, wiki-style literate config.

## 2. Layers as they exist

| Layer | Where | Lines | Loaded at startup | Notes |
|---|---|---|---|---|
| Emacs startup (Lambda-derived) | `early-init.el`, `init.el`, `lambda-library/lem-default-config.el` | 853 + 176 | yes | Tangled from `literate/10-bootstrap.org`, which is 1,544 lines of copied vendor startup code with a documented local patch. |
| Lambda vendor modules | `lambda-library/lambda-setup/lem-setup-*.el` (41 files) | 9,913 | 24 of 41 | 17 modules (~3,014 lines) are never required. 258 defuns; the user layer references 10. `lem-setup-keybindings.el` carries agent edits ("Spec 09", "CLAUDE.md forbids…"), so the tree is not a pristine upstream snapshot. |
| User layer (`starter-*`) | `lambda-library/lambda-user/{config,early-config,starter-*}.el` | 1,391 | yes | Tangled from `literate/20…80-*.org`. Modest, idiomatic, well-commented. |
| Physical-hint adapter | `starter-setup-key-hints.el` | 98 | yes | Advises Meow keypad internals and Marginalia so hints show `SPC f f` instead of keypad translations. Also merged to `main` as PR #4. |
| UwUmacs core (in progress) | `lambda-library/lambda-user/uwumacs{,-maps,-state,-registry,-integration-core}.el` | 954 | **no** (not required anywhere) | Tangled from `literate/41-uwumacs-core.org` (94% code, 61 prose lines). Delivers one binding today: `SPC f f` → `find-file`, only if `uwumacs-mode` is enabled manually. |
| Literate sources | `literate/*.org` (11 chapters + index + framework + manifest.json) | 5,874 | no | Build: `tools/tangle.el` (125 lines) stages, validates, and copies changed outputs; generated `.el` is tracked. |
| Tests and tooling | `tests/*.el`, `tools/*` | 2,841 + 899 | no | 113 ERT tests + 10 Python. ~1,170 lines of GUI-runner machinery drive 11 graphical tests. |
| Docs / process | `docs/**` | 14,307 lines, 63k words | no | 38 ADRs (one day), spec, plan, 194-ticket catalogue (107 rows are built-in libraries), 8,187-line inventory JSON, progress ledger, Python validator enforcing four-way duplication. |

## 3. Startup flow (observed)

1. `early-init.el`: Lambda directories under `var/`, package archives, loads `early-config.el` (filters `lem-packages-alist` to 20 topics, adds `frames-only-mode`), installs declared packages.
2. `init.el`: Lambda dispatch → `config.el`.
3. `config.el` base stage: 10 `lem-setup-*` modules, then `starter-platform`, `private.el` (once), `starter-setup-fonts`, `starter-setup-literate`, `starter-setup-dashboard`.
4. `after-init-hook`: 9 more `lem-setup-*` (completion, **keybindings**, help, navigation, dired, search, vc, projects, tabs), then `starter-setup-meow` (which requires `starter-setup-key-hints`).
5. `emacs-startup-hook`: 7 more `lem-setup-*`, then `starter-setup-treesit`, `-languages`, `-terminal`, `-org`, `-ui` (loads Sonokai, replacing the `lambda-dark` theme loaded in stage 3), `-frames`.

## 4. Key ownership (observed)

`SPC` in Normal/Motion runs `meow-keypad`; the keypad's leader map is `lem+leader-map` (set in `starter-setup-meow.el:25`). Keypad modifier prefixes are disabled, so keys are literal except the keypad's own `C-` fallback at depth ≥ 2. Writers into the `SPC` tree:

| Writer | Adds | Where |
|---|---|---|
| `lem-setup-keybindings.el` | b c C M e f F **m**(mu4e, not installed) n(denote) q S s t u **g**(vc) w W `.` | vendor, via `bind-keys :prefix lem-prefix` |
| `starter-setup-meow.el` | ? / SPC ; [ ] { } TAB d i k **l**(vertico-repeat) p(project-prefix-map) r R **v**(vc again) | `meow-leader-define-key` |
| `starter-setup-dashboard.el` | h H | `meow-leader-define-key` |
| `starter-setup-terminal.el` | o | `meow-leader-define-key` |
| `starter-setup-languages.el` | **l** (overwrites vertico-repeat) | `meow-leader-define-key` |

Known damage: `SPC l` double-bound; `SPC m` opens a dead mail menu; `SPC g` and `SPC v` duplicate; `SPC p b` and `SPC p x` reach `project-list-buffers` / the `C-x` submap because the keypad tries `C-b`/`C-x` first (alignment review F7); `git-gutter` and `mu4e` commands are bound but not installed.

## 5. Components (observed, not specified)

| Component | Files | Responsibility | Interface (observed) | Tests | Status |
|---|---|---|---|---|---|
| Bootstrap | `early-init.el`, `init.el`, `lem-default-config.el` | Lambda startup, package policy, dispatch to user config | `lem-*` variables, `lem-packages-alist` | `verify-config.el` | existing |
| Composition root | `config.el`, `early-config.el` | choose Lambda modules and stage user modules | requires in three stages | `verify-config.el` | existing |
| Platform | `starter-platform.el` | shell selection per OS, project/org dirs, skip exec-path-from-shell on Windows | `starter-platform-apply`, two defcustoms | `verify-config.el` (project dir) | existing |
| Terminal | `starter-setup-terminal.el` | EAT with MSYS2 wrapper on Windows, `SPC o` menu | `starter-eat*`, `starter+terminal-keys` | none | existing |
| Meow grammar | `starter-setup-meow.el` | Colin's QWERTY grammar, mode-state list, keypad leader = `lem+leader-map` | `starter-meow-setup` | `key-hints-tests.el` (indirect) | existing |
| Hint adapter | `starter-setup-key-hints.el` | physical-key labels in keypad prompt, which-key title, Marginalia | advice on `meow--keypad-show-message`, `marginalia-annotate-binding` | 5 batch + 3 GUI | existing, planned for retirement |
| UwUmacs maps | `uwumacs-maps.el` | validated prefix customs, priority-layered map candidates, owner metadata, base reconciliation | `uwumacs-leader-map`, `uwumacs-user-leader-map`, `uwumacs--build-map-candidate`… | 13 | existing, unloaded |
| UwUmacs state | `uwumacs-state.el` | buffer-local emulation alist ahead of Meow, eligibility flags, transactional refresh across all buffers, 11 observation hooks | `uwumacs-mode`, `uwumacs-refresh`, `uwumacs-localleader-map` | 22 + 2 GUI | existing, unloaded |
| UwUmacs registry | `uwumacs-registry.el` | descriptor validation, dependency order, readiness states, setup/cleanup lifetimes, reentrancy rejection, `uwumacs-doctor` | `uwumacs-register/enable/disable-integration` | 26 + 1 GUI | existing, unloaded |
| Frames policy | `starter-setup-frames.el` | frames-only-mode with completion/popper/Magit exceptions | advice on `lem-display-magit-in-other-window` | 5 GUI | existing |
| Appearance | `starter-setup-fonts.el`, `starter-setup-ui.el`, `themes/doom-sonokai-theme.el` | fonts before dashboard, Sonokai, doom-modeline, nerd-icons, spacious-padding | `starter-ui-*` | `verify-config.el` | existing |
| Dashboard | `starter-setup-dashboard.el` | home page over dashboard.el, pixel-centred lines, `SPC h`/`SPC H` | `starter-dashboard-*` | `verify-config.el` | existing |
| Programming | `starter-setup-treesit.el`, `starter-setup-languages.el` | pinned grammar recipes, conditional remaps, Eglot opt-in, `SPC l` menu | `starter-treesit-*`, `starter+lsp-keys` | none | existing |
| Org | `starter-setup-org.el` | inbox capture templates, portable directory | none | none | existing |
| Literate build | `tools/tangle.el`, `starter-setup-literate.el`, `literate/manifest.json` | tangle to staging, validate, copy | `--check`/`--write`, `starter-literate-*` | 8 | existing |
| GUI runner | `tests/gui-setup.el`, `tests/gui-run.el`, `tools/run-gui-tests.ps1`, `tools/observed-keys.el` | isolated graphical Emacs, watchdogs, audit | env-var protocol | 10 runner tests | existing |
| Docs/process | `docs/**` | ADRs, plan, catalogue, validator | `validate-plan.py` | 10 Python | existing |

## 6. Verified alternative for the core (probe evidence, `scratchpad/probe-localleader-c.el`)

With the installed Meow (20260714.1200) and Emacs 31.1, this public-API design was executed in batch and behaves as required:

- `(meow-normal-define-key (cons "SPC" leader-map))` and `(meow-motion-define-key …)` make `SPC` a real prefix map in Normal and Motion; Insert keeps `self-insert-command`; `meow-keypad` stays callable.
- One buffer-local variable registered once in `emulation-mode-map-alists` holds `SPC m` → a keymap composed along `derived-mode-all-parents` (most specific first). Result: `emacs-lisp-mode` overrides `prog-mode` entries and inherits the rest; other buffers see nothing.
- `where-is-internal` returns `SPC f f` and `SPC m e`, so Marginalia's stock M-x annotation and `C-h k`/`C-h b` show physical keys with no adapter; which-key lists groups by their `(cons "label" map)` names.
- Total: about 20 lines.

## 7. Decision log

Resolved (inferred from code/docs, not confirmed by the user unless marked):
- Meow stays the editing engine; UwUmacs owns the leader. *(user)*
- frames-only-mode with completion/popper/Magit exceptions. *(user)*
- Literate Org is the source of truth; generated Lisp is tracked; startup never tangles. *(agent, 2026-09-11 plan)*
- Own the maps rather than mutate vendor maps; no read-key dispatch; transactional map commits; emulation alist ahead of Meow; registry with readiness states. *(agent, ADR-0003…0006)* — **challenged by §6**.
- Emacs 30.1 floor with a 31.1 host. *(agent, ADR-0008)* — no 30.1 environment exists in the checkout.

Open (for the user): see the numbered questions in the review message of 2026-09-13; answers will be recorded here.

## 8. Proposed classification (pending sign-off)

| Component | Proposal | Reason |
|---|---|---|
| UwUmacs maps/state/registry (954 lines + 1,877 test lines) | **Replace** | Re-implements keymaps, `with-eval-after-load`, hooks and `derived-mode-p` behind transactions and readiness states; delivers one binding; §6 does the job in ~20 lines. |
| Hint adapter (+ its tests, `observed-keys.el`) | **Delete** after the literal leader lands | Unnecessary once `SPC` is a real keymap. |
| Leader definitions (5 writers) | **Refactor** into one literate chapter with one `uwumacs-leader-map` and per-mode localleaders | Single owner, fixes `SPC l`/`m`/`g`/`v`/`p` damage. |
| Docs/process layer | **Replace** with `ARCHITECTURE.md` + a learner wiki; keep ADRs only for real decisions | 15 doc lines per code line; duplication enforced by validator. |
| Lambda vendor tree | **User decision** (keep / trim to loaded / extract used) | 17 unloaded modules; 10 of 258 defuns used; macOS/mail/notes policy leaks into keys. |
| `starter-*` user modules | **Keep**, light refactors | Sound and modest. |
| Literate build (`tangle.el`, tests) | **Keep** | Proportionate; make chapter 10 stop tangling vendor code (user decision). |
| verify-config, tangle-tests | **Keep** (slim verify-config) | Proportionate smoke tests. |
| GUI runner + runner tests | **User decision** (keep for frames tests, or delete) | 1,170 lines for 11 GUI tests. |
| Compatibility tests | **Delete** | Hardcode Emacs 30.1 and a directory that does not exist. |

## 9. Status

All components: *existing*. Nothing has been verified against a contract written after the review.
