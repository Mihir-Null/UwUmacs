# ADR-0010: Preserve host policy behind a temporary Lambda bridge

- Status: **selected**
- Origin: **agent-selected-with-inherited-constraints**
- Recorded: 2026-09-13 (backfilled from the cited evidence; not an invented original decision date)
- Implementation: **planned**
- Decision maker: user for explicitly stated product requirements; Codex for the agent-selected design details described below. Inherited choices retain unknown historical authorship.

## Context

Current command maps refer to lem-* and starter-* utilities. The desired reusable layer must not absorb machine policy.

## Decision

Keep vendor files and installed packages intact initially. Bridge selected command symbols through uwumacs-compat-lambda.el instead of sharing entire mutable vendor maps. Keep current completion, Sonokai, PowerShell, explicit MSYS2, opt-in language servers and independent Org storage. Frames-only is host-selected, not required by portable core. Move later host leader contributions to owned descriptors.

## Alternatives considered

Rename/fork all Lambda symbols immediately; silently import the vendor map hierarchy; bake Windows paths into core.

## Consequences

Migration is incremental and reversible. Host-specific utility dependencies must be removed or isolated before standalone packaging. Inherited choices are preserved without asserting that Codex made their original decisions.

## Provenance and implementation references

[Architecture contract](../superpowers/specs/2026-09-13-uwumacs-design.md), sections 2/9; [Implementation plan](../superpowers/plans/2026-09-13-uwumacs.md), P05/P17; [upstream boundary](../UPSTREAM.md).
