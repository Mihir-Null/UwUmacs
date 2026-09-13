# ADR-0018: Bridge the current keypad with physical-key hints

- Status: **accepted**
- Origin: **user-request-with-agent-implementation**
- Recorded: 2026-09-13 (backfilled from the cited evidence; not an invented original decision date)
- Implementation: **implemented; planned replacement**
- Decision maker: user for explicitly stated product requirements; Codex for the agent-selected design details described below. Inherited choices retain unknown historical authorship.

## Context

The user asked both the SPC menu and M-x completion to show the physical keys needed in the existing semantic-leader configuration.

## Decision

Add a display-only adapter conditional on the current keypad policy. Reconstruct physical prefixes without changing Meow’s lookup formatter. Respect Control-first collision resolution and only advertise verified reachable printable leader sequences. Show physical Which-key prefixes and annotate Marginalia bindings in Normal/Motion; retain native fallback in Insert or unsupported cases. Load after Meow and reapply the descriptor after Which-key enablement.

## Alternatives considered

Globally change the key formatter, mechanically remove Control labels, advertise shadowed literal bindings, or switch to literal input during the original display-only task.

## Consequences

Implemented and committed as 51c19c1. The adapter depends on narrow Meow/Which-key internals and is scheduled for retirement by ADR-0003/0007, but is not yet superseded in running code. Fresh verification: five focused ERT tests, three graphical tests, isolated startup and tangle consistency passed before this commit.

## Provenance and implementation references

[Literate implementation](../../literate/40-editing.org), [focused tests](../../tests/key-hints-tests.el), [graphical tests](../../tests/key-hints-gui-tests.el); commit 51c19c1; [replacement decision](0003-native-literal-dispatch.md).
