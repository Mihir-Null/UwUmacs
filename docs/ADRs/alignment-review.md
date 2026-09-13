# UwUmacs Phase 1 alignment and efficacy review

Performed 2026-09-13 by the resuming agent, before any roadmap implementation. This tracked file is the Phase 1 evidence record required by the [handoff](../uwumacs/HANDOFF.md) and [ADR-0036](0036-review-first-development-handoff.md). It is not a numbered architectural decision.

## 1. Scope, environment and disposition

| Field | Value |
|---|---|
| Repository | `C:/Users/walnu/.config/emacs-dots` |
| Branch / revision | `uwumacs` at `3e2c86f`, 0 ahead / 0 behind `origin/uwumacs` after `git fetch --all --prune` |
| Reviewed range | `1f70a93..3e2c86f` (`8d2102f` frames, `2d7d070` architecture, `51c19c1` hints, `3e2c86f` ADR backfill) |
| Dirty files at start | `docs/ADRs/README.md`, `docs/ADRs/index.json`, `docs/uwumacs/README.md`, `docs/uwumacs/validate-plan.py` modified; `docs/ADRs/0036-*.md`, `docs/ADRs/implementation-state.md`, `docs/uwumacs/HANDOFF.md` untracked |
| Disposition of dirty files | Retained unchanged. All are the handoff's own preparation output; none were reset, stashed or overwritten. |
| Emacs available | `C:/Program Files/Emacs/emacs-31.1/bin/emacs.exe` (31.1) — the only installed Emacs on this host |
| Meow | `var/elpa/meow-20260714.1200` (matches the recorded compatibility target) |
| Other worktrees | `var/worktrees/sonokai` (detached `2836452`) and `C:/Users/walnu/.config/emacs-dots-ci` (`dev-ci`) — neither modified |
| Isolated checkout | Not created. No runtime source was edited in this phase; see finding F2 disposition. |

Live repository state took precedence over the dated snapshot, and matched it in every field checked.

## 2. Checks actually run in this session

These are fresh results from this session, not inherited claims.

| Check | Command | Result |
|---|---|---|
| Documentation gate | `python docs/uwumacs/validate-plan.py --check-source-snapshot` | PASS — 194 tickets, 160 configured names, 144 installed accounted for, 63 inventory-only, 36 ADRs with full contract coverage |
| Whitespace | `git diff --check` | PASS (clean; CRLF advisories only) |
| Tangle determinism | `emacs -Q --batch -l tools/tangle.el -- --check` | PASS — 17 generated files match |
| Tangle tests | `tests/tangle-tests.el` | PASS — 8/8 |
| Focused hint tests | `tests/key-hints-tests.el` | PASS — 5/5 |
| Isolated startup | `tests/verify-config.el` | PASS — `EMACS-DOTS-VERIFY PASS`, `Failures: nil` |
| Frame policy tests | `tests/frames-tests.el` (batch) | 5 SKIPPED, 0 executed — see F2 |
| Graphical hint tests | `tests/key-hints-gui-tests.el` | Not executed — no runner exists; see F2 |
| Meow mechanism probes | 4 batch probe scripts against the installed Meow | See F1, F3 |

Emacs 30.1 was not exercised: no 30.1 installation exists on this host (F8).

## 3. Requirement coverage

