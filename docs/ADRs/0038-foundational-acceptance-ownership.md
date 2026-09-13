# ADR-0038: Assign foundational acceptance to its actual prerequisites

- Status: **selected**
- Origin: **agent-selected-under-user-review-authority**
- Recorded: 2026-09-13
- Implementation: **acceptance ownership documented; runtime evidence remains per ticket**
- Decision maker: Codex under the user's explicit full-roadmap and plan-revision authority; this mapping was not individually selected by the user.

## Context

ADR-0019 referenced only P01 although its acceptance contracts require state activation, the Lambda bridge, help/file adapters and the minimum runtime. The explicit per-ticket loop began at P07, leaving foundation checks without precise owners. Literal completion by catalogue number would prematurely force later adapters into P01 or leave their checks implicit.

## Decision

Retain P01-P17 implementation order, all catalogue IDs and all acceptance contracts. Each inventory row names an acceptance task; the plan carries the foundational mapping.

Task completion does not imply ticket acceptance. All P01-P17 tickets require named tests, tested versions, actual code revisions and limitations. Catalogue numbering retains review order; acceptance executes after actual prerequisites at each inventory record's `acceptance_task`. I010's first adapter is `uwumacs-integration-core.el`; I011 remains package dependency compatibility, not a synthetic integration dependency. I020 final acceptance is P06 after P05 retires keypad advice; P04 menu evidence is preliminary. I009 tests exact Emacs 30.1 initially at P03 and revalidates final core/artifact at P17. Runtime unavailability needs concrete evidence, never a verified placeholder. Re-run covering checks when later changes affect prior evidence.

## Alternatives considered

Force every foundation check into P01, prematurely building dependent adapters; retain implicit ownership and risk missed checks; postpone all minimum-runtime testing to P17 and discover incompatibilities after integration work. Explicit ownership and early/final floor checks preserve task boundaries and improve feedback.

## Consequences

A wrong prerequisite mapping costs documented rescheduling and revalidation, not silently dropped behavior. Historical census hashes remain historical. The existing milestone exit evidence requirements remain intact. Verified records name actual code revisions, tested versions and tests; scheduling alone is not a capability limitation.

## Provenance and implementation references

The user resumed development on 2026-09-13, explicitly selected P01-P17 and required GitHub sync. Independent architecture review approved this mapping after correcting I020 to P06, and confirmed I009 at P03 plus P17 revalidation strengthens the contract. See the [execution contract](execution-contract.md), [plan](../superpowers/plans/2026-09-13-uwumacs.md), [catalogue](../uwumacs/integrations.md) and [inventory](../uwumacs/package-inventory.json). This clarifies scheduling in [ADR-0014](0014-milestones-and-order.md) and coverage in [ADR-0019](0019-wave-1a-core.md) / [ADR-0020](0020-wave-1b-discovery.md), retaining their milestone and integration decisions.
