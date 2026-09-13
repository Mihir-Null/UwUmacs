# ADR-0001: Record material decisions with explicit provenance

- Status: **accepted**
- Origin: **user-request-with-agent-format**
- Recorded: 2026-09-13 (backfilled from the cited evidence; not an invented original decision date)
- Implementation: **documentation implemented**
- Decision maker: user for explicitly stated product requirements; Codex for the agent-selected design details described below. Inherited choices retain unknown historical authorship.

## Context

The user requested a dedicated ADR folder for decisions made agentically or already documented. Existing rationale was scattered through the architecture, roadmap and literate source.

## Decision

Use docs/ADRs with stable numbered Markdown records and a machine-readable index. Record concise context, the selected option, alternatives, consequences, authority, implementation state and source references. Capture keybinding, package-scope, lifecycle, compatibility, migration and release choices. A decision can be selected for planning without being implemented or individually approved by the user. Add the same-change recording rule to the repository AGENTS.md.

## Alternatives considered

A single unstructured decisions paragraph would be hard to audit. Treating every statement as user-approved would erase provenance. One ADR for every routine command or spelling correction would obscure architectural choices.

## Consequences

Future material decisions are reviewable. Reversals create a new ADR and supersession link; historical records are not silently rewritten. User-facing rationale is recorded, not hidden deliberation. Integration contract details use per-wave decision tables so every ticket is covered without 194 tiny ADR files.

## Provenance and implementation references

User request: “record all decisions that were made agentically ... to a dedicated ADRs folder.” Format follows [Nygard-style ADR templates](https://adr.github.io/adr-templates/). See [repository agent guidance](../../AGENTS.md).
