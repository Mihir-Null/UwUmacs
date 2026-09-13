# UwUmacs implementation state

Updated 2026-09-13 after the user resumed development and authorized GitHub synchronization. This tracked resumption record supersedes the stale pre-P00 checkpoint; earlier execution-log entries remain historical.

## Current checkpoint

| Field | Recorded state |
|---|---|
| Phase | Phase 1 and P00–P02 complete; P03 next |
| Repository / branch | `C:/Users/walnu/.config/emacs-dots/var/worktrees/uwumacs`, `uwumacs` |
| Reviewed P00 code | `21dbebc..ad49657`; all eight scoped fix findings addressed, no new Critical/Important breakage per the recorded re-review |
| Runtime baseline | P01–P02 native maps/state runtime at `e915905`; host migration remains P05; inherited frames/hints remain active in the host |
| Working checkout | Isolated linked worktree; deployed main checkout remains separate |
| Active roadmap task | P03 registry, readiness and lifecycle |
| Integration acceptance | All 194 tickets remain pending; P01/P02 foundation completion is not individual integration acceptance; ADR-0038 assigns each acceptance task |
| Review evidence | Phase 1 in [alignment-review.md](alignment-review.md); P01 review clean; P02 original review plus three scoped fix reviews, summarized below |
| Next action | Implement P03 with the reviewed native-map/state interfaces, eight assigned support checks and exact Windows Emacs 30.1; continue through P17 with review and GitHub sync |

### P00 evidence inspected

- Implementer/controller report: helper tests 10/10, runner tests 9/9, focused hints 5/5, tangle 17 outputs matching and isolated startup PASS. These are P00-session results, not new executions during retirement.
- Reviewed GUI run records: frames 5/5 and hints 3/3, at least three consecutive green runs per suite, zero skips. The missing package-initialize advice resolved F2; graphical tests were timing-hardened without changing their assertions.
- Read `var/uwumacs-audit/observed-keys.json`: graphical capture stamped `ad49657276a7da4dfc6af58431089d439465b56a`, worktree dirty=false at capture, 144 activated packages, errors empty. The artifact is ignored local evidence; its generator is tracked at `tools/observed-keys.el`.
- Scoped fix review over `94e8611..ad49657` records all eight findings addressed. The no-execution guard and its six-case regression make PASS unreachable if nothing ran. The independent audit provenance check closes the artifact verification gap noted by that review.
- F1 is now resolved for the P02 implementation: genuinely active Meow resolves SPC to meow-keypad before activation and is restored after disable. F8's runtime-availability limitation is resolved by isolated Windows/Linux 30.1 provisioning; actual minimum-version core acceptance is P03, with final P17 revalidation still required.

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
| P01 | Native maps and customization | complete — `e703f7e..075fb53`, review clean |
| P02 | State activation and localleaders | complete — `19129aa..e915905`, review clean |
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

- 2026-09-13 — P02 complete at `e9159050074538fdad5f0be658e085403cc9ba4c` (initial `a4eadf8`, fixes `f389685`, `71e6fb1` and `e915905`). Independent initial review found equal-priority defaults bypass and first EAT input interception; scoped round 1 addressed both but found public base-map edits lost on refresh; scoped round 2 addressed public edits but found a false conflict between overlapping native composed layers; round 3 addressed that traversal defect with no new Critical/Important breakage. Fresh focused core/state/runner ERT 45/45, graphical state 24/24 with zero failures/skips/invariant violations, 21 generated outputs matching and strict compilation 4/4 passed. The unchanged tangle-tool regression last passed 8/8 at the preceding fix and was not rerun as if it were new evidence. Final graphical artifact `state-1-20260913-181552` matches the runtime commit; only controller-owned documentation was dirty, and the generic JSON records counts rather than embedding the commit. All owned GUI processes/frames/roots were cleaned. A PowerShell cache write stayed inside the disposable home and was removed. P02 does not enable the host or complete the 194 integration tickets.

  P02 rulings: validate foundation and context together to reject equal-specificity conflicts; observe EAT exec/exit hooks synchronously before the next key lookup; retain committed map metadata for discovery; reconcile actual native public base edits on refresh (unchanged definitions retain declaration ownership/priority, changes use public-base priority zero), while user overrides stay directly composed. Alternatives were silent overlay order, late pre-command observation and reconstruction from stale declarations; each produced a confirmed regression. ADR-0003/0004/0005/0009 and the architecture record the implemented boundaries. Broader temporary-input, terminal, daemon/TUI and minimum-version acceptance remain their assigned tasks.

  ADR-0038 assigns acceptance ownership throughout P01-P17 without changing any of the 194 contracts or historical census hashes. I009 runs first at P03 and again at P17; I020 final acceptance follows hint retirement at P06. Windows30.1 official complete ZIP SHA-256 `a58e44f1d3ecf5bac1a920fe9d83656f0c45ef3034ac4b4d185ee5c057ac7a4a` and GNU signatures were verified (signer fingerprint `ECE77CF417C76C1ACFCE7C2B5B6135511580F007`). Linux30.1 uses Nixpkgs `bf9fa86a9b1005d932f842edf2c38eeecc98eef3`; both environments have isolated runtime probes only so far. Retained source-only Meow is snapshot `20260714.1200`, commit `aa8aec19e70369b547176e625f5b95c4a8565e8e`. Installed packages and system profiles were not modified. Next: P03 registry/lifecycle and eight assigned foundational checks; actual package/core acceptance has not been inferred from provisioning.

