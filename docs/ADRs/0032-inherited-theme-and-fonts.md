# ADR-0032: Retain the documented theme, font and dashboard architecture

- Status: **accepted**
- Origin: **inherited-documented-policy**
- Recorded: 2026-09-13 (backfilled from the cited evidence; not an invented original decision date)
- Implementation: **existing policy; branding and formatter reconciliation planned**
- Decision maker: user for explicitly stated product requirements; Codex for the agent-selected design details described below. Inherited choices retain unknown historical authorship.

## Context

The appearance source already defines a tracked Sonokai port, theme lifecycle, conditional icon ranges and font-aware dashboard layout.

## Decision

Keep the tracked theme outside var/elpa, one active selected theme, and the existing light/dark toggle lifecycle. Keep text-font choice independent from icon availability, map only the required icon glyph ranges, and establish metrics before dashboard centering. Preserve the existing modeline/workspace architecture and explicit documentation entry points. UwUmacs adds optional branding through ADR-0012; completion formatter selection is a planned wave-2A decision.

## Alternatives considered

Replace the exact tracked theme with a similar package theme; require Nerd Fonts for basic text; overwrite all Unicode font mapping; introduce another modeline/workspace system solely for branding.

## Consequences

These inherited mechanisms stay behind host/appearance adapters. This record does not claim their original authorship or that the planned icon-provider reconciliation is already implemented.

## Provenance and implementation references

[Appearance source](../../literate/50-appearance.org), [dashboard source](../../literate/55-dashboard.org), [deployment theme ownership](../DEPLOYMENT.md).
