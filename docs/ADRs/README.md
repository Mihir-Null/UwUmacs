# Architecture decision records

This folder is the dedicated decision log for UwUmacs and its relevant existing Emacs-Dots foundation. It backfills the agent-selected choices in the architecture/roadmap, all 194 individual integration contracts, the implemented frame/hint work, and the documented host boundaries already relied on by the design. It does not invent historical authorship or claim to reconstruct undocumented decisions in every vendored package.

Start or resume implementation through the [execution contract](execution-contract.md) and [current-state log](implementation-state.md). The Phase 1 findings and execution gate are recorded in the [alignment review](alignment-review.md). The user has authorized review-first subagent development, including plan changes and significant refactors justified by the review; [ADR-0036](0036-review-first-development-handoff.md) records the scope. Execution state stays in this folder alongside decision records.

## Authority and status

- **accepted**: an explicit user requirement, implemented choice, or documented inherited policy. Read Origin; this does not mean the user personally selected every technical detail.
- **selected**: a concrete agent-selected implementation/planning choice within the requested direction. It has not been claimed as individually user-approved or implemented.
- **superseded**: replaced by a linked successor. No current record is marked superseded merely because replacement is planned.
- Implementation is separate from decision status. The physical-hint adapter is committed as `51c19c1`; the UwUmacs literal leader remains planned.

Records preserve the reasoning and authority. The [architecture](../superpowers/specs/2026-09-13-uwumacs-design.md) remains the current technical contract; the [plan](../superpowers/plans/2026-09-13-uwumacs.md) remains execution guidance. The [catalogue](../uwumacs/integrations.md) and inventory retain acceptance/evidence data. Update linked representations together when a decision changes; use a successor ADR for a substantive reversal.

## Recording policy

1. Give a material architectural, integration, keybinding, scope, compatibility, migration or release decision the next stable four-digit ID. Record it in the same change as the decision.
2. State who requested the outcome and who selected the details. Cite a document, code revision or explicit user request. If historical attribution is unknown, say so.
3. Record context, selected option, alternatives, benefits/costs and implementation references. Preserve concise decision rationale, not hidden deliberation.
4. Routine edits and commands need no separate ADR. A changed integration contract belongs in its wave ADR and linked catalogue record.
5. Update index.json and cross-links. Do not renumber history. A reversal gets a new record and explicit supersession links.
6. Keep disabled/install-only entries unscheduled; recording them does not authorize activation.

