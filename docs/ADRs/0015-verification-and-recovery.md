# ADR-0015: Use behavior-based gates and recoverable migration checkpoints

- Status: **selected**
- Origin: **agent-selected**
- Recorded: 2026-09-13 (backfilled from the cited evidence; not an invented original decision date)
- Implementation: **planned**
- Decision maker: user for explicitly stated product requirements; Codex for the agent-selected design details described below. Inherited choices retain unknown historical authorship.

## Context

Graphical state, completion and frame bugs are not established by batch package loading. The hint test originally needed correction because forcing an already-active Meow mode disabled the test’s state.

## Decision

Use temporary files/buffers/repos/Org stores; block package acquisition in isolated checks. Verify effective keys, actual execution, rendered menus/annotations, arguments/remapping, localleader isolation, temporary maps, reload/disable and native GUI startup. Keep daemon/terminal gates separate. Preserve existing Meow Beacon behavior until explicit fixtures establish differences. Maintain source hashes and per-ticket pending/in-progress/verified/capability-limited records. A missing capability is not a passed execution test. Checkpoint hints separately before replacement.

## Alternatives considered

Only test function return values or substrings that also match native key labels; run destructive tests in real workspaces; treat downloads or skipped tests as completion.

## Consequences

Verification costs more than startup smoke alone but targets the observed failure modes. Live probes exit only their own Emacs process. Local implementation commits remain separable from design documentation.

## Provenance and implementation references

[Architecture contract](../superpowers/specs/2026-09-13-uwumacs-design.md), section 10; [Implementation plan](../superpowers/plans/2026-09-13-uwumacs.md), P00/P06 and evidence format. [Hint GUI tests](../../tests/key-hints-gui-tests.el).
