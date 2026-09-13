# ADR-0013: Prioritize enabled configurations and distinguish evidence

- Status: **selected**
- Origin: **user-scope-with-agent-classification**
- Recorded: 2026-09-13 (backfilled from the cited evidence; not an invented original decision date)
- Implementation: **planned**
- Decision maker: user for explicitly stated product requirements; Codex for the agent-selected design details described below. Inherited choices retain unknown historical authorship.

## Context

The user explicitly narrowed priority to enabled configuration rather than disabled or installed-but-unused/deferred integrations. A package folder alone does not establish use.

## Decision

Schedule configured commands that load on invocation, active dependencies and documented built-in surfaces. Keep absent guarded integrations, empty language opt-ins, provisioned-only and install-only packages inventory-only. Do not activate or uninstall them. Distinguish declaration intent, library availability and observed feature loading. Store package names/versions, relative source references and hashes; exclude private source, history and account data. Each scheduled entry receives a disposition and acceptance check.

## Alternatives considered

Treat every installed package as active; treat every not-yet-loaded feature as disabled; activate everything to simplify the census.

## Consequences

The current catalogue contains 194 package/feature/support tickets, 160 configured names, and 63 inventory-only entries; 144 installed packages have dispositions. Counts are snapshot evidence, not a promise of 194 external integrations or proof of successful feature loads. Interpreting enabled lazy loading as in scope is explicitly an agent interpretation, communicated to the user.

## Provenance and implementation references

User scope correction; [Integration catalogue](../uwumacs/integrations.md); [inventory evidence](../uwumacs/package-inventory.json).
