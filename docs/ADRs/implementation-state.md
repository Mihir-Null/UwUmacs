# UwUmacs implementation state

Updated 2026-09-13 after inspecting P00's changes, task review, scoped re-review and on-disk audit. This tracked resumption record supersedes the stale pre-P00 checkpoint; earlier execution-log entries remain historical.

## Current checkpoint

| Field | Recorded state |
|---|---|
| Phase | Phase 1 and P00 complete; P01 onward paused by the user's current instruction |
| Repository / branch | `C:/Users/walnu/.config/emacs-dots`, `uwumacs` |
| Reviewed P00 code | `21dbebc..ad49657`; all eight scoped fix findings addressed, no new Critical/Important breakage per the recorded re-review |
| Runtime baseline | Frames in `1f70a93`; physical hints in `51c19c1`; no UwUmacs literal runtime exists |
| Working checkout | Original checkout by prior user decision; sibling branches/worktrees remain separate |
| Active roadmap task | None; do not begin P01 without a new user instruction |
| Integration acceptance | All 194 tickets remain pending; P00 fixture completion is not adapter acceptance |
| Review evidence | Phase 1 in [alignment-review.md](alignment-review.md); P00 review and findings summarized below |
| Next action | Finish publishing the retired handoff and the lightweight hints branch's corrected guide; leave roadmap execution paused |

### P00 evidence inspected

- Implementer/controller report: helper tests 10/10, runner tests 9/9, focused hints 5/5, tangle 17 outputs matching and isolated startup PASS. These are P00-session results, not new executions during retirement.
- Reviewed GUI run records: frames 5/5 and hints 3/3, at least three consecutive green runs per suite, zero skips. The missing package-initialize advice resolved F2; graphical tests were timing-hardened without changing their assertions.
- Read `var/uwumacs-audit/observed-keys.json`: graphical capture stamped `ad49657276a7da4dfc6af58431089d439465b56a`, worktree dirty=false at capture, 144 activated packages, errors empty. The artifact is ignored local evidence; its generator is tracked at `tools/observed-keys.el`.
- Scoped fix review over `94e8611..ad49657` records all eight findings addressed. The no-execution guard and its six-case regression make PASS unreachable if nothing ran. The independent audit provenance check closes the artifact verification gap noted by that review.
- F1's helper negative-control fixture is now tested; P02 still must test the future implementation's activation/restoration against genuinely active Meow. F8 (Emacs 30.1 unavailable) remains a P17 capability limit.

### Findings preserved from ignored review scratch

| Finding | Evidence / current disposition |
|---|---|
| FX1: dead `SPC ?` | `consult-apropos` is not fbound on the inspected host; no claim is made that it was removed upstream. Guide must offer `M-x apropos-command`/`M-x` and label the broken binding. Runtime repair remains P05. |
| FX2 / F7: project shadowing | 25 top-level project entries, 23 plain/shift and 2 modified. Four affected paths: `p C-b`, `p C-x`, `p b`, `p x`. Meow dispatch simulation reaches `project-list-buffers` from `SPC p b`, the Control-x submap from `SPC p x`, and `project-save-some-buffers` from `SPC p x s`. `consult-project-buffer` and `project-execute-extended-command` need native/M-x access until P05. Simulation is not a claim of physically typed GUI evidence. |
| F6 correction | `SPC l` owns LSP; `SPC s l` already reaches `vertico-repeat`. A future migration must preserve that existing route, not claim to invent it. |
| FX3: weak guide row gate | Raw `lem+leader-map` equality does not prove a command exists or that keypad dispatch reaches it. Guide checks must distinguish native leader input from keypad input; the audit demonstrates both failures. |
| F4 / F5 | `embark-consult` absent and undeclared; two graphical Corfu formatters, with kind-icon first. Repairs remain P07; no package policy changed here. |

Deferred review limitations remain open: parent timeout/termination path not exercised end-to-end; runner-test global counts not restored; helper cursor escape output; duplicate depth predicate; large audit-report function; missing isolated setup batch test; root sentinel polish. These do not become completed roadmap work through handoff retirement.

### P00 rulings preserved

The reviewed P00 workflow selected an isolated GUI root with a wrapper early-init and package-directory advice (avoids live-state writes; may miss deployment-only defects), an opt-in Meow-state macro with negative/restoration controls (enables meaningful P02 tests), at least three consecutive graphical passes (limits timing claims), separate processes per suite with invariant checks (extra startup cost), sorted graphical audit capture with source provenance (avoids batch-only presentation assumptions), and an all-pending progress seed (not implementation evidence). See the tracked runner notes and code for implementation detail. These are inherited P00 choices, not new runtime changes by the retirement task.

## Roadmap state

