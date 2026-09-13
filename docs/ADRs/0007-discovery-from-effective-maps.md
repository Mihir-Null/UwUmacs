# ADR-0007: Derive discovery from effective executable maps

- Status: **selected**
- Origin: **agent-selected**
- Recorded: 2026-09-13 (backfilled from the cited evidence; not an invented original decision date)
- Implementation: **planned**
- Decision maker: user for explicitly stated product requirements; Codex for the agent-selected design details described below. Inherited choices retain unknown historical authorship.

## Context

The user asked both SPC menus and M-x hints to show actual physical keys. Literal maps simplify this but do not rewrite every help string in Emacs.

## Decision

Use Which-key for prefix discovery, Transient for option/repeated-action interfaces and Embark for candidate/object actions. Use effective native maps and command remapping for annotations in the original editing buffer. Live help includes sequence, command, owner and state/mode scope. Keep a narrow removable Marginalia adapter if necessary, and avoid caching until measured. Do not globally rewrite key-description, substitute-command-keys or package documentation.

## Alternatives considered

Independent menu trees drift from executable maps. Global key-string rewriting can change unrelated help or internal input lookup. One universal replacement menu would duplicate mature packages.

## Consequences

Menus and annotations remain testable against actual execution. Temporary menus must show their own keys. Compatibility with private interfaces must be isolated and revisited, not presented as a universal public hook.

## Provenance and implementation references

[Architecture contract](../superpowers/specs/2026-09-13-uwumacs-design.md), section 8; [Implementation plan](../superpowers/plans/2026-09-13-uwumacs.md), P04/P07/P08. [Which-key](https://github.com/justbur/emacs-which-key).