| # | User requirement | Design | Task | ADR | Evidence and assessment | Corrective action |
|---|---|---|---|---|---|---|
| R1 | Keep Meow's editing grammar and states | section 2, 6 | P01–P03 | 0002, 0004 | Sound. Meow retains states; UwUmacs adds one emulation entry ahead of Meow's. Verified: deactivating restores `meow-keypad` exactly. | None |
| R2 | Extensible literal leader, local menus, per-package integrations | section 5, 6 | P01–P03, P07–P16 | 0003, 0005, 0006 | Verified mechanism. Literal `SPC f f` resolves to `find-file` while Meow normal state is genuinely active. | Record the ORDER requirement (F3) |
| R3 | SPC menus and M-x show physical keys that work in the originating buffer | section 8 | P04 | 0007 | Design sound, unproven at runtime. The `uwumacs-command-keys` contract is correct in principle; no implementation exists yet. | Keep P04's exact-annotation cases |
| R4 | Maintain real literal maps; hint adapter is a bridge | section 9 | P00, P05 | 0018 | Accurate. Adapter committed at `51c19c1`, tests pass, ADR-0018 correctly marked implemented-with-planned-replacement. | None |
| R5 | Frames-only preference with intentional exceptions | section 9 | P06 | 0017 | Implemented but unverified in this session. All 5 frame tests skip in batch. | F2 |
| R6 | Prioritize enabled configurations only | section 1 | all | 0013 | Consistent. Validator enforces 63 inventory-only exclusions; no disabled package is scheduled. | None |
| R7 | Order: core/discovery/branding, then integrations, then package | section 1, plan 1 | P00–P17 | 0014 | Consistent and dependency-ordered. | None |
| R8 | Every integration needs its own acceptance evidence | plan 4, 6 | P07–P16 | 0021–0030 | Consistent. Plan forbids marking a wave complete on file load. `progress.json` not yet created, which is correct because implementation has not started. | Create at P00/P07 |
| R9 | Review efficacy; prior choices not infallible | — | Phase 1 | 0036 | This document. Three architecture claims independently re-verified; one corrected (F4). | — |
| R10 | Record state and decisions durably in `docs/ADRs/` | — | ongoing | 0001, 0036 | Consistent. State log and ADR policy present and honest about status. | Update state log |

## 4. Task consistency (P00–P17)

| Task | Producer to consumer contract | Finding |
|---|---|---|
| P00 | Produces rollback checkpoint, test loader, observed-key report | Under-specified. Must also produce the graphical runner (F2). Its observed-keys step is the right place for the F6/F7 data gathered here. |
| P01 | Produces `uwumacs-leader-map`, `uwumacs-user-leader-map`, customization; consumed by P02/P04 | Sound. The first ERT example is trivially true (it proves Emacs keymaps work) but is explicitly a contract anchor, not an acceptance test. Acceptable as written. |
| P02 | Produces `uwumacs-mode`, `uwumacs-refresh`, localleader, emulation lifecycle; consumed by P03/P04 | Defect (F1). Fixture guidance lacks the safe state-entry idiom and a negative control, so tests can pass without shadowing Meow. |
| P03 | Produces registry APIs and descriptor semantics; consumed by P04 and every wave | Sound. Enable-twice/disable-twice and pending-disable cases are real behavior tests. |
| P04 | Consumes P01 maps and P03 owner metadata; produces `uwumacs-command-keys`, Which-key labels, live help | Sound. The "not a substring that also matches `C-c C-SPC`" guard is a genuine anti-overfit control. Depends on GUI evidence (F2). |
| P05 | Consumes P00 observed bindings and P04 discovery; produces a single leader owner | Sound and correctly atomic: it removes the literate block, generated file, manifest entry, require and advice together. Needs F6/F7 data. |
| P06 | Consumes P05; produces milestone 1 acceptance | Blocked by F2 until a runner exists. |
| P07–P16 | Each consumes the P06 core; all write `literate/43-uwumacs-integrations.org`, `literate/manifest.json` and `docs/uwumacs/progress.json` | Serial order and the single-writer rule are correct. See shared-file rows below. |
| P17 | Consumes tested core; produces standalone artifact | Capability-limited (F8): the Emacs 30.1 gate cannot run on this host. |

### Shared file and interface pairs

