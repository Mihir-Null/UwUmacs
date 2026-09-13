# ADR-0036: Review alignment before subagent development and retain execution state

- Status: **accepted**
- Origin: **user-workflow-with-agent-record-layout**
- Recorded: 2026-09-13
- Implementation: **handoff and initial state log prepared; review and roadmap execution pending**
- Decision maker: user selected review-first subagent development and ADR logging; Codex selected the linked record layout and operational detail.

## Context

The user requested a handoff directing the next agent to review all plans, changes and relevant documents for alignment with intent and efficacy, then begin subagent-driven implementation while logging current state and decisions in the ADRs. Existing numbered ADRs preserve rationale, but do not yet provide an execution recovery log.

## Decision

Use the [implementation handoff](../uwumacs/HANDOFF.md) as the entry point. Require an evidence-based alignment review before dependent implementation, then execute the existing P00–P17 roadmap using bounded implementer tasks and independent review. Keep a tracked current-state log in docs/ADRs/implementation-state.md and create docs/ADRs/alignment-review.md during the review. Preserve numbered ADRs for material decisions; synchronize their implementation evidence with the existing per-ticket progress format and plan checkboxes. Scratch subagent ledgers supplement these tracked records.

The controller serializes shared-file work and documentation reconciliation. Review findings may correct agent-selected choices with recorded evidence; the review is not a reason to ask again for the already-requested implementation. The user subsequently explicitly authorized changes to the plan and significant structural or other refactors when the review finds them necessary. Earlier agent-selected architecture and task order may therefore be revised; preserve user goals, enabled scope and original-to-revised task coverage. Record the justification, alternatives, migration/rollback implications and verification, supersede affected decisions where needed, and synchronize the plan before dependent implementation. Refactor size alone does not require renewed approval. Preserve milestone acceptance outcomes and report capability limitations honestly.

## Alternatives considered

Rely only on conversation or an ignored scratch ledger, which weakens recovery and cross-checkout handoff. Mix every operational update into numbered ADRs, which obscures lasting decisions. Begin implementation without reviewing the inherited assumptions, which risks propagating plan defects. These alternatives do not meet the requested workflow as clearly.

## Consequences

Current state and decisions remain together under the user-selected ADR folder, with separate roles and links. Several representations need deliberate synchronization. This handoff does not establish that the review passed, activate UwUmacs, or expand package scope. Existing ADRs remain in force unless explicitly superseded.

## Provenance and implementation references

User request of 2026-09-13: prepare a handoff asking the next agent first to review alignment and efficacy, then begin subagent-driven roadmap development and log current state and decisions in the ADRs; followed by explicit authorization to revise the plan and perform significant structural or other refactors when review establishes a need. See [handoff](../uwumacs/HANDOFF.md), [initial state](implementation-state.md), [roadmap](../superpowers/plans/2026-09-13-uwumacs.md) and [ADR-0001](0001-record-decisions-and-provenance.md). The separation of decision rationale from execution evidence extends the existing local policy; [ADR templates](https://adr.github.io/adr-templates/) inform the record structure, not a claim of consensus on this workflow.
