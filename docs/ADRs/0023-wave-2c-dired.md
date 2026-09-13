# ADR-0023: Dired and extension integrations

- Status: **selected**
- Origin: **agent-selected**
- Recorded: 2026-09-13 (backfilled from the cited evidence; not an invented original decision date)
- Implementation: **planned**
- Decision maker: user for explicitly stated product requirements; Codex for the agent-selected design details described below. Inherited choices retain unknown historical authorship.

## Context

File operations and Wdired have different editing states; existing Meow shims should be reused before adding overrides.

## Decision

Adopt the following individual contracts for this enabled-configuration wave. These are selected implementation decisions, not evidence that the packages have been reconfigured. The catalogue retains exact acceptance tests and file ownership.

| Ticket | Package / feature | Agent-selected integration decision |
|---|---|---|
| I049 | `dired` | SPC d opens Dired; Motion navigation and SPC m provide file operations |
| I050 | `wdired` | Use package-supported entry/finish/abort commands and Meow's existing shim |
| I051 | `dired-narrow` | Expose narrowing under the Dired localleader |
| I052 | `dired-ranger` | Expose copy/paste operations under Dired localleader |
| I053 | `dired-hacks-utils` | Keep shared Dired dependency; no menu |
| I054 | `diredfl` | Preserve faces without changing navigation |
| I055 | `peep-dired` | Make preview explicit and frame-aware |
| I056 | `dired-sidebar` | Keep sidebar invocation explicit; define its exception to frames-only placement |
| I057 | `nerd-icons-dired` | Keep optional icon presentation |

## Alternatives considered

Enable every installed related package; apply identical navigation keys to every context; add a menu command for every support library. These options were rejected in favor of the scoped contracts below.

## Consequences

Each ticket is independently reviewable. Existing native package actions remain available except where an explicit state-scoped contract replaces them. Missing executable/build capabilities are recorded as limitations rather than passing behavior. Revision of a contract must update its ADR, catalogue and inventory together, or supersede the decision.

## Provenance and implementation references

[Integration catalogue](../uwumacs/integrations.md), wave 2C; [Implementation plan](../superpowers/plans/2026-09-13-uwumacs.md), P09; architecture sections 4/9/10. Input evidence is the 2026-09-13 configured-package census, not the installed directory alone.
