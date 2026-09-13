# UwUmacs :3 — implementation handoff

Prepared 2026-09-13. Start here when continuing this project.

## Session update — 2026-09-13, Phase 1 complete

**Phase 1 is done. Do not repeat it.** The alignment review is committed as `5c04812` and recorded in
[docs/ADRs/alignment-review.md](../ADRs/alignment-review.md). Read that file and the
[current-state log](../ADRs/implementation-state.md) first; the rest of this handoff remains the standing
contract except where this section corrects it.

What changed since the original handoff was written:

| Item | Corrected state |
|---|---|
| Phase 1 review | **Complete.** Nine findings (F1–F9); execution gate recorded. No structural refactor of the plan was justified. |
| Central mechanism | **Verified**, not merely asserted. A symbol added to `emulation-mode-map-alists` with an explicit numeric ORDER shadows a genuinely active `meow-keypad` SPC and restores it cleanly on deactivation. |
| Architecture | Two corrections applied in `5c04812`: the explicit ORDER requirement (section 6) and the accurate `embark-consult` status (section 9). |
| Graphical baseline | **Unverified.** All 8 graphical tests skip in batch and no runner is committed. The earlier "three GUI tests passing" claim is not reproducible. See F2 and [gui-runner-notes.md](gui-runner-notes.md). |
| `superpowers` skill | **Was not installed** during the review session, so the review used a plain controller workflow. The user has since installed the plugin in the terminal. Use `superpowers:subagent-driven-development` as originally intended. |
| Isolated checkout | **User decision: work in the original checkout** (`C:/Users/walnu/.config/emacs-dots`, branch `uwumacs`). The temporary `uwumacs-impl` worktree created during the review has been removed and its branch deleted. This supersedes the worktree instruction in "Verified repository snapshot" below. Because this checkout also serves the live Emacs deployment, keep runtime edits tangled and coherent, and do not leave the tree in a half-regenerated state. |
| Branch position | `uwumacs` at `5c04812`, one commit **ahead of** `origin/uwumacs` (not pushed; pushing is still unauthorized). |

**Your next action is P00**, carrying these explicit deliverables:

1. The graphical runner (finding F2). [gui-runner-notes.md](gui-runner-notes.md) preserves a working
   `-Q` prototype, three hazards already paid for, and the one open problem: an `--init-directory` start does
   not reproduce `verify-config.el`'s module loading. Consider loading the config explicitly inside a
   graphical Emacs instead.
2. `tests/uwumacs-test-helper.el` and the temporary-directory fixtures from plan section 2.
3. The runtime observed-key capture. Three of its data points are already established and need only
   confirmation at runtime, not rediscovery: `SPC l`'s effective owner is the LSP submenu
   (`60-programming.org:470` overwrites `vertico-repeat` from `40-editing.org:97`); the only literally
   unreachable `project-prefix-map` keys are `C-x` (giving `C-x s`) and `C-b`; and both `kind-icon`
   (vendored `lem-setup-completion.el:555`) and `nerd-icons-corfu` (`starter-setup-ui.el:123`) register Corfu
   margin formatters.
4. Record `51c19c1` as the reviewed rollback point. It already exists — do not create a duplicate commit.

**Two gates carried forward.** P02 may not close until its fixtures include the F1 negative control: assert
`(key-binding (kbd "SPC"))` is `meow-keypad` *before* activating UwUmacs, enter state with
`(meow--switch-state 'normal)` plus `(should (meow-normal-mode-p))`, and assert restoration after
deactivation. Calling `(meow-normal-mode 1)` on an already-normal buffer silently deactivates Meow's state
keymap, which lets the central acceptance test pass while proving nothing. P06 may not close until the
graphical runner executes both suites with zero skips. P17 must resolve or document F8: this host has only
Emacs 31.1, so the 30.1 floor has no executable environment.

## Instructions to the next agent

First review **all plans, changes and relevant documents produced so far** for alignment with the user's intent and likely effectiveness. Verify the claims against code, actual behavior and primary upstream sources. Correct material gaps before dependent implementation. Then begin **subagent-driven development** of the existing P00–P17 roadmap, keeping current state and material decisions in [the ADR folder](../ADRs/README.md). The user has selected this execution method; do not ask them to choose it again.

This handoff prepares that work. It does not claim the review or UwUmacs implementation has started. On resumption, live repository state and recorded evidence take precedence over this dated snapshot.

## User intent and authority

