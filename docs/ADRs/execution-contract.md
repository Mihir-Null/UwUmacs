# UwUmacs execution contract

This file supersedes `docs/uwumacs/HANDOFF.md`, which was consumed and removed on 2026-09-13 at the user's instruction to delete the handoff file or clear its content once read. [ADR-0037](0037-execution-contract-replaces-handoff.md) records that change. The handoff's dated session material is obsolete and was deliberately not carried forward; its standing content is carried forward here unchanged in meaning.

This is a standing contract, not a letter to a successor. It states what the user wants, what authority an agent working on UwUmacs holds, how execution is run, where durable state is recorded, and how work is verified. It holds until the user changes it.

It does not carry the current position. Read the [current-state log](implementation-state.md) for the active checkpoint, task, findings and next action, and the [alignment review](alignment-review.md) for the Phase 1 findings and execution gate. Live repository state and recorded evidence take precedence over any narrative, including this one.

## User intent and authority

- Keep Meow's editing grammar and states, while maintaining an extensible literal leader, local menus and per-package integrations under the name **UwUmacs**, with **`:3`** as its symbol.
- Both SPC menus and M-x completion should show the physical keys that actually work in the originating buffer/state. The user finds mentally translating Meow keypad hints confusing.
- Maintain real literal command maps; the existing physical-hint translation adapter is an implemented bridge while the new layer is developed.
- Preserve the preference for the external window manager to manage new editing windows through frames-only-mode, with intentional temporary-window exceptions.
- Prioritize enabled configurations, including deliberately lazy command/mode activation. Do not schedule disabled configurations, installed-only packages or inactive language opt-ins merely because they are present.
- Build the initial roadmap in order: core/discovery/branding, enabled integrations, then a reusable package. Every integration needs its own acceptance evidence.
- Review efficacy, maintainability and community practice; do not treat previous agent choices as infallible or as individually user-approved.
- Record the current state and material agent decisions durably in `docs/ADRs/` throughout execution.

Explicit user requirements outrank agent design choices. The [architecture](../superpowers/specs/2026-09-13-uwumacs-design.md) is the technical contract once reconciled with those requirements; the [plan](../superpowers/plans/2026-09-13-uwumacs.md) derives from it. The user explicitly authorizes the agent to revise the plan and to make significant structural or other refactors when review establishes a need. This includes changing architecture, module boundaries, interfaces, task decomposition or ordering, and replacing earlier agent-selected mechanisms. The existing plan and ADRs are reviewable baselines, not immutable implementation constraints. Preserve the user's goals and enabled-configuration scope; record the problem, rationale, alternatives, migration and rollback implications, and verification before dependent work proceeds. Update or supersede affected ADRs and reconcile the architecture, plan, [catalogue](../uwumacs/integrations.md), inventory and [validator](../uwumacs/validate-plan.py) together. The size of an otherwise authorized refactor alone is not a reason to request permission again. Resolve ordinary reversible implementation choices autonomously. Ask only when missing information or authorization is actually required.

## Current execution authority

On 2026-09-13 the user explicitly resumed UwUmacs development using subagent-driven development and relevant architecture-first practices, and requested that all commits be synced to remote GitHub. The user also explicitly selected the full P01-P17 roadmap, rather than stopping at the first usable milestone. This lifts the earlier P01 hold. Continue the ordered roadmap from P01 with independent task reviews, durable evidence and coherent commits on `uwumacs`; push reviewed development commits to `origin/uwumacs` and verify synchronization.

## Execution method

The user has selected `superpowers:subagent-driven-development`; do not ask them to choose an execution method again. Read the skill's current instructions rather than copying an old tool or model invocation.

- One controller is responsible for integration and for durable state. Shared documentation updates are serialized through the controller or one designated writer.
- One implementation writer at a time in the shared checkout. Many waves share `literate/43-uwumacs-integrations.org`, the manifest and the progress records. Independent read-only work may run alongside useful controller work; workers must not spawn duplicate reviewers or alter unrelated files.
- Before each implementation dispatch, record its base commit and produce a bounded brief: full relevant task text, exact global constraints, ticket IDs, agreed interfaces, owning ADRs, permitted files, acceptance checks, known findings and a report path. Use a fresh subagent with only the context it needs.
- The implementer writes meaningful failing behavior tests, implements the smallest coherent change, tangles authoritative source, runs the relevant checks, and reports commit range, tests and results, limitations and decision proposals.
- A fresh reviewer checks both specification compliance and code quality over the exact task diff. Fixes route back to an implementer and are reviewed in turn.
- **An unresolved required behavior is not verified merely because a review-loop limit was reached.** Record any adjudication and its consequences.

