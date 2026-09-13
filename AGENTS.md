# Repository collaboration guidance

## Decision records

Record material agent-selected architectural, package-integration, keybinding, scope, compatibility, migration and release decisions in `docs/ADRs/` in the same change that makes them. Follow `docs/ADRs/README.md` and update `docs/ADRs/index.json` and affected cross-links.

Distinguish explicit user requirements from agent-selected implementation details and inherited policy. Record concise context, decision, alternatives, consequences and evidence. Keep implementation state separate from decision status; do not label planned code implemented or imply individual user approval that was not given.

For an existing integration contract, update its wave ADR and linked catalogue/inventory together. Substantive reversals get a successor ADR and supersession link. Routine edits and tool invocations do not need individual ADRs.

Validate documentation changes with `python docs/uwumacs/validate-plan.py`. Use `--check-source-snapshot` only when the original census source is expected to remain unchanged.
