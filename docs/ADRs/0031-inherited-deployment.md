# ADR-0031: Retain documented deployment and state ownership

- Status: **accepted**
- Origin: **inherited-documented-policy**
- Recorded: 2026-09-13 (backfilled from the cited evidence; not an invented original decision date)
- Implementation: **existing policy; historical details require live verification**
- Decision maker: user for explicitly stated product requirements; Codex for the agent-selected design details described below. Inherited choices retain unknown historical authorship.

## Context

The current deployment documentation already records a consolidated Lambda source snapshot and Windows startup layout. This backfill does not establish historical authorship or revalidate every machine path.

## Decision

Preserve the complete editable repository and the two documented startup junction contexts without changing HOME. Keep private.el and var state outside Git, load private overrides once after platform defaults, and keep Customize in persistent var/etc/custom.el. Keep the vendor revision/hash manifest and original licenses. Preserve selected package topics and existing archive policy; the current host’s packages are not claimed to be globally locked. Keep backups and rollback separate from Git.

## Alternatives considered

Change HOME globally; maintain two independent startup configurations; put private state into the reusable package; treat an installed archive snapshot as a reproducible package lock.

## Consequences

These are inherited constraints, not fresh decisions to recreate junctions or alter package archives. Deployment instructions can be historical; for example their old Magit-absence note is superseded by the current inventory’s installed Magit evidence. No filesystem migration is performed by this ADR.

## Provenance and implementation references

[Deployment](../DEPLOYMENT.md), [upstream provenance](../UPSTREAM.md), [framework ownership](../../literate/framework.org).