- Keep Meow's editing grammar and states, while maintaining an extensible literal leader, local menus and per-package integrations under the name **UwUmacs**, with **`:3`** as its symbol.
- Both SPC menus and M-x completion should show the physical keys that actually work in the originating buffer/state. The user finds mentally translating Meow keypad hints confusing.
- Maintain real literal command maps; the existing physical-hint translation adapter is an implemented bridge while the new layer is developed.
- Preserve the preference for the external window manager to manage new editing windows through frames-only-mode, with intentional temporary-window exceptions.
- Prioritize enabled configurations, including deliberately lazy command/mode activation. Do not schedule disabled configurations, installed-only packages or inactive language opt-ins merely because they are present.
- Build the initial roadmap in order: core/discovery/branding, enabled integrations, then a reusable package. Every integration needs its own acceptance evidence.
- Review efficacy, maintainability and community practice; do not treat previous agent choices as infallible or as individually user-approved.
- Record the current state and material agent decisions durably in `docs/ADRs/` throughout execution.

Explicit user requirements outrank agent design choices. The architecture is the technical contract once reconciled with those requirements; the plan derives from it. The user explicitly authorizes the next agent to revise the plan and make significant structural or other refactors when the review establishes a need. This includes changing architecture, module boundaries, interfaces, task decomposition or ordering, and replacing earlier agent-selected mechanisms. The existing plan and ADRs are reviewable baselines, not immutable implementation constraints. Preserve the user's goals and enabled-configuration scope; record the problem, rationale, alternatives, migration/rollback implications and verification before dependent work proceeds. Update or supersede affected ADRs and reconcile the architecture, plan, catalogue, inventory and validators together. The size of an otherwise authorized refactor alone is not a reason to request permission again. Resolve ordinary reversible implementation choices autonomously. Ask only when missing information or authorization is actually required; do not stop after the review merely to ask whether to begin the already-requested development.

## Verified repository snapshot

| Item | Snapshot before this handoff |
|---|---|
| Local repository | `C:/Users/walnu/.config/emacs-dots` |
| Branch | `uwumacs`, clean and aligned with `origin/uwumacs` at `3e2c86f` |
| Remote | `https://github.com/Mihir-Null/Emacs-Dots.git`; previously verified private |
| Base | `1f70a93`: merged frames-only work; implementation commit `8d2102f` |
| Architecture/roadmap | `2d7d070` |
| Physical hints | `51c19c1`: SPC Which-key prefix and M-x Marginalia annotations |
| ADR backfill | `3e2c86f`: ADR-0001 through ADR-0035 |
| UwUmacs runtime | Not implemented; P00–P17 still pending |
| Integration census | 194 tickets, 160 configured names, 144 installed packages accounted for, 63 inventory-only exclusions |

The 194 tickets include built-ins, command surfaces and support libraries; they are not 194 external packages. Existing hint verification reported five focused tests and three graphical tests passing, plus isolated startup and tangle checks. Documentation/source-snapshot validation passed. Those are prior results, not fresh evidence for your implementation session.

Read [current implementation state](../ADRs/implementation-state.md) before acting. Check `git status`, branch, upstream, worktrees and history; preserve any newer or uncommitted work. Fetch remote refs before judging divergence. Do not reset to the snapshot, repeat the already-completed main refresh, or rebase/merge main reflexively. The hint rollback commit already exists; do not create a duplicate baseline commit.

This checkout also serves the user's Emacs deployment. Before runtime edits, use the available worktree skill to establish an isolated implementation checkout derived from the current `uwumacs` work, preserving the deployed checkout and all branch changes. Record its absolute path, branch and integration target. If an appropriate isolated checkout already exists, reuse it after verification. Do not change startup junctions as a shortcut for testing.

## Phase 1 — alignment and efficacy review

Read the documents fully; the following order is a dependency guide, not permission to review only selected sections.

1. [Repository guidance](../../AGENTS.md), this handoff, [ADR policy/index](../ADRs/README.md), [machine-readable decision index](../ADRs/index.json), every numbered ADR and the current state log.
2. [Architecture](../superpowers/specs/2026-09-13-uwumacs-design.md), [P00–P17 plan](../superpowers/plans/2026-09-13-uwumacs.md), [development map](README.md), [all integration tickets and exclusions](integrations.md), [inventory evidence](package-inventory.json), and [documentation validator](validate-plan.py).
3. Earlier plans in `docs/superpowers/plans/`, [reading order](../READING-ORDER.md), [deployment](../DEPLOYMENT.md), [upstream provenance](../UPSTREAM.md), [porting notes](../PORTING-NOTES.md), and [framework ownership](../../literate/framework.org). Treat dated deployment/package claims as historical until rechecked.
4. Every changed file in the commits above, including the merged frames implementation. Inspect the full `uwumacs` change range and any later commits/uncommitted diff. Follow dependencies into relevant configuration and installed package source; review tests as critically as implementation.
5. All authoritative [literate source chapters](../../literate/index.org), their generated modules and the [manifest](../../literate/manifest.json), especially [editing/hints](../../literate/40-editing.org), [frames](../../literate/45-frames.org), host composition, appearance/dashboard, programming and Org policy. Inspect all enabled integration declarations against the census.

