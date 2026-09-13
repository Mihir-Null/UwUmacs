# ADR-0029: Appearance and visual compatibility

- Status: **selected**
- Origin: **agent-selected**
- Recorded: 2026-09-13 (backfilled from the cited evidence; not an invented original decision date)
- Implementation: **planned**
- Decision maker: user for explicitly stated product requirements; Codex for the agent-selected design details described below. Inherited choices retain unknown historical authorship.

## Context

Existing visuals are preserved with portable fallbacks; visual libraries do not all need leader entries.

## Decision

Adopt the following individual contracts for this enabled-configuration wave. These are selected implementation decisions, not evidence that the packages have been reconfigured. The catalogue retains exact acceptance tests and file ownership.

| Ticket | Package / feature | Agent-selected integration decision |
|---|---|---|
| I153 | `doom-modeline` | Add :3 branding while retaining N/I/M state and useful status |
| I154 | `doom-themes` | Keep current theme package and tracked Sonokai port |
| I155 | `lambda-themes` | Keep the vendor theme lifecycle in the compatibility layer |
| I156 | `nerd-icons` | Keep optional font-based icons with text fallbacks |
| I157 | `nerd-icons-completion` | Retain candidate icons independently of key annotations |
| I158 | `spacious-padding` | Retain existing spacing policy |
| I159 | `svg-lib` | Preserve visual dependency and cache policy; no menu |
| I160 | `svg-tag-mode` | Keep availability-gated tags |
| I161 | `shrink-path` | Preserve modeline path formatting; no menu |
| I162 | `dimmer` | Preserve inactive-buffer dimming |
| I163 | `outline` | Keep folding commands available through localleader |
| I164 | `outline-minor-faces` | Keep outline presentation only |
| I165 | `highlight-numbers` | Keep its explicit mode/toggle behavior |
| I166 | `hl-todo` | Keep highlighting and expose navigation only when enabled |
| I167 | `goggles` | Preserve edit feedback overlays |
| I168 | `pulse` | Keep momentary navigation feedback |
| I169 | `rainbow-mode` | Retain explicit color preview toggle |
| I170 | `reveal` | Preserve visibility behavior around hidden text |
| I171 | `font-lock` | Keep syntax highlighting independent of modal state |
| I172 | `fontset` | Keep the existing font mapping policy |
| I173 | `fringe` | Keep existing fringe settings and indicators |

## Alternatives considered

Enable every installed related package; apply identical navigation keys to every context; add a menu command for every support library. These options were rejected in favor of the scoped contracts below.

## Consequences

Each ticket is independently reviewable. Existing native package actions remain available except where an explicit state-scoped contract replaces them. Missing executable/build capabilities are recorded as limitations rather than passing behavior. Revision of a contract must update its ADR, catalogue and inventory together, or supersede the decision.

## Provenance and implementation references

[Integration catalogue](../uwumacs/integrations.md), wave 2I; [Implementation plan](../superpowers/plans/2026-09-13-uwumacs.md), P15; architecture sections 4/9/10. Input evidence is the 2026-09-13 configured-package census, not the installed directory alone.