The structure follows the [Nygard ADR format](https://adr.github.io/adr-templates/), adding explicit agent/user provenance and separate implementation status.

## Decision index

| ADR | Decision | Status | Origin | Implementation |
|---|---|---|---|---|
| [ADR-0001](0001-record-decisions-and-provenance.md) | Record material decisions with explicit provenance | accepted | user-request-with-agent-format | documentation implemented |
| [ADR-0002](0002-meow-interaction-layer.md) | Keep Meow as the editing engine and build an interaction layer | selected | user-direction-with-agent-design | planned |
| [ADR-0003](0003-native-literal-dispatch.md) | Use native literal prefix lookup | selected | agent-selected | P01-P02 native maps and activation implemented; host migration pending |
| [ADR-0004](0004-owned-state-layer.md) | Own a reversible state-aware emulation layer | selected | agent-selected | P02 owned activation and buffer lifecycle implemented |
| [ADR-0005](0005-composition-and-conflicts.md) | Compose localleaders and reject ambiguous defaults | selected | agent-selected | P01-P02 transactional maps and localleaders implemented; registry lifecycle pending |
| [ADR-0006](0006-integration-registry.md) | Use a small lazy integration registry | selected | agent-selected | planned |
| [ADR-0007](0007-discovery-from-effective-maps.md) | Derive discovery from effective executable maps | selected | agent-selected | planned |
| [ADR-0008](0008-compatibility-floor.md) | Select a core runtime floor and explicit test targets | selected | agent-selected | planned |
| [ADR-0009](0009-literate-files-and-modules.md) | Keep flat generated outputs and focused modules | selected | agent-selected | P01-P02 literate core and four flat outputs implemented; remaining modules pending |
| [ADR-0010](0010-host-boundary.md) | Preserve host policy behind a temporary Lambda bridge | selected | agent-selected-with-inherited-constraints | planned |
| [ADR-0011](0011-key-vocabulary.md) | Preserve useful keys and make collisions explicit | selected | agent-selected | planned |
| [ADR-0012](0012-branding.md) | Use the user-selected :3 identity with optional presentation | selected | user-brand-with-agent-presentation | planned |
| [ADR-0013](0013-enabled-scope-and-inventory.md) | Prioritize enabled configurations and distinguish evidence | selected | user-scope-with-agent-classification | planned |
| [ADR-0014](0014-milestones-and-order.md) | Build foundations before ordered enabled integrations and packaging | selected | user-milestones-with-agent-order | planned |
| [ADR-0015](0015-verification-and-recovery.md) | Use behavior-based gates and recoverable migration checkpoints | selected | agent-selected | planned |
| [ADR-0016](0016-standalone-release.md) | Extract a minimal reusable artifact after integration validation | selected | agent-selected | planned |
| [ADR-0017](0017-frames-only-integration.md) | Use frames-only-mode with scoped display exceptions | accepted | user-request-with-agent-implementation | implemented; retained host policy |
| [ADR-0018](0018-physical-hint-adapter.md) | Bridge the current keypad with physical-key hints | accepted | user-request-with-agent-implementation | implemented; planned replacement |
| [ADR-0019](0019-wave-1a-core.md) | Foundational library contracts | selected | agent-selected | P01 files-map foundation implemented; individual Wave 1A acceptance pending |
| [ADR-0020](0020-wave-1b-discovery.md) | Home, menus and display policy | selected | agent-selected | planned |
| [ADR-0021](0021-wave-2a-completion.md) | Completion and candidate-action integrations | selected | agent-selected | planned |
| [ADR-0022](0022-wave-2b-help.md) | Help and documentation integrations | selected | agent-selected | planned |
| [ADR-0023](0023-wave-2c-dired.md) | Dired and extension integrations | selected | agent-selected | planned |
| [ADR-0024](0024-wave-2d-vc.md) | Version-control and temporary-interface integrations | selected | agent-selected | planned |
| [ADR-0025](0025-wave-2e-navigation.md) | Projects, navigation and workspaces | selected | agent-selected | planned |
| [ADR-0026](0026-wave-2f-org.md) | Enabled Org workflows | selected | agent-selected | planned |
| [ADR-0027](0027-wave-2g-programming.md) | Structural editing and programming integrations | selected | agent-selected | planned |
| [ADR-0028](0028-wave-2h-terminal.md) | Shell and terminal integrations | selected | agent-selected | planned |
| [ADR-0029](0029-wave-2i-appearance.md) | Appearance and visual compatibility | selected | agent-selected | planned |
| [ADR-0030](0030-wave-2j-runtime.md) | Remaining runtime compatibility | selected | agent-selected | planned |
| [ADR-0031](0031-inherited-deployment.md) | Retain documented deployment and state ownership | accepted | inherited-documented-policy | existing policy; historical details require live verification |
| [ADR-0032](0032-inherited-theme-and-fonts.md) | Retain the documented theme, font and dashboard architecture | accepted | inherited-documented-policy | existing policy; branding and formatter reconciliation planned |
| [ADR-0033](0033-inherited-windows-terminal.md) | Retain child-scoped Windows terminal adaptation | accepted | inherited-documented-policy | existing host policy |
| [ADR-0034](0034-inherited-language-tooling.md) | Retain pinned grammar recipes and explicit language tooling | accepted | inherited-documented-policy | existing host policy |
| [ADR-0035](0035-inherited-org-policy.md) | Retain the minimal Org storage boundary | accepted | inherited-documented-policy | existing host policy |
| [ADR-0036](0036-review-first-development-handoff.md) | Review alignment before subagent development and retain execution state | accepted | user-workflow-with-agent-record-layout | Phase 1 and P00 complete; P01 resumed under the current execution contract |
| [ADR-0037](0037-execution-contract-replaces-handoff.md) | Retire the consumed handoff; preserve the standing execution contract | accepted | user-request-with-agent-record-layout | handoff migration complete; execution resumed by the user on 2026-09-13 |
| [ADR-0038](0038-foundational-acceptance-ownership.md) | Assign foundational acceptance to its actual prerequisites | selected | agent-selected-under-user-review-authority | acceptance ownership documented; runtime evidence remains per ticket |

## Coverage

[index.json](index.json) maps every architecture section and fixed constraint to ADRs, maps implementation tasks to their decisions, and associates all 194 integration tickets with exactly one wave ADR. Run `python docs/uwumacs/validate-plan.py --check-source-snapshot` from the repository root to check links and coverage.
