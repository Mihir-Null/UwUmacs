# ADR-0003: Use native literal prefix lookup

- Status: **selected**
- Origin: **agent-selected**
- Recorded: 2026-09-13 (backfilled from the cited evidence; not an invented original decision date)
- Implementation: **P01-P02 native maps and activation implemented; host migration pending**
- Decision maker: user for explicitly stated product requirements; Codex for the agent-selected design details described below. Inherited choices retain unknown historical authorship.

## Context

The working hint adapter explains keypad translations, but the user now wants directly maintained physical bindings.

## Decision

Bind command symbols and native submaps. Let the Emacs command loop resolve the whole literal sequence, including remapping, prefix arguments, hooks and macro recording. Do not add a key-reading loop, keyboard-macro translation table or generic call-interactively dispatcher. Keep original keypad explicitly accessible; migrate away from its SPC dispatch only after verification.

## Alternatives considered

Continue translation plus reconstructed labels; flatten native Control/Meta bindings mechanically; emulate another key sequence. These preserve ambiguity or bypass command-loop semantics.

## Consequences

A displayed sequence can be verified by native lookup. Native prefix collisions still need individual choices. Keypad-specific selection/Beacon conveniences do not automatically carry over. This decision schedules replacement of ADR-0018; it does not claim that replacement already shipped.

## Provenance and implementation references

[Architecture contract](../superpowers/specs/2026-09-13-uwumacs-design.md), sections 3, 6–8; [Implementation plan](../superpowers/plans/2026-09-13-uwumacs.md), P01/P02/P05. [Current hint adapter](0018-physical-hint-adapter.md).
