# ADR-0009: Keep flat generated outputs and focused modules

- Status: **selected**
- Origin: **agent-selected**
- Recorded: 2026-09-13 (backfilled from the cited evidence; not an invented original decision date)
- Implementation: **P01-P02 literate core and four flat outputs implemented; remaining modules pending**
- Decision maker: user for explicitly stated product requirements; Codex for the agent-selected design details described below. Inherited choices retain unknown historical authorship.

## Context

The existing tangle validator allows only explicit flat user-library outputs. The project already uses literate authoring with tracked generated Lisp.

## Decision

Keep Org authoritative and startup generation-free. Author new chapters 41–44 for core, discovery, integrations and Lambda compatibility. Generate flat uwumacs-*.el files in lambda-library/lambda-user and register every output in the manifest. Separate maps/state/registry/discovery/branding/host bridge. Related per-package descriptors may share one wave file; split by responsibility when needed.

## Alternatives considered

Weaken tangle validation to permit arbitrary nested paths; place maintained code in var/elpa; one giant config file; one empty file for every census row.

## Consequences

The current generation safety boundary remains intact. Org and generated Lisp must be committed together. Package identity remains individual even when files are shared.

## Provenance and implementation references

[Architecture contract](../superpowers/specs/2026-09-13-uwumacs-design.md), sections 2/4/9; [Implementation plan](../superpowers/plans/2026-09-13-uwumacs.md), P01–P17; [tangle implementation](../../tools/tangle.el).
