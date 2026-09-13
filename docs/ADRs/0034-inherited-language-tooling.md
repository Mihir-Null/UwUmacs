# ADR-0034: Retain pinned grammar recipes and explicit language tooling

- Status: **accepted**
- Origin: **inherited-documented-policy**
- Recorded: 2026-09-13 (backfilled from the cited evidence; not an invented original decision date)
- Implementation: **existing host policy**
- Decision maker: user for explicitly stated product requirements; Codex for the agent-selected design details described below. Inherited choices retain unknown historical authorship.

## Context

The programming chapter documents pinned parsers, availability checks and empty language/server opt-ins.

## Decision

Keep exact grammar revisions and ABI checks, remap to tree-sitter modes only when both the grammar and target mode work, retain classic-mode fallback, and install grammars only through explicit commands. Keep Eglot available without starting servers automatically. Nix, Racket and Guile packages remain explicit opt-ins; the current empty list is outside the initial adapter roadmap.

## Alternatives considered

Use moving grammar branches, unconditional tree-sitter remaps, or automatically install/start every language server.

## Consequences

A fallback mode is a supported outcome, not proof that an unavailable parser or server works. Preserve the exact-revision install adapter in the host until a tested replacement exists.

## Provenance and implementation references

[Programming source](../../literate/60-programming.org), [enabled scope](0013-enabled-scope-and-inventory.md).
