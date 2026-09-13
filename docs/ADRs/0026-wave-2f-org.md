# ADR-0026: Enabled Org workflows

- Status: **selected**
- Origin: **agent-selected**
- Recorded: 2026-09-13 (backfilled from the cited evidence; not an invented original decision date)
- Implementation: **planned**
- Decision maker: user for explicitly stated product requirements; Codex for the agent-selected design details described below. Inherited choices retain unknown historical authorship.

## Context

The current minimal Org store and templates should work without enabling the unrelated installed notes and publishing ecosystem.

## Decision

Adopt the following individual contracts for this enabled-configuration wave. These are selected implementation decisions, not evidence that the packages have been reconfigured. The catalogue retains exact acceptance tests and file ownership.

| Ticket | Package / feature | Agent-selected integration decision |
|---|---|---|
| I095 | `org` | Own a mode-specific localleader while retaining Meow editing |
| I096 | `org-agenda` | Use Motion with agenda-specific navigation and actions |
| I097 | `org-capture` | Keep task/note templates; give capture finish/cancel priority |
| I098 | `org-id` | Preserve ID creation and links |
| I099 | `org-refile` | Expose refile under Org localleader |
| I100 | `org-inlinetask` | Keep inline task insertion explicit |
| I101 | `org-contrib` | Audit only contributed features actually enabled by the Org module |
| I102 | `ox` | Use Org's export dispatch rather than a replacement export UI |

## Alternatives considered

Enable every installed related package; apply identical navigation keys to every context; add a menu command for every support library. These options were rejected in favor of the scoped contracts below.

## Consequences

Each ticket is independently reviewable. Existing native package actions remain available except where an explicit state-scoped contract replaces them. Missing executable/build capabilities are recorded as limitations rather than passing behavior. Revision of a contract must update its ADR, catalogue and inventory together, or supersede the decision.

## Provenance and implementation references

[Integration catalogue](../uwumacs/integrations.md), wave 2F; [Implementation plan](../superpowers/plans/2026-09-13-uwumacs.md), P12; architecture sections 4/9/10. Input evidence is the 2026-09-13 configured-package census, not the installed directory alone.