Use read-only review subagents for bounded independent areas if useful. The controller must reconcile their findings into one review; do not start implementation while an unresolved prerequisite design defect remains.

| Review area | Required assessment |
|---|---|
| Intent and scope | Map each user requirement to a design section, implementation task, ADR and observable acceptance result. Check all 194 scheduled tickets and all exclusions. |
| Literal input and ownership | Validate native key lookup, Meow state precedence, buffer-local composition, user overrides, command remapping, prefix arguments, macros, selection/Beacon behavior and cleanup. Test the proposed mechanism rather than assuming that naming a native API proves it works. |
| Discovery | Check exact reachable keys in Normal, Motion and Insert; source-buffer context during M-x; temporary maps and remapped commands; unsupported/native fallback; absence of stale annotations. |
| Frames and temporary interfaces | Check attached completion/menu displays, popup exceptions, help return, last-frame protection, Magit/Transient, terminal character input and frame-action remapping from actual leader input. |
| Existing hint bridge | Review its private Meow/Which-key dependencies and tests, including collision handling. Retain it until the literal replacement passes its gates. |
| Registry and extensibility | Assess descriptor readiness, dependency semantics, lazy activation, repeated registration, disable while pending, cleanup and conflict handling. Look for unnecessary abstraction and host dependencies in core. |
| Package truth | Distinguish declared, installed, loaded and behaviorally tested. Recheck the `embark-consult` gap, competing Corfu icon formatters, effective `SPC l` owner and modified keys in the project map. |
| Plan efficacy | Check task/interface dependencies and shared file ownership. Identify test examples that merely prove Emacs itself works, underspecified task steps and acceptance cases that can pass without the requested behavior. Expand those briefs before dispatch. |
| Compatibility and provenance | Verify installed Emacs/Meow/package versions and upstream API assumptions. Emacs 30.1 is a planned minimum, not proof of completed cross-version testing. Preserve licenses and distinguish historical assertions from fresh evidence. |

Consult the primary upstream references in architecture section 11 and the installed source versions. Record dated links or revisions supporting consequential choices. Separate documented mechanisms from inferred community practice; no universal-consensus claim is required.

Create `docs/ADRs/alignment-review.md` containing:

- Reviewed revision range, dirty-file disposition, environment, source references and concrete checks run.
- Requirement coverage table: requirement, evidence, assessment, corrective action and owning task/ADR.
- One consistency row per P00–P17 task, plus rows for task pairs sharing a file/interface: producer, consumer, contract and finding.
- Findings with severity, affected files/tickets, user impact, disposition, owner and verification needed. Include acknowledged limitations and prior failures.
- A clear execution gate: which prerequisites are ready and which findings block dependent tasks. Record a clean assessment only after completing the tables.

Fix material design/documentation defects, record the rulings and rerun documentation checks. If a structural or other refactor is justified, record its scope and migration gates, revise the affected plan before dispatch, and implement the refactor through the same subagent and review workflow. Independent work may proceed once its own prerequisites are resolved; downstream work must not build on an unresolved structural defect. Continue directly into P00 after this gate.

## Phase 2 — subagent-driven implementation

Use the installed `superpowers:subagent-driven-development` skill and its implementer/reviewer templates. Read its current instructions rather than copying an old tool/model invocation. Keep one controller responsible for integration and durable state.

1. Resolve the plan-specific scratch ledger, reconcile it with Git and the tracked ADR state log, and create tasks for P00–P17. Resume existing work instead of redispatching completed tasks.
2. Start with P00 baseline verification and fixtures. Then execute P01–P06, followed by P07–P16 in catalogue wave order, then P17, unless the review has justified and documented a revised roadmap under the authority above. Preserve traceability from original task/ticket IDs to replacements; do not silently drop an enabled integration. Preserve dependency order when refining large waves into reviewable ticket-sized tasks.
3. Before each implementation dispatch, record its base commit and produce a bounded brief: full relevant task text, exact global constraints, ticket IDs, agreed interfaces, owning ADRs, permitted files, acceptance checks, known findings and a report path. Use a fresh subagent with only the context it needs.
4. Use one implementation writer at a time in a shared checkout. In particular, many waves share `literate/43-uwumacs-integrations.org`, the manifest and progress records. Independent read-only work may run alongside useful controller work. Workers must not spawn duplicate reviewers or alter unrelated files.
5. Have the implementer write meaningful failing behavior tests, implement the smallest coherent change, tangle authoritative source, run the relevant checks and return a report with commit range, tests/results, limitations and decision proposals.
6. Dispatch a fresh reviewer for both specification compliance and code quality over the exact task diff. Route fixes back to an implementer and review the fixes. Follow the skill's bounded review loop; record any adjudication and its consequences. Do not count an unresolved required behavior as verified because a review-loop limit was reached.
7. Reconcile reviewed work, update ADR implementation status/evidence, the current-state log, the per-ticket progress file and plan checkboxes, then continue. Serialize shared documentation updates through the controller or one designated writer.
8. At each milestone run its integration/startup/GUI gates. Finish with a whole-branch review and the P17 standalone/version gates. Report unexecuted environments and capability limitations explicitly.

