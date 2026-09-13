# ADR-0006: Use a small lazy integration registry

- Status: **selected**
- Origin: **agent-selected**
- Recorded: 2026-09-13 (backfilled from the cited evidence; not an invented original decision date)
- Implementation: **planned**
- Decision maker: user for explicitly stated product requirements; Codex for the agent-selected design details described below. Inherited choices retain unknown historical authorship.

## Context

The enabled configuration contains packages that load only on a command or mode entry, plus internal feature names that differ from package names.

## Decision

Use plain Lisp descriptor data: features, modes, requires, leader/local/state bindings, initial-state, setup and capability. Implement disabled/pending/ready/unavailable/failed statuses. Validate dependency cycles and refuse removal of a dependency with enabled dependants. Setup can return a cleanup closure. Core selection defaults to nil; the host selects integrations explicitly. Disabled pending callbacks cannot reactivate later. Public signatures and exact field types remain in architecture section 5.

## Alternatives considered

A Doom-sized binding DSL, mandatory General dependency, eager require of every target, or implicit package installation would obscure the intended small API.

## Consequences

Feature readiness differs from package availability. Registry dependency order differs from package-manager dependency order. Tests must cover idempotence, missing libraries and callbacks after disable. The API is agent-selected and remains unimplemented.

## Provenance and implementation references

[Architecture contract](../superpowers/specs/2026-09-13-uwumacs-design.md), section 5; [Implementation plan](../superpowers/plans/2026-09-13-uwumacs.md), P03/P17; [Evil Collection](https://github.com/emacs-evil/evil-collection).