| Shared artifact | Tasks | Contract | Finding |
|---|---|---|---|
| `literate/41-uwumacs-core.org` | P01, P02, P03 | Sequential authorship of one chapter | Safe under the one-writer rule. P02/P03 also modify P01 outputs, so P01 tests must be re-run each time. |
| `literate/42-uwumacs-discovery.org` | P04, P06 | Discovery, then branding | Safe. P06 must not silently alter P04 annotation behavior. |
| `literate/43-uwumacs-integrations.org` | P07–P16 | Ten waves, one file | Highest contention point. The serial order plus "add only the wave's new output to the manifest" is adequate only if strictly serialized. |
| `literate/manifest.json` | P01–P17 | Every new flat output registered before tangle | Tangle validator rejects nested outputs; verified enforced (17 files match). |
| `docs/uwumacs/progress.json` | P07–P16 | One entry per catalogue ID | Does not yet exist; must be created before the first wave ticket is closed. |
| `tests/verify-config.el` | P05, P17 | Assert core and adapters instead of the retiring hint feature | Currently passes while asserting the hint feature; P05 must update it in the same change that removes the adapter. |
| `uwumacs-command-keys` | P04 to Marginalia adapter, P06 GUI | Must honor remapping and overriding maps | Contract correct; `overriding-terminal-local-map` precedence verified natively (F3). |

## 5. Findings

### F1 — Meow state fixtures can pass without proving the central behavior (High)

**Affected:** plan P02, ADR-0004, future `tests/uwumacs-state-tests.el`.

Under `meow-global-mode` a fresh buffer is already in normal state with `meow-normal-mode` set to `t`. Calling `(meow-normal-mode 1)` — the obvious fixture idiom — re-enters the minor mode: the body generated by `meow--define-state-minor-mode` calls `meow--disable-current-state`, which turns the mode back off. Observed result: `meow-normal-mode` is `nil` while `meow--current-state` remains `normal`.

Because Meow's emulation entry is `((meow-normal-mode . meow-normal-state-keymap))`, the normal-state keymap goes inactive and `SPC` falls through to `self-insert-command`:

```
after (meow-normal-mode 1): mode var  => nil
after (meow-normal-mode 1): state     => normal
after: SPC                            => self-insert-command
```

A fixture built this way then activates UwUmacs, asserts that `SPC f f` runs `find-file`, and passes without ever shadowing `meow-keypad` — it only proves a keymap was added to an otherwise empty slot.

The safe idiom, already used correctly by `tests/key-hints-gui-tests.el:14`, is `(meow--switch-state 'normal)` followed by `(should (meow-normal-mode-p))`.

**User impact:** the requirement that a literal leader replace keypad in real Normal state could be reported verified while untested.

**Disposition:** P02's brief must require (a) `meow--switch-state` plus a `meow-normal-mode-p` assertion, (b) a negative control asserting `(key-binding (kbd "SPC"))` is `meow-keypad` before activation, and (c) a restoration assertion after deactivation. **Owner:** P02. **Verification:** the three assertions above.

### F2 — No reproducible graphical runner; the graphical baseline is unverified (High)

**Affected:** `tests/frames-tests.el`, `tests/key-hints-gui-tests.el`, `tools/`, plan P00 and P06, ADR-0015, ADR-0017.

All 8 graphical tests are gated on `(skip-unless (display-graphic-p))`. In batch the 5 frame tests report SKIPPED and nothing executes. `tools/` contains only `tangle.el`; no graphical runner is committed, so the handoff's "three graphical tests passing" cannot be reproduced from this repository.

Prototype work done in this session (kept in scratch, not committed) established three reusable facts:

1. The runner pattern itself is sound: under `emacs -Q` it detects the display, discovers and runs ERT tests, writes a UTF-8 result and exits only its own process (`EMACS-DOTS-GUI PASS`).
2. A hang must be assumed. A modal Windows dialog freezes the event loop and every timer with it, so a watchdog timer alone cannot rescue a blocked run. The runner must also disable `use-dialog-box` and `use-file-dialog`, and append per-test progress so a block names the test that caused it.
3. Isolation must arm before any config code runs. A first attempt appended the package-directory override and install blocker to the end of the copied `early-init.el`; that code was never reached, and the session began downloading packages into the temp root. A wrapper `early-init.el` that arms the override and then loads the real file prevents this (verified: 0 downloads). Even so, an `--init-directory` start did not reproduce normal module loading (`meow` and `which-key` not loaded), unlike `tests/verify-config.el`, which loads `early-init.el` and `init.el` itself and succeeds.

