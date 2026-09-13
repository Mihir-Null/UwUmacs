# ADR-0028: Shell and terminal integrations

- Status: **selected**
- Origin: **agent-selected**
- Recorded: 2026-09-13 (backfilled from the cited evidence; not an invented original decision date)
- Implementation: **planned**
- Decision maker: user for explicitly stated product requirements; Codex for the agent-selected design details described below. Inherited choices retain unknown historical authorship.

## Context

Prompt and character input must reach the subprocess. Windows PowerShell and explicit MSYS2 policy must survive modal integration.

## Decision

Adopt the following individual contracts for this enabled-configuration wave. These are selected implementation decisions, not evidence that the packages have been reconfigured. The catalogue retains exact acceptance tests and file ownership.

| Ticket | Package / feature | Agent-selected integration decision |
|---|---|---|
| I129 | `eat` | Keep PowerShell default and explicit MSYS2 entry; preserve Meow's EAT shims |
| I130 | `eshell` | Use Insert for the prompt and Motion/Normal only when explicitly requested |
| I131 | `esh-mode` | Preserve Eshell prompt editing boundaries |
| I132 | `em-alias` | Retain aliases in the user's existing storage policy |
| I133 | `em-banner` | Preserve the configured banner without rebranding subprocess output |
| I134 | `em-cmpl` | Preserve Eshell completion behavior |
| I135 | `em-dirs` | Keep directory navigation and stack commands |
| I136 | `em-glob` | Keep shell glob expansion |
| I137 | `em-hist` | Keep command history and search |
| I138 | `em-ls` | Keep listing output and link actions |
| I139 | `em-prompt` | Preserve prompt recognition and point motion |
| I140 | `em-term` | Retain visual-command handoff |
| I141 | `pcmpl-args` | Keep command argument completion |
| I142 | `pcmpl-homebrew` | Gate Homebrew-specific completion to hosts with brew |
| I143 | `pcomplete-extension` | Keep extension completion handlers |
| I144 | `esh-help` | Keep command-help access in Eshell |
| I145 | `eshell-up` | Expose directory-up explicitly |
| I146 | `eshell-syntax-highlighting` | Preserve prompt highlighting |
| I147 | `shell` | Keep native shell/comint interaction and PowerShell policy |
| I148 | `comint` | Respect process input, history and completion maps |
| I149 | `term` | Keep terminal character-mode maps authoritative |
| I150 | `exec-path-from-shell` | Preserve platform gating; keep native Windows environment policy |
| I151 | `tramp` | Preserve remote filename handling; do not start connections during activation |
| I152 | `server` | Keep existing server naming and explicit daemon lifecycle |

## Alternatives considered

Enable every installed related package; apply identical navigation keys to every context; add a menu command for every support library. These options were rejected in favor of the scoped contracts below.

## Consequences

Each ticket is independently reviewable. Existing native package actions remain available except where an explicit state-scoped contract replaces them. Missing executable/build capabilities are recorded as limitations rather than passing behavior. Revision of a contract must update its ADR, catalogue and inventory together, or supersede the decision.

## Provenance and implementation references

[Integration catalogue](../uwumacs/integrations.md), wave 2H; [Implementation plan](../superpowers/plans/2026-09-13-uwumacs.md), P14; architecture sections 4/9/10. Input evidence is the 2026-09-13 configured-package census, not the installed directory alone.
