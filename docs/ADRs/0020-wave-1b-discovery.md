# ADR-0020: Home, menus and display policy

- Status: **selected**
- Origin: **agent-selected**
- Recorded: 2026-09-13 (backfilled from the cited evidence; not an invented original decision date)
- Implementation: **planned**
- Decision maker: user for explicitly stated product requirements; Codex for the agent-selected design details described below. Inherited choices retain unknown historical authorship.

## Context

The first usable release must show accurate input and preserve the user’s frame preference before broad package expansion.

## Decision

Adopt the following individual contracts for this enabled-configuration wave. These are selected implementation decisions, not evidence that the packages have been reconfigured. The catalogue retains exact acceptance tests and file ownership.

| Ticket | Package / feature | Agent-selected integration decision |
|---|---|---|
| I020 | `which-key` | Show actual prefix maps with readable group names; no keypad popup advice |
| I021 | `dashboard` | SPC h opens home; SPC H opens live binding help; show :3 UwUmacs |
| I022 | `frames-only-mode` | Keep OS-managed editing frames and attached completion |
| I023 | `frame` | Keep frame creation, focus and deletion explicit in the w menu |
| I024 | `window` | Use display-buffer and native remapping for display policy |
| I025 | `popper` | Keep popup selection/history while frame policy owns placement |

## Alternatives considered

Enable every installed related package; apply identical navigation keys to every context; add a menu command for every support library. These options were rejected in favor of the scoped contracts below.

## Consequences

Each ticket is independently reviewable. Existing native package actions remain available except where an explicit state-scoped contract replaces them. Missing executable/build capabilities are recorded as limitations rather than passing behavior. Revision of a contract must update its ADR, catalogue and inventory together, or supersede the decision.

## Provenance and implementation references

[Integration catalogue](../uwumacs/integrations.md), wave 1B; [Implementation plan](../superpowers/plans/2026-09-13-uwumacs.md), P06; architecture sections 4/9/10. Input evidence is the 2026-09-13 configured-package census, not the installed directory alone.

Acceptance execution owners are clarified in [ADR-0038](0038-foundational-acceptance-ownership.md) and the inventory; task references do not imply blanket ticket completion.
