# ADR-0035: Retain the minimal Org storage boundary

- Status: **accepted**
- Origin: **inherited-documented-policy**
- Recorded: 2026-09-13 (backfilled from the cited evidence; not an invented original decision date)
- Implementation: **existing host policy**
- Decision maker: user for explicitly stated product requirements; Codex for the agent-selected design details described below. Inherited choices retain unknown historical authorship.

## Context

The current Org user module intentionally supplies only a portable directory, inbox and task/note capture templates over Lambda’s Org configuration.

## Decision

Keep the configured starter Org directory, inbox.org, agenda files and simple task/note captures. Preserve the independent notes vault. Test new Org adapters against a temporary org-directory and ID database, not user content. Do not enable installed Denote, citation or publishing modules merely because their archives remain present.

## Alternatives considered

Migrate the user’s notes to fit the adapter design; import a new ontology; activate all installed Org extensions.

## Consequences

Org integration can progress without a content migration. Later notes workflows require their own selected scope and decision record.

## Provenance and implementation references

[Org source](../../literate/70-org.org), [scope decision](0013-enabled-scope-and-inventory.md).