- 2026-09-13 — P01 complete, implementation `73d403f`, reviewed metadata fix `075fb53`; scoped re-review found both findings addressed and no new breakage. Focused ERT 13/13; tangle 20 matching outputs; strict compilation 3/3; inert isolated core load and dependency scan passed. Equivalent native events now share metadata identity, and explicit empty metadata stays empty. P01 builds native maps/customization without enabling the host. No integration ticket is marked accepted merely by the foundation. Updated ADR-0003/0005/0009/0019 implementation descriptions and reconciled historical ADR-0036/0037 hold text. User explicitly selected full P01–P17 scope in this run. Next: P02; add exactly one successful Customize refresh, genuine active-Meow restoration tests, isolated localleaders and actual graphical state evidence. Emacs 30.1 and Linux dependencies are being provisioned separately; no compatibility execution is claimed yet.

- 2026-09-13 — User resumed development and explicitly authorized GitHub sync for all commits. Reconciled branch `uwumacs` at `9913dbc` with `origin/uwumacs` (equal), created the isolated linked worktree, and verified the documentation census gate, tangle (17 matching outputs), and helper tests (10/10). Read-only architecture review found no need to restructure P01–P06; native-map composition, transactional validation, genuine Meow-state fixtures and effective lookup remain the gates. The named architecture-first pair-programming skill was unavailable after bounded local search; architecture review uses the tracked spec/ADRs and GNU/Meow primary sources. Next: P01. Earlier pause entries below are historical.

- 2026-09-13 — Published `feat/meow-physical-key-hints` at `77db4db`: original hints adapter cherry-picked as `fbb3ca2`, followed by guide/ADR-0038 corrections from P00. Fresh checks on that branch: 35 callable guide rows and Meow dispatch paths, documented project/native exceptions, five hint tests, isolated startup and tangle (17 outputs) all passed. The guide and its branch-local ADR are on that branch; no P00 tooling or UwUmacs roadmap was merged into it. The current `uwumacs` guide remains the historical baseline for future migration. Returned to `uwumacs`; P01–P17 remain paused.

- 2026-09-13 — Inspected P00 code, Phase 1 findings, task critique and scoped fix review, and verified audit provenance on disk. Completed the partially drafted handoff retirement under [ADR-0037](0037-execution-contract-replaces-handoff.md), preserving standing intent in [execution-contract.md](execution-contract.md). The user explicitly paused P01 onward and requested guide corrections on the lightweight hints branch. No new roadmap implementation was started.

- 2026-09-13 — **Execution transferred to a terminal session with the `superpowers` plugin installed.** That plugin was unavailable during the review, so Phase 1 ran as a plain controller workflow; P00 onward should use `superpowers:subagent-driven-development` as the original handoff intends. Per user decision, work continues in the **original checkout** rather than an isolated worktree: the temporary `uwumacs-impl` worktree was removed and its branch deleted, losing nothing because no commits were made in it. Preserved the review session's graphical-runner prototype and its three paid-for hazards in [gui-runner-notes.md](../uwumacs/gui-runner-notes.md) before scratch cleanup, and added a session-update section to the [execution contract](execution-contract.md). Branch `uwumacs` at `5c04812`, one commit ahead of `origin/uwumacs`, not pushed. Next: P00, with the graphical runner (F2) as its first deliverable.
- 2026-09-13 — **Phase 1 alignment review completed**; evidence in [alignment-review.md](alignment-review.md). Reviewed `1f70a93..3e2c86f` plus the uncommitted handoff files (retained unchanged). Re-ran the documentation gate, tangle check, tangle tests, focused hint tests and isolated startup — all PASS; `frames-tests.el` reported 5 SKIPPED in batch and the graphical hint tests did not execute. Probed the architecture's central mechanism against installed Meow 20260714.1200 and **verified** it: a symbol added to `emulation-mode-map-alists` with an explicit numeric ORDER lands ahead of Meow, shadows a genuinely active `meow-keypad` SPC, resolves `SPC f f` to `find-file`, restores `meow-keypad` on deactivation, leaves other buffers and Insert state untouched, and still yields to `overriding-terminal-local-map`. Nine findings recorded: F1 (High — Meow state fixtures can pass without proving shadowing; `(meow-normal-mode 1)` silently deactivates the state keymap), F2 (High — no reproducible graphical runner exists; graphical baseline unverified), F3/F4 (Medium — architecture corrections, applied to `docs/superpowers/specs/2026-09-13-uwumacs-design.md` sections 6 and 9), F5/F6/F7 (Low — vendor-boundary Corfu formatters, `SPC l` double writer, and the two unreachable `project-prefix-map` keys, all confirmed with runtime data), F8 (Medium — no Emacs 30.1 on this host), F9 (informational). No structural refactor of the plan was justified; task decomposition, ordering and interfaces held up under checking. No runtime source was edited and no isolated checkout was created, so the deployed configuration is unchanged. Every Emacs instance started for probing was stopped and all temporary roots removed; the real `var/elpa` (145 packages) and the working tree were verified unchanged. Affected ADRs: 0003, 0004 (ORDER requirement), 0021 (embark-consult), 0036 (review performed). Unresolved: F1 before P02 closes, F2 before P06 closes, F8 before P17 claims 30.1 support. Next: P00, carrying the graphical runner and the F6/F7 observed-key data as explicit deliverables.
- 2026-09-13 — Prepared [standing execution contract](execution-contract.md) and [ADR-0036](0036-review-first-development-handoff.md) at the user's request. Inspected branch/history and planning/ADR documentation. The user also authorized plan changes and significant structural or other refactors justified by that review; ADR-0036 and the handoff record this authority. No alignment verdict, runtime implementation, milestone completion or new runtime test result is claimed. Next: Phase 1 review, then P00.

Append dated updates with task/ticket IDs, code/review commits, checks and results, limitations, affected ADRs, unresolved findings and exact next action. Keep the checkpoint table current. Store the Phase 1 findings in docs/ADRs/alignment-review.md when that review is performed. Preserve this log across compaction and scratch cleanup.
