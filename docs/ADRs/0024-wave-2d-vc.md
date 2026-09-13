# ADR-0024: Version-control and temporary-interface integrations

- Status: **selected**
- Origin: **agent-selected**
- Recorded: 2026-09-13 (backfilled from the cited evidence; not an invented original decision date)
- Implementation: **planned**
- Decision maker: user for explicitly stated product requirements; Codex for the agent-selected design details described below. Inherited choices retain unknown historical authorship.

## Context

Magit status is a section interface while commit messages are text editing. Transient and with-editor protocols must retain authority.

## Decision

Adopt the following individual contracts for this enabled-configuration wave. These are selected implementation decisions, not evidence that the packages have been reconfigured. The catalogue retains exact acceptance tests and file ownership.

| Ticket | Package / feature | Agent-selected integration decision |
|---|---|---|
| I058 | `transient` | Give temporary maps control while a transient is active; use existing Magit menus |
| I059 | `magit-section` | Navigate sections with section-aware commands |
| I060 | `with-editor` | Preserve commit message entry and finish/cancel protocol |
| I061 | `cond-let` | Preserve Magit dependency; no menu |
| I062 | `llama` | Preserve Magit dependency; no menu |
| I063 | `magit` | Keep SPC v entry points; use Motion in status/log and editing states in commit buffers |
| I064 | `git-commit` | Keep commit editing and checks separate from status navigation |
| I065 | `vc` | Keep native VC commands in the version-control menu |
| I066 | `vc-git` | Retain the selected Git backend |
| I067 | `vc-annotate` | Add localleader navigation for annotation buffers |
| I068 | `diff-mode` | Expose hunk navigation and application as explicit local actions |
| I069 | `smerge-mode` | Group choose-upper/lower/both actions under a merge localleader subgroup |
| I070 | `ediff` | Keep Ediff's control interface and frame policy explicit |
| I071 | `wgrep` | Reuse supported edit/finish/abort entry points and Meow shim |
| I072 | `flyspell` | Honor the current git-commit hook; gate missing spelling executables |

## Alternatives considered

Enable every installed related package; apply identical navigation keys to every context; add a menu command for every support library. These options were rejected in favor of the scoped contracts below.

## Consequences

Each ticket is independently reviewable. Existing native package actions remain available except where an explicit state-scoped contract replaces them. Missing executable/build capabilities are recorded as limitations rather than passing behavior. Revision of a contract must update its ADR, catalogue and inventory together, or supersede the decision.

## Provenance and implementation references

[Integration catalogue](../uwumacs/integrations.md), wave 2D; [Implementation plan](../superpowers/plans/2026-09-13-uwumacs.md), P10; architecture sections 4/9/10. Input evidence is the 2026-09-13 configured-package census, not the installed directory alone.
