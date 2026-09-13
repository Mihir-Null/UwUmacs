# ADR-0017: Use frames-only-mode with scoped display exceptions

- Status: **accepted**
- Origin: **user-request-with-agent-implementation**
- Recorded: 2026-09-13 (backfilled from the cited evidence; not an invented original decision date)
- Implementation: **implemented; retained host policy**
- Decision maker: user for explicitly stated product requirements; Codex for the agent-selected design details described below. Inherited choices retain unknown historical authorship.

## Context

The user requested frames-only-mode so the actual window manager manages new editing windows. Lambda’s Popper and Magit placement defaults could conflict with that preference.

## Decision

Enable frames-only-mode while keeping completion windows attached. Disable only Popper display control while active. Wrap Lambda’s Magit display function for graphical frame reuse/pop-up. Exclude the package’s legacy magit-commit-show-diff and magit-bury-buffer-function configuration overrides. Remap standard split commands and the two Lambda split-and-focus wrappers in the mode map; avoid re-enabling an already-enabled mode during re-evaluation.

## Alternatives considered

Apply unconditional pop-up-frames globally, disable all Popper behavior, or inherit legacy Magit quit settings. These can detach temporary controls or mishandle restoration and frame quitting.

## Consequences

Frame preference and installation were user-authorized; the adapter/filtering details were agent-selected. It is implemented in commit 8d2102f and included by merge 1f70a93. This records the intended current policy, not proof that every Meow keypad invocation honors native remapping; the literal-leader migration explicitly tests that path.

## Provenance and implementation references

[Frame source and rationale](../../literate/45-frames.org), [frame tests](../../tests/frames-tests.el); UwUmacs P06.
