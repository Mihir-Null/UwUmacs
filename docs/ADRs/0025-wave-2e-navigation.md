# ADR-0025: Projects, navigation and workspaces

- Status: **selected**
- Origin: **agent-selected**
- Recorded: 2026-09-13 (backfilled from the cited evidence; not an invented original decision date)
- Implementation: **planned**
- Decision maker: user for explicitly stated product requirements; Codex for the agent-selected design details described below. Inherited choices retain unknown historical authorship.

## Context

Existing projects, workspaces, search results and frame/window utilities need explicit scopes rather than a replacement workspace architecture.

## Decision

Adopt the following individual contracts for this enabled-configuration wave. These are selected implementation decisions, not evidence that the packages have been reconfigured. The catalogue retains exact acceptance tests and file ownership.

| Ticket | Package / feature | Agent-selected integration decision |
|---|---|---|
| I073 | `project` | Own a literal project submenu; bind commands directly rather than sharing project-prefix-map |
| I074 | `bookmark` | Retain bookmark creation/jump under the file menu |
| I075 | `recentf` | Keep recent-file access through Consult and dashboard |
| I076 | `ibuffer` | Expose buffer-list actions in a Motion adapter |
| I077 | `revert-buffer-all` | Keep explicit reload-all action with existing confirmation semantics |
| I078 | `tab-bar` | Keep W workspace menu and next/previous workspace shortcuts |
| I079 | `tabspaces` | Keep project/buffer filtering without replacing workspace architecture |
| I080 | `ace-window` | Keep explicit window selection and define scope when frames-only is enabled |
| I081 | `avy` | Retain candidate-label selection used by ace-window; no extra global movement grammar |
| I082 | `windmove` | Keep directional navigation scoped to available Emacs windows |
| I083 | `winner` | Keep layout undo within its supported window scope |
| I084 | `imenu-list` | Provide explicit outline display and frame-policy exception |
| I085 | `goto-last-change` | Retain change navigation in the search/navigation menu |
| I086 | `goto-addr` | Preserve address recognition; no forced global key |
| I087 | `xref` | Use existing definition/reference commands in the LSP menu with a back action |
| I088 | `deadgrep` | Expose a project search command and a Motion results adapter |
| I089 | `rg` | Keep its existing configurable search interface |
| I090 | `visual-regexp` | Retain visual query replacement |
| I091 | `visual-regexp-steroids` | Keep its alternate regexp engine as an explicit action |
| I092 | `isearch` | Allow the search map to own typing and search repetition |
| I093 | `replace` | Preserve y/n/!/q query-replace interaction |
| I094 | `register` | Keep Consult register access and native register semantics |

## Alternatives considered

Enable every installed related package; apply identical navigation keys to every context; add a menu command for every support library. These options were rejected in favor of the scoped contracts below.

## Consequences

Each ticket is independently reviewable. Existing native package actions remain available except where an explicit state-scoped contract replaces them. Missing executable/build capabilities are recorded as limitations rather than passing behavior. Revision of a contract must update its ADR, catalogue and inventory together, or supersede the decision.

## Provenance and implementation references

[Integration catalogue](../uwumacs/integrations.md), wave 2E; [Implementation plan](../superpowers/plans/2026-09-13-uwumacs.md), P11; architecture sections 4/9/10. Input evidence is the 2026-09-13 configured-package census, not the installed directory alone.
