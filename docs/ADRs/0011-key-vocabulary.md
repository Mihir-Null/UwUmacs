# ADR-0011: Preserve useful keys and make collisions explicit

- Status: **selected**
- Origin: **agent-selected**
- Recorded: 2026-09-13 (backfilled from the cited evidence; not an invented original decision date)
- Implementation: **planned**
- Decision maker: user for explicitly stated product requirements; Codex for the agent-selected design details described below. Inherited choices retain unknown historical authorship.

## Context

The source has competing writers for SPC l, a single SPC i utility, and a project map with modified events. A literal hierarchy needs deliberate choices.

## Decision

Keep established useful sequences. Own the maps rather than mutating shared vendor maps.

| Prefix / key | Meaning |
|---|---|
| `SPC SPC` | M-x |
| `SPC f`, `b`, `s`, `p` | Files, buffers, search, projects |
| `SPC m` | Current mode's commands |
| `SPC c`, `e`, `i` | Change/wrap, evaluation, insertion |
| `SPC l`, `F` | Code intelligence, diagnostics |
| `SPC v` | Version control; preserve the existing v namespace |
| `SPC w`, `W` | Window/frame actions, workspaces |
| `SPC o`, `t`, `q`, `C` | Open applications, toggles, quit, configuration |
| `SPC h`, `H` | Dashboard, live keybinding help |
| `SPC /` | Describe UwUmacs bindings, replacing keypad-specific help |
| `SPC ?` | Command discovery; retain the existing apropos entry |
| `SPC s l` | Completion history, replacing the shadowed early `SPC l` binding |
| `SPC C i` | Configuration file lookup previously on single `SPC i` |
| `SPC i s` | Snippet insertion |
| `SPC f D` | Consult directory action |
| `SPC c p` | Explicit completion provider actions |

The project submenu must be explicitly defined, because the existing `project-prefix-map` can contain modified events that keypad previously handled. Capture the existing reachable commands before selecting literal aliases. Never flatten every Control/Meta binding algorithmically: collisions require individual choices and tests.

Publish a migration table for every changed sequence. Keep the modified recovery prefix. Do not add new keypad behavior while retiring the current hint adapter.

## Alternatives considered

Adopt Doom’s complete layout; silently change every mnemonic; mechanically strip modifiers. These either discard established habits or create hidden collisions.

## Consequences

The exact new aliases are agent-selected planning choices. P00 runtime evidence still governs collision resolution; changed keys require a migration table. No literal key migration is implemented by recording this ADR.

## Provenance and implementation references

[Architecture contract](../superpowers/specs/2026-09-13-uwumacs-design.md), section 7; [Implementation plan](../superpowers/plans/2026-09-13-uwumacs.md), P00/P05 and integration tickets for Vertico Repeat, project, snippets, Cape and Consult Dir.
