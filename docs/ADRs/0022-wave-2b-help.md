# ADR-0022: Help and documentation integrations

- Status: **selected**
- Origin: **agent-selected**
- Recorded: 2026-09-13 (backfilled from the cited evidence; not an invented original decision date)
- Implementation: **planned**
- Decision maker: user for explicitly stated product requirements; Codex for the agent-selected design details described below. Inherited choices retain unknown historical authorship.

## Context

Help links, Info navigation and returning to the source buffer are central to learning the new binding system.

## Decision

Adopt the following individual contracts for this enabled-configuration wave. These are selected implementation decisions, not evidence that the packages have been reconfigured. The catalogue retains exact acceptance tests and file ownership.

| Ticket | Package / feature | Agent-selected integration decision |
|---|---|---|
| I042 | `help` | Keep C-h and add live UwUmacs command/keymap inspection |
| I043 | `help-at-pt` | Preserve help-at-point feedback |
| I044 | `helpful` | Provide contextual help with consistent Motion navigation and q |
| I045 | `elisp-demos` | Retain examples inside Helpful |
| I046 | `elisp-refs` | Support Helpful reference navigation; no duplicate global menu |
| I047 | `info` | Keep Info navigation plus Motion j/k and a mode-specific localleader |
| I048 | `info-colors` | Keep Info fontification; no new keys |

## Alternatives considered

Enable every installed related package; apply identical navigation keys to every context; add a menu command for every support library. These options were rejected in favor of the scoped contracts below.

## Consequences

Each ticket is independently reviewable. Existing native package actions remain available except where an explicit state-scoped contract replaces them. Missing executable/build capabilities are recorded as limitations rather than passing behavior. Revision of a contract must update its ADR, catalogue and inventory together, or supersede the decision.

## Provenance and implementation references

[Integration catalogue](../uwumacs/integrations.md), wave 2B; [Implementation plan](../superpowers/plans/2026-09-13-uwumacs.md), P08; architecture sections 4/9/10. Input evidence is the 2026-09-13 configured-package census, not the installed directory alone.
