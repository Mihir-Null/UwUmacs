# ADR-0005: Compose localleaders and reject ambiguous defaults

- Status: **selected**
- Origin: **agent-selected**
- Recorded: 2026-09-13 (backfilled from the cited evidence; not an invented original decision date)
- Implementation: **planned**
- Decision maker: user for explicitly stated product requirements; Codex for the agent-selected design details described below. Inherited choices retain unknown historical authorship.

## Context

Each major mode needs its own commands; user overrides must survive adapter reloads.

## Decision

Compose user maps above the most-specific adapter, inherited adapters and common UwUmacs defaults. Bind literal and modified leaders to the same buffer-specific root. Derive SPC m from that buffer’s localleader. Undefined keys fall through. Conflicting defaults at equal specificity name both owners and preserve the last valid map set; user overrides are intentional and win.

## Alternatives considered

A global mutable localleader leaks between buffers. Silent last-writer-wins makes startup order part of the keybinding API.

## Consequences

Two-buffer, derived-mode and collision tests are mandatory. Adapters need explicit ownership metadata. Changing keys through Customize recomposes maps once.

## Provenance and implementation references

[Architecture contract](../superpowers/specs/2026-09-13-uwumacs-design.md), sections 5–7; [Implementation plan](../superpowers/plans/2026-09-13-uwumacs.md), P01–P03.
