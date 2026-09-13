# ADR-0037: Replace the consumed handoff with a standing execution contract

- Status: **accepted**
- Origin: **user-request-with-agent-record-layout**
- Recorded: 2026-09-13
- Implementation: **migration complete; handoff removed and every reference re-pointed**
- Decision maker: user instructed the deletion of the consumed handoff; Codex selected the destination record and the migration boundary.

## Context

[ADR-0036](0036-review-first-development-handoff.md) made `docs/uwumacs/HANDOFF.md` the entry point for this project: read the handoff, run an evidence-based alignment review, then execute the P00–P17 roadmap. That instruction has now been carried out. Phase 1 is complete and its evidence is in the [alignment review](alignment-review.md); Phase 2 has begun and P00 is finished. The user then instructed that the handoff file be deleted or its content cleared once read.

The handoff was not only a dated dispatch. It also carried material that stays true after it is read: the user's statement of intent and authority, the selected execution method, the durable-state responsibilities table with its decision-logging format, the verification and environment rules, and the publication boundary. Deleting the file outright would discard the user's own statement of what they want and what an agent is authorized to do.

Two structural problems also had to be settled. The handoff mixed a standing contract with a dated snapshot, so a reader could not tell which parts were still binding. And `docs/uwumacs/validate-plan.py` listed `HANDOFF.md` among the files whose markdown links it checks, so removing the file without editing that list would have crashed the documentation gate.

## Decision

Retire `docs/uwumacs/HANDOFF.md` and replace it with [execution-contract.md](execution-contract.md) as the standing entry point, alongside the [current-state log](implementation-state.md) for the current position.

The contract carries forward, reworded in the present tense, exactly the handoff's durable material: user intent and authority, the authority paragraph on revising the plan and performing significant refactors, the execution method, the durable-state responsibilities table and ruling-log format, the verification and environment notes, and the publication boundary. It deliberately drops the handoff's dated material: the Phase 1 review instructions, the Phase 1 completion table, the "your next action is P00" list, the verified repository snapshot, and the worktree instruction the user overrode in favour of working in the original checkout. Where a newer record already owns a subject, the contract links to that record instead of repeating it.

This reverses only ADR-0036's entry-point clause. ADR-0036's review-first workflow, its record layout and its authorization scope remain in force, so it keeps Status `accepted` and is not marked superseded. `docs/uwumacs/validate-plan.py` now link-checks `docs/ADRs/execution-contract.md` in place of the removed handoff, so the successor carries the same gate the retired file did. Every tracked reference to the handoff is re-pointed; the historical execution-log entries in `implementation-state.md` keep describing what actually happened on their dates and note that the handoff is retired rather than pretending it never existed.

## Alternatives considered

Leave a stub `HANDOFF.md` redirecting to the successor. Rejected: the user asked for the file to be gone, and a file that exists only to satisfy a validator's file list is cruft that a future reader must still evaluate and discard.

Fold the standing contract into `implementation-state.md`. Rejected: that file is the dated resumption record, rewritten at every checkpoint. Mixing a standing contract into a rolling log muddies both roles and invites the contract to be edited as if it were state.

Fold the standing contract into ADR-0036. Rejected: ADRs are decision records with fixed provenance, and the contract carries operational detail — verification commands, executables, environment conventions — that changes for reasons unrelated to any decision. Editing ADR-0036's body to absorb it would also rewrite a record rather than supersede a clause, against [recording policy](README.md) item 5.

Delete the handoff without migrating it. Rejected: it would discard the user's own statement of intent and authority, which no other tracked record carries in full.

## Consequences

Resumption now has two documents with distinct roles: a standing contract that changes only when the user's requirements change, and a dated state log that changes constantly. A reader can tell which is which. The contract is inside `docs/ADRs/`, matching the user's request that durable state and decisions live there.

`docs/uwumacs/HANDOFF.md` no longer exists, so any external note or conversation citing that path is stale; the path is named in this record and in the contract's opening paragraph so the trail is followable. Two historical entries in `implementation-state.md` still describe preparing and using the handoff, which remains accurate, and now link to the contract instead of a missing file.

The documentation gate covers the successor: the contract's links are checked, and it is held to the same no-placeholder rule. Nothing about the roadmap, the architecture, the integration scope or any acceptance evidence changes as a result of this record.

## Provenance and implementation references

User instruction of 2026-09-13, given after reading the handoff into execution: delete the handoff file or clear its content once read. The migration and deletion were performed as task P00D in the same change that records this ADR. See [execution-contract.md](execution-contract.md), [ADR-0036](0036-review-first-development-handoff.md), the [current-state log](implementation-state.md), the [alignment review](alignment-review.md) and [ADR-0001](0001-record-decisions-and-provenance.md) for the provenance policy this record follows. The successor-record requirement is [recording policy](README.md) item 5; the [ADR templates](https://adr.github.io/adr-templates/) inform the structure.
