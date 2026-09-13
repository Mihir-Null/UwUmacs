# ADR-0014: Build foundations before ordered enabled integrations and packaging

- Status: **selected**
- Origin: **user-milestones-with-agent-order**
- Recorded: 2026-09-13 (backfilled from the cited evidence; not an invented original decision date)
- Implementation: **planned**
- Decision maker: user for explicitly stated product requirements; Codex for the agent-selected design details described below. Inherited choices retain unknown historical authorship.

## Context

The user approved the three milestone direction and asked for an initial ordered multi-step map covering enabled packages.

## Decision

Execute P00–P17 serially by default: recover the current baseline; build maps/state/registry/discovery; migrate host keys; validate branding/frames; integrate completion, help, Dired, VC, navigation, Org, programming, terminals, appearance and runtime compatibility; then package a standalone core. Package dependencies are provisioned before consumers regardless of compatibility-review order. Each catalogue entry gets its own acceptance evidence even when files are shared.

| Task | Milestone/wave | Dependency | Deliverable |
|---|---|---|---|
| P00 | Baseline | None | Recoverable current hint baseline and validation fixtures |
| P01 | 1 / 1A | P00 | Native maps, customization and conflict validation |
| P02 | 1 / 1A | P01 | Reversible state-aware activation and localleader composition |
| P03 | 1 / 1A | P02 | Lazy registry, integration dependencies and cleanup |
| P04 | 1 / 1B | P03 | Actual-key menus, M-x annotations and live help |
| P05 | 1 | P04 | Explicit Lambda-to-UwUmacs key migration |
| P06 | 1 / 1B | P05 | :3 branding and graphical frame/menu acceptance |
| P07 | 2A | P06 | Completion and candidate action integrations |
| P08 | 2B | P07 | Help/Info integrations |
| P09 | 2C | P08 | Dired and enabled extensions |
| P10 | 2D | P09 | Magit/VC, diff/merge and temporary interfaces |
| P11 | 2E | P10 | Projects, search, buffers and workspaces |
| P12 | 2F | P11 | Current Org workflows |
| P13 | 2G | P12 | Structural editing and programming |
| P14 | 2H | P13 | Shells, terminals and process input |
| P15 | 2I | P14 | Presentation compatibility |
| P16 | 2J | P15 | Persistence and remaining built-in compatibility |
| P17 | 3 | P16 | Independently loadable core and release candidate |

## Alternatives considered

Build every adapter before core contracts settle; package the distribution before a working host proves behavior; treat whole-wave loading as proof that all member packages work.

## Consequences

The order is an agent-selected implementation dependency sequence, not a calendar estimate or a claim that work is complete. Library tickets get compatibility checks rather than artificial menus.

## Provenance and implementation references

[Implementation plan](../superpowers/plans/2026-09-13-uwumacs.md), P00–P17; [Integration catalogue](../uwumacs/integrations.md). Per-wave ADRs preserve every individual planned integration contract.

Acceptance execution owners are clarified in [ADR-0038](0038-foundational-acceptance-ownership.md) and the inventory; task references do not imply blanket ticket completion.