Roadmap order, per-task contracts and milestone gates live in the [plan](../superpowers/plans/2026-09-13-uwumacs.md); use its individual integration contracts rather than a blanket "wave loaded" result. Preserve traceability from original task and ticket IDs to any replacements; do not silently drop an enabled integration. Keep the default host policies: PowerShell normal, MSYS2 explicit, language servers opt-in, independent notes vault untouched, installed package files unmodified, and package acquisition outside portable core.

## Durable state and decision recording

Follow [ADR-0036](0036-review-first-development-handoff.md) and the [ADR policy](README.md). The user explicitly requested both current state and decisions in the ADR folder.

| Artifact | Responsibility |
|---|---|
| [`docs/ADRs/implementation-state.md`](implementation-state.md) | Tracked resumption record: checkout, branch and revision, active task and tickets, completed gates, current findings, next action, and dated execution updates. Update after every task, at milestones, and before handoff or compaction. |
| [`docs/ADRs/alignment-review.md`](alignment-review.md) | Tracked review evidence and the disposition of the Phase 1 findings. |
| Numbered ADRs and [`docs/ADRs/index.json`](index.json) | Material architectural, integration, compatibility, migration and release rulings with provenance, alternatives, consequences, and separate implementation state. New substantive reversals get successor records and supersession links. |
| [`docs/uwumacs/progress.json`](../uwumacs/progress.json) | One entry per catalogue ID with status, verified code commit, target version, tests and limitations. A `pending` entry is a placeholder, never a claim of implementation. |
| Plan checkboxes and [catalogue](../uwumacs/integrations.md) | Keep task completion, contracts and acceptance descriptions consistent with the evidence above. |
| Plan-specific SDD scratch ledger and reports | Operational dispatch and review detail. Never the only copy of a meaningful decision or of recovery state; preserve durable summaries before any authorized scratch cleanup. |

Log each material ruling as: **decision — reason/evidence — affected requirement/task — alternative — consequence if wrong — ADR reference**. This is concise reviewable rationale, not hidden deliberation. Distinguish user instructions, agent choices and inherited policy. Keep `selected` and `accepted` decision status separate from implementation progress; do not retire ADR-0018 merely because replacement is planned.

For each execution update record: date, task and ticket IDs, implementation and review commits, named checks and actual results, limitations, ADRs changed, unresolved findings, and the exact next action. A record may cite an already-created code commit; do not invent the hash of the documentation commit being written. After an interruption, reconcile recorded commits with current Git state before choosing the next task.

Keep `package-inventory.json`'s census evidence historical unless it is deliberately refreshed. Normal implementation changes will invalidate its optional source-hash check. Record legitimate drift rather than rewriting hashes to disguise it. Extend validators for progress and state consistency as those records become active, without weakening existing scope or contract checks.

## Verification and environment notes

- Documentation gate: `python docs/uwumacs/validate-plan.py --check-source-snapshot` and `git diff --check`. After intentional configuration edits, run the validator without the snapshot flag unless the census is being refreshed explicitly.
- Baseline tests: [focused hints](../../tests/key-hints-tests.el), [graphical hints](../../tests/key-hints-gui-tests.el), [frames](../../tests/frames-tests.el), [tangle](../../tests/tangle-tests.el), [isolated startup](../../tests/verify-config.el), and the shared [UwUmacs test helper](../../tests/uwumacs-test-helper.el). Read their runners before executing; the plan carries the shared commands.
- Previously used executables: `C:/Program Files/Emacs/emacs-31.1/bin/emacs.exe` and its sibling `runemacs.exe`. Verify availability first. Use the existing package directory through `EMACS_DOTS_TEST_PACKAGES` for isolated tests; worktrees do not automatically contain ignored `var/elpa` state.
- Batch initialization does not establish ordinary graphical startup. Run graphical tests after ordinary initialization in a dedicated instance through the committed [graphical runner](../../tools/run-gui-tests.ps1) and write an explicit result. **A skipped graphical test is not a pass.** The runner's hazards and their causes are recorded in [gui-runner-notes.md](../uwumacs/gui-runner-notes.md).
- Only exit the instance created for a given check. Preserve the user's Emacs processes and persisted state.
- Author runtime edits in Org and regenerate tracked Lisp through the existing tangle tooling. Keep flat outputs and manifest coverage, and check line endings if clean generation differs.
- Emacs 30.1, Windows 31.1 and Linux graphical and terminal gates remain distinct. Inability to run one is a documented limitation, not a pass.

## Publication boundary

Commit coherent reviewed changes on `uwumacs`, with source, generated outputs, tests and decision records kept in sync. The user's 2026-09-13 resumption request explicitly authorizes syncing all development commits to GitHub. Verify local and remote branch equality after publishing. This does not authorize merging main, deleting branches, tagging or publishing a package. Routine reversible development does not need repeated approval.
