# ADR-0016: Extract a minimal reusable artifact after integration validation

- Status: **selected**
- Origin: **agent-selected**
- Recorded: 2026-09-13 (backfilled from the cited evidence; not an invented original decision date)
- Implementation: **planned**
- Decision maker: user for explicitly stated product requirements; Codex for the agent-selected design details described below. Inherited choices retain unknown historical authorship.

## Context

The user wants a maintained Meow layer that can grow beyond this personal Lambda installation.

## Decision

After milestone 2, package an explicit UwUmacs output allowlist, excluding the host bridge, private config and var state by default. Add headers, real dependency requirements, autoloads, preserved licenses, a minimal non-Lambda example, extension guide and compatibility evidence. Core must load without lem-*/starter-* or package installation. Publishing remains a distinct user-authorized action, not an automatic consequence of finishing a plan.

## Alternatives considered

Publish the entire private configuration as the reusable package; claim standalone readiness based only on the existing host; add a new package manager.

## Consequences

The first reusable release needs actual artifact tests and tested version statements. Current branch pushes to the existing private repository do not constitute a public package release.

## Provenance and implementation references

[Implementation plan](../superpowers/plans/2026-09-13-uwumacs.md), P17; [Architecture contract](../superpowers/specs/2026-09-13-uwumacs-design.md), sections 2/10.
