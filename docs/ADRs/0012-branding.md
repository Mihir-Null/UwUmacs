# ADR-0012: Use the user-selected :3 identity with optional presentation

- Status: **selected**
- Origin: **user-brand-with-agent-presentation**
- Recorded: 2026-09-13 (backfilled from the cited evidence; not an invented original decision date)
- Implementation: **planned**
- Decision maker: user for explicitly stated product requirements; Codex for the agent-selected design details described below. Inherited choices retain unknown historical authorship.

## Context

The user named the project UwUmacs and selected :3 as the logo/symbol.

## Decision

Display plain-text :3 UwUmacs on the dashboard and optionally :3 in the modeline. Preserve a clearly visible Meow state indicator. Keep the symbol usable without Nerd Fonts, SVG or a graphical backend. Retain the existing dashboard centering and live-help entry.

## Alternatives considered

Require an image asset or icon font; replace N/I/M status with a decorative symbol. Both reduce portability or useful state information.

## Consequences

The name/symbol are user-selected; ASCII rendering, optional modeline treatment and fallback behavior are agent design details. Branding is still planned.

## Provenance and implementation references

User naming request; [Architecture contract](../superpowers/specs/2026-09-13-uwumacs-design.md), sections 1/8; [Implementation plan](../superpowers/plans/2026-09-13-uwumacs.md), P06/P15.
