# ADR-0005: Compose localleaders and reject ambiguous defaults

- Status: **selected**
- Origin: **agent-selected**
- Recorded: 2026-09-13 (backfilled from the cited evidence; not an invented original decision date)
- Implementation: **P01-P02 transactional maps and localleaders implemented; registry lifecycle pending**
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

## P02 composition seam and reservation

`uwumacs-map-context-function` is an optional no-argument provider evaluated in
the target buffer. It returns `:leader-sources`, `:localleader-sources` and
`:state-sources` (an alist from `normal`/`motion` to P01 builder sources). This
is a map-input seam, not registry readiness or package loading. Foundational and
contextual non-user sources are validated together: numeric priority determines
precedence, and equal-priority overlap names both owners and rejects the candidate.
Public user leader maps remain highest. `uwumacs--leader-sources` retains the
validated foundation contributions for that combined build. Context localleader sources sit below that buffer's public
`uwumacs-localleader-map` variable. The same symbol's function returns the
effective composed map for an optional buffer.

`uwumacs-refresh` accepts an optional buffer; nil selects all live buffers.
It builds every selected candidate first, then commits the prepared roots and
eligibility flags without rerunning providers. Customize uses the same prepare
and commit stages: invalid candidates retain prior values and maps. While
inactive it validates the current buffer without installing maps.

The localleader suffix remains reserved, including when the child is empty.
Bindings overlapping that reserved suffix in leader sources or user leader maps
are errors; localleader overrides belong in the buffer's localleader map.
The reservation prevents one buffer's prefix from silently replacing another
command. User state maps intentionally compose above owned literal/state maps.
Major-mode changes reset buffer-local maps; ordinary refresh and disable/re-enable
preserve the buffer's user localleader definitions.

P02 review correction: committed candidates also carry `:metadata`, copied into
buffer-local `uwumacs--buffer-metadata` at the same commit as the maps. Its
`:leader` and `:localleader` values are P01 event-vector ownership tables;
`:state` is an alist from Normal/Motion to those tables. These describe non-user
contributions and must be reconciled with actual user-overridden native lookup
for discovery. Never re-evaluate a provider to reconstruct metadata for an older
committed map. Failed refresh preserves both maps and metadata; disable clears
the committed buffer metadata.