No user Emacs process was running at any point. Every instance started here was stopped, all temp roots were removed, and the real `var/elpa` (145 packages) and the working tree were verified unchanged afterwards.

**User impact:** milestone 1 acceptance, frames policy and the physical-hint rendering claims all rest on graphical behavior that currently has no executable evidence.

**Disposition:** P00 builds `tests/gui-setup.el` and `tests/gui-run.el` (or equivalent) using the wrapper isolation above, then re-runs both graphical suites and records explicit results. Until then the graphical baseline is unverified, not passing. **Owner:** P00, then P06. **Verification:** a committed runner reporting 5/5 frame and 3/3 hint tests executed, with zero skips.

### F3 — Emulation-map ordering verified, with one required correction (Medium)

**Affected:** architecture section 6 step 1, ADR-0003, ADR-0004, P01/P02.

Meow registers three literal alists, not symbols, via `add-to-ordered-list` with no ORDER argument (`meow-core.el:167-172`), so they sort to the end of `emulation-mode-map-alists`.

Verified against the installed Meow with a genuinely active normal state:

| Probe | Result |
|---|---|
| `add-to-ordered-list 'emulation-mode-map-alists 'uwumacs--emulation-alist 100` | symbol lands at index 0, ahead of Meow |
| normal state before activation | `SPC` runs `meow-keypad` |
| after activation | `SPC` is a prefix keymap; `SPC f f` runs `find-file` |
| after deactivation | `SPC` runs `meow-keypad` (clean restoration) |
| second buffer, not activated | `SPC` runs `meow-keypad` (buffer-local isolation holds) |
| insert state | `SPC` runs `self-insert-command` |
| `overriding-terminal-local-map` bound | `SPC` runs `ignore` (temporary maps still win) |

The architecture's mechanism is therefore sound as designed. The correction: because Meow's entries are unordered, UwUmacs must pass an explicit numeric ORDER. An `add-to-list` or unordered add would place UwUmacs after Meow and be shadowed — the exact opposite of the intent.

**Disposition:** state the ORDER requirement in architecture section 6 and in ADR-0003/0004 so no implementer re-derives it. **Owner:** P01/P02. **Verification:** the table above as ERT cases.

### F4 — `embark-consult` is undeclared, not merely unavailable (Medium)

**Affected:** architecture section 9 and plan P07, ADR-0021, catalogue wave 2A.

The architecture says `embark-consult` is "declared but unavailable". The stronger, accurate finding is that it is not declared anywhere. Its only mention is a comment in `literate/10-bootstrap.org:600` asserting that sub-packages install transitively with their parent. `var/elpa` contains `embark-1.2.0.20260812.23` and no `embark-consult`, so the assumption is wrong for this archive.

**User impact:** consult-aware Embark actions are silently absent, and a P07 ticket phrased as "validate the existing declaration" would be validating something that does not exist.

**Disposition:** correct the architecture wording, and have P07 add an explicit host declaration and prove a real load. **Owner:** P07. **Verification:** `(require 'embark-consult)` succeeds after an explicit declaration.

### F5 — Competing Corfu formatters confirmed, across the vendor boundary (Low)

Both writers exist, as the architecture claims:

- `lambda-library/lambda-setup/lem-setup-completion.el:555` adds `kind-icon-margin-formatter`, guarded by `lem-load-extras` and `(locate-library "kind-icon")`; `kind-icon-0.2.2.0.20250311.112658` is installed.
- `lambda-library/lambda-user/starter-setup-ui.el:123`, generated from `literate/50-appearance.org:462`, adds `nerd-icons-corfu-formatter`.