| Task | Deliverable | Status |
|---|---|---|
| P00 | Baseline verification and fixtures | complete — `21dbebc..ad49657`, review clean |
| P01 | Native maps and customization | pending |
| P02 | State activation and localleaders | pending |
| P03 | Registry and lifecycle | pending |
| P04 | Discovery and annotations | pending |
| P05 | Host migration | pending |
| P06 | Branding and frame/GUI acceptance | pending |
| P07 | Completion integrations | pending |
| P08 | Help integrations | pending |
| P09 | Dired integrations | pending |
| P10 | Version-control integrations | pending |
| P11 | Navigation integrations | pending |
| P12 | Org integrations | pending |
| P13 | Programming integrations | pending |
| P14 | Terminal integrations | pending |
| P15 | Appearance compatibility | pending |
| P16 | Runtime compatibility | pending |
| P17 | Standalone core and release gates | pending |

Keep this table synchronized with plan checkboxes and the per-ticket progress file when created. A capability limitation or parked review finding is not completed acceptance.

## Execution log

- 2026-09-13 — Inspected P00 code, Phase 1 findings, task critique and scoped fix review, and verified audit provenance on disk. Completed the partially drafted handoff retirement under [ADR-0037](0037-execution-contract-replaces-handoff.md), preserving standing intent in [execution-contract.md](execution-contract.md). The user explicitly paused P01 onward and requested guide corrections on the lightweight hints branch. No new roadmap implementation was started.

- 2026-09-13 — **Execution transferred to a terminal session with the `superpowers` plugin installed.** That plugin was unavailable during the review, so Phase 1 ran as a plain controller workflow; P00 onward should use `superpowers:subagent-driven-development` as the original handoff intends. Per user decision, work continues in the **original checkout** rather than an isolated worktree: the temporary `uwumacs-impl` worktree was removed and its branch deleted, losing nothing because no commits were made in it. Preserved the review session's graphical-runner prototype and its three paid-for hazards in [gui-runner-notes.md](../uwumacs/gui-runner-notes.md) before scratch cleanup, and added a session-update section to the [execution contract](execution-contract.md). Branch `uwumacs` at `5c04812`, one commit ahead of `origin/uwumacs`, not pushed. Next: P00, with the graphical runner (F2) as its first deliverable.
- 2026-09-13 — **Phase 1 alignment review completed**; evidence in [alignment-review.md](alignment-review.md). Reviewed `1f70a93..3e2c86f` plus the uncommitted handoff files (retained unchanged). Re-ran the documentation gate, tangle check, tangle tests, focused hint tests and isolated startup — all PASS; `frames-tests.el` reported 5 SKIPPED in batch and the graphical hint tests did not execute. Probed the architecture's central mechanism against installed Meow 20260714.1200 and **verified** it: a symbol added to `emulation-mode-map-alists` with an explicit numeric ORDER lands ahead of Meow, shadows a genuinely active `meow-keypad` SPC, resolves `SPC f f` to `find-file`, restores `meow-keypad` on deactivation, leaves other buffers and Insert state untouched, and still yields to `overriding-terminal-local-map`. Nine findings recorded: F1 (High — Meow state fixtures can pass without proving shadowing; `(meow-normal-mode 1)` silently deactivates the state keymap), F2 (High — no reproducible graphical runner exists; graphical baseline unverified), F3/F4 (Medium — architecture corrections, applied to `docs/superpowers/specs/2026-09-13-uwumacs-design.md` sections 6 and 9), F5/F6/F7 (Low — vendor-boundary Corfu formatters, `SPC l` double writer, and the two unreachable `project-prefix-map` keys, all confirmed with runtime data), F8 (Medium — no Emacs 30.1 on this host), F9 (informational). No structural refactor of the plan was justified; task decomposition, ordering and interfaces held up under checking. No runtime source was edited and no isolated checkout was created, so the deployed configuration is unchanged. Every Emacs instance started for probing was stopped and all temporary roots removed; the real `var/elpa` (145 packages) and the working tree were verified unchanged. Affected ADRs: 0003, 0004 (ORDER requirement), 0021 (embark-consult), 0036 (review performed). Unresolved: F1 before P02 closes, F2 before P06 closes, F8 before P17 claims 30.1 support. Next: P00, carrying the graphical runner and the F6/F7 observed-key data as explicit deliverables.
- 2026-09-13 — Prepared [standing execution contract](execution-contract.md) and [ADR-0036](0036-review-first-development-handoff.md) at the user's request. Inspected branch/history and planning/ADR documentation. The user also authorized plan changes and significant structural or other refactors justified by that review; ADR-0036 and the handoff record this authority. No alignment verdict, runtime implementation, milestone completion or new runtime test result is claimed. Next: Phase 1 review, then P00.

Append dated updates with task/ticket IDs, code/review commits, checks and results, limitations, affected ADRs, unresolved findings and exact next action. Keep the checkpoint table current. Store the Phase 1 findings in docs/ADRs/alignment-review.md when that review is performed. Preserve this log across compaction and scratch cleanup.
