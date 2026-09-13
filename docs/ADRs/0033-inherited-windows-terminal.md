# ADR-0033: Retain child-scoped Windows terminal adaptation

- Status: **accepted**
- Origin: **inherited-documented-policy**
- Recorded: 2026-09-13 (backfilled from the cited evidence; not an invented original decision date)
- Implementation: **existing host policy**
- Decision maker: user for explicitly stated product requirements; Codex for the agent-selected design details described below. Inherited choices retain unknown historical authorship.

## Context

The platform and terminal chapters document Windows environment preservation and the EAT/MSYS2 compatibility adapter.

## Decision

Keep PowerShell as the ordinary shell, MSYS2 as an explicit terminal choice, discover programs by capability, and scope POSIX environment/search-path adaptations to the spawned child process. Preserve the temporary native-comp trampoline safeguard used by that process wrapper. Do not globally replace the Windows PATH or infer that POSIX tools are always installed.

## Alternatives considered

Make MSYS2 the universal default; export a POSIX environment globally; install shells opportunistically during UwUmacs activation.

## Consequences

Process adapters need native Windows and explicit MSYS2 fixtures. The reusable core stays platform-neutral. Historical reasoning comes from the cited source, not guessed authorship.

## Provenance and implementation references

[Platform and terminal source](../../literate/30-platform.org), [porting notes](../PORTING-NOTES.md).