The kind-icon writer lives in the vendored Lambda tree, which architecture section 9 keeps unchanged. P07 must therefore resolve the duplicate at runtime rather than by editing the vendor file, as the plan already states. Effective order is `add-to-list` dependent and must come from P00's runtime capture, not from source reading.

### F6 — `SPC l` double writer confirmed (Low)

`literate/40-editing.org:97` binds `("l" . vertico-repeat)`; `literate/60-programming.org:470` later binds `("l" . starter+lsp-keys)`. The later write wins, so the LSP submenu is the effective owner and `vertico-repeat` is shadowed — matching the architecture's migration entry of `SPC s l`.

### F7 — `project-prefix-map` modified keys enumerated (Low)

Exactly two entries are unreachable literally, confirming the architecture's caution with concrete data:

| Key | Binding |
|---|---|
| `C-x` | nested keymap, giving `C-x s` for `project-save-some-buffers` |
| `C-b` | `project-list-buffers` |

All 20 other entries are plain or shift-modified printable keys. P05 can define the literal submenu from this list without re-deriving it.

### F8 — The Emacs 30.1 compatibility floor has no executable environment (Medium)

ADR-0008 and the global constraints set a 30.1 minimum, and P17 requires running the core gate on 30.1. This host has only Emacs 31.1 (`C:/Program Files/Emacs/emacs-31.1`; no other install on PATH).

**Disposition:** either provision a 30.1 build before P17 or record 30.1 as an explicit, documented capability limitation. Per ADR-0015 and the plan, an unexecuted environment must not be called supported-by-test. **Owner:** P17.

### F9 — `uwumacs-leader-alt-key` default is free (informational)

`C-c C-SPC` and `C-c SPC` are both unbound in vanilla Emacs 31.1. Note that Meow's default leader is `mode-specific-map`, the global `C-c` map; the current config overrides this with `(add-to-list 'meow-keymap-alist (cons 'leader lem+leader-map))` in `starter-setup-meow.el:25`, so the alt leader does not collide with the host's leader contents. P05 should keep that override in mind when retiring `meow-leader-define-key` writers.

## 6. Acknowledged limitations of this review

- No graphical test was executed (F2). Frames and rendered-hint behavior remain unverified in this session.
- No Emacs 30.1, Linux, or daemon/terminal environment was exercised (F8).
- Probe scripts were run in scratch and are not committed. Their results are reproduced above rather than being re-runnable from the repository until P00 lands fixtures.
- The catalogue's 194 tickets were checked for structural coverage via the validator, not individually re-derived against each installed package's source.

## 7. Execution gate

| Prerequisite | State |
|---|---|
| Repository state, branch and provenance | Ready — verified clean and in sync |
| Documentation, ADR coverage and validator | Ready — full-coverage PASS |
| Batch baseline (tangle, hints, startup) | Ready — fresh PASS results |
| Core emulation mechanism | Ready — verified against installed Meow (F3) |
| Graphical baseline and runner | Blocking P06 only — P00 must land a runner (F2) |
| P02 fixture design | Blocking P02 until the negative control is specified (F1) |
| Emacs 30.1 gate | Capability-limited — resolve or document at P17 (F8) |

**Verdict:** no prerequisite design defect blocks the roadmap. The architecture's central mechanism is verified, not merely asserted. Two findings, F1 and F2, are test-design and tooling defects that must be fixed inside P00 and P02 before their dependent gates are claimed, and both are contained within tasks the plan already schedules. Corrections F3 and F4 are documentation fixes applied alongside this review.

P00 may begin immediately, carrying F2 (the graphical runner) and the F6/F7 runtime data as explicit deliverables. P02 may not close until F1's negative control exists. No structural refactor of the plan is justified by this review: task decomposition, ordering and interfaces held up under checking.
