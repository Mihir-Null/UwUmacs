# ADR-0008: Select a core runtime floor and explicit test targets

- Status: **selected**
- Origin: **agent-selected**
- Recorded: 2026-09-13 (backfilled from the cited evidence; not an invented original decision date)
- Implementation: **planned**
- Decision maker: user for explicitly stated product requirements; Codex for the agent-selected design details described below. Inherited choices retain unknown historical authorship.

## Context

Native keymap APIs and built-in Which-key make a recent Emacs baseline practical; the current observed machine is newer than the proposed minimum.

## Decision

Select GNU Emacs 30.1 as the portable core minimum. Treat Windows Emacs 31.1 as the current exercised host and Meow snapshot 20260714.1200 as the initial compatibility target. Record the real Meow source revision before standalone release. Separate GUI, daemon/terminal and Linux evidence. Do not invent tags or inherit a sibling checkout’s CI results.

## Alternatives considered

Require only the newest local Emacs, or claim support for older versions without a test matrix. Both obscure the difference between intended support and executed validation.

## Consequences

The minimum-version and standalone gates are still planned. Current graphical tests do not establish an entire cross-platform support matrix.

## Provenance and implementation references

[Architecture contract](../superpowers/specs/2026-09-13-uwumacs-design.md), sections 2/10; [Implementation plan](../superpowers/plans/2026-09-13-uwumacs.md), P00/P06/P17.