Use the existing plan's individual integration contracts; do not replace them with a blanket “wave loaded” result. Shared library compatibility tickets need evidence, not invented menu entries. Keep the default host policies: PowerShell normal, MSYS2 explicit, language servers opt-in, independent notes vault untouched, installed package files unmodified and package acquisition outside portable core.

## Durable state and decision recording

Follow [ADR-0036](../ADRs/0036-review-first-development-handoff.md) and the existing ADR policy. The user explicitly requested both current state and decisions in the ADR folder.

| Artifact | Responsibility |
|---|---|
| `docs/ADRs/implementation-state.md` | Tracked resumption record: checkout/branch/revision, active task/tickets, completed gates, current findings, next action and dated execution updates. Update after review, every task, milestones and before handoff/compaction. |
| `docs/ADRs/alignment-review.md` | Tracked review evidence and disposition of Phase 1 findings; create during that review. |
| Numbered ADRs and `docs/ADRs/index.json` | Material architectural/integration/compatibility/migration rulings with provenance, alternatives, consequences and separate implementation state. New substantive reversals get successor records and supersession links. |
| `docs/uwumacs/progress.json` | Create when implementation starts using plan section 6. One entry per catalogue ID with status, verified code commit, target version, tests and limitations. |
| Plan checkboxes and catalogue | Keep task completion, contracts and acceptance descriptions consistent with the evidence above. |
| Plan-specific SDD scratch ledger/reports | Operational dispatch and review detail; never the only copy of meaningful decisions or recovery state. Preserve durable summaries before any authorized scratch cleanup. |

Log each material ruling as: **decision — reason/evidence — affected requirement/task — alternative — consequence if wrong — ADR reference**. This is concise reviewable rationale, not hidden deliberation. Distinguish user instructions, agent choices and inherited policy. Keep `selected`/`accepted` decision status separate from implementation progress; do not retire ADR-0018 merely because replacement is planned.

For each execution update record: date, task/ticket IDs, implementation and review commits, named checks and actual results, limitations, ADRs changed, unresolved findings and exact next action. A record may cite the already-created code commit; do not invent the hash of the documentation commit being written. After interruption, reconcile recorded commits with current Git state before choosing the next task.

Keep `package-inventory.json`'s census evidence historical unless deliberately refreshed. Normal implementation changes will invalidate its optional source hash check. Record legitimate drift rather than rewriting hashes to disguise it. Extend validators for progress/state consistency when those records become active, without weakening existing scope/contract checks.

## Verification and environment notes

- Initial documentation gate: `python docs/uwumacs/validate-plan.py --check-source-snapshot` and `git diff --check`. After intentional configuration edits, run the validator without the snapshot flag unless refreshing the census explicitly.
- Existing baseline tests: [focused hints](../../tests/key-hints-tests.el), [graphical hints](../../tests/key-hints-gui-tests.el), [frames](../../tests/frames-tests.el), [tangle](../../tests/tangle-tests.el), [isolated startup](../../tests/verify-config.el). Read their runners before executing; the plan contains the shared commands.
- Previously used executables: `C:/Program Files/Emacs/emacs-31.1/bin/emacs.exe` and its sibling `runemacs.exe`. Verify availability first. Use the existing package directory through `EMACS_DOTS_TEST_PACKAGES` for isolated tests; worktrees do not automatically contain ignored `var/elpa` state.
- Batch tests do not establish ordinary graphical startup. Run GUI tests after ordinary initialization in a dedicated instance and write an explicit result. A skipped graphical test is not a pass. Only exit the instance created for that check; preserve the user's Emacs processes and persisted state.
- P00 must provide repeatable fixtures/runners rather than depending on old machine-local audit scripts. Emacs 30.1, Windows 31.1 and Linux GUI/terminal gates remain distinct; inability to run one is a documented limitation.
- Author runtime edits in Org and regenerate tracked Lisp through the existing tangle tooling. Keep flat outputs and manifest coverage, and check line endings if clean generation differs.

Commit coherent reviewed changes on the development line, with source, generated outputs, tests and decision records kept in sync. Preserve existing publication authorization and verify its scope before remote actions; this handoff does not authorize merging main, deleting branches, tagging or publishing a package. Routine reversible development does not need repeated approval.

Your first substantive deliverable is the completed alignment review and an updated state log. Your next action is implementation, not another planning-only conclusion. Continue through the roadmap while work can proceed; when handing off, leave an exact resumable state and distinguish verified, pending and capability-limited work.
