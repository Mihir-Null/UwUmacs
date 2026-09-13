# ADR-0006: Use a small lazy integration registry

- Status: **selected**
- Origin: **agent-selected**
- Recorded: 2026-09-13 (backfilled from the cited evidence; not an invented original decision date)
- Implementation: **P03 registry, readiness, cleanup and user overrides implemented**
- Decision maker: user for explicitly stated product requirements; Codex for the agent-selected design details described below. Inherited choices retain unknown historical authorship.

## Context

The enabled configuration contains packages that load only on a command or mode entry, plus internal feature names that differ from package names.

## Decision

Use plain Lisp descriptor data: features, modes, requires, leader/local/state bindings, initial-state, setup and capability. Implement disabled/pending/ready/unavailable/failed statuses. Validate dependency cycles and refuse removal of a dependency with enabled dependants. Setup can return a cleanup closure. Core selection defaults to nil; the host selects integrations explicitly. Disabled pending callbacks cannot reactivate later. Public signatures and exact field types remain in architecture section 5.

### P03 lifetime clarification

Mode-scoped descriptors wait until their features and a matching live buffer are
available. Setup runs with that buffer current, once per enabled readiness
lifetime. Owned global effects remain until disable or descriptor replacement;
switching buffers does not retire and recreate them. Per-buffer behavior belongs
in a named mode hook installed by setup and removed by its returned cleanup.
Each buffer receives local/state maps only for its current mode, with the nearest
ancestor winning. Leader entries are global, independent of current mode, at
priority zero; two global defaults sharing a key conflict even when their mode
contexts differ. A callable pending leader does not run setup in an unrelated
buffer. This keeps the Dired opener available before entering Dired. Initial state applies on context entry, never on ordinary refresh after
a user changes state.

Selection is explicit in `uwumacs-integrations`. Enabling adds that ID; its
requirements must already be selected and registered. Disabling removes the ID
and refuses selected dependants. Disabling the global mode retires effects while
retaining the selected list for re-enable. Registration validates exact data,
the dependency graph and candidate maps before replacing visible descriptors.
Independent lifetimes follow the selected list order, with dependencies first.
Replacing a dependency retires dependent effects first, then establishes new
lifetimes in dependency order. An identical registration is inert. After
successful setup, the override hook
runs before the final map refresh; user maps remain authoritative.

Setup must return nil or a cleanup function. Cleanup must remove only its own
still-owned changes and tolerate prior user changes. If setup signals before
returning cleanup, it must undo its own partial work using `unwind-protect`;
the registry cannot recover a closure that was never returned. Later failures
run any returned cleanup and report failed rather than ready. Failed lifetimes
are retried only after explicit disable/re-enable or descriptor replacement.

Pre-setup conflicts preserve the previous descriptor selection and all committed
maps/metadata. If a setup/override hook causes a conflict, its returned cleanup
runs and its status becomes failed. If the final map build still fails (for
example a user hook occupied the reserved localleader), all newly started,
uncommitted lifetimes are failed and cleaned; previous committed maps/metadata
remain. Direct user-map mutations are never rolled back. Doctor reports the
error; after correcting the user's map, refresh rebuilds without failed entries.
An explicit disable/re-enable or replacement is required to retry failed setup.
A buffer-specific refresh stays local when global readiness has not changed;
feature or lifetime changes refresh all buffers to keep global leaders coherent.

The registry installs only its provider and an after-load observer while global
mode is on; P02's existing mode/state observers coordinate entry and synchronous
input eligibility. Core load alone remains inert and does not require Meow.

This clarifies zero-argument lifetime and the existing P02 seam under the user's
approved roadmap authority; it adds no descriptor field or public API.

## Alternatives considered

A Doom-sized binding DSL, mandatory General dependency, eager require of every target, or implicit package installation would obscure the intended small API.

## Consequences

Feature readiness differs from package availability. Registry dependency order differs from package-manager dependency order. Tests must cover idempotence, missing libraries and callbacks after disable. The API is agent-selected; P03 supplies the implementation and focused registry tests.

## Provenance and implementation references

[Architecture contract](../superpowers/specs/2026-09-13-uwumacs-design.md), section 5; [Implementation plan](../superpowers/plans/2026-09-13-uwumacs.md), P03/P17; [Evil Collection](https://github.com/emacs-evil/evil-collection).

P03 evidence: `tests/uwumacs-registry-tests.el`,
`tests/uwumacs-registry-gui-tests.el`, and the independent support checks in
`tests/uwumacs-compatibility-tests.el`. The selected global/local distinction is
consistent with the mode-specific `SPC m` convention in
[Spacemacs conventions](https://www.spacemacs.org/doc/CONVENTIONS.html), section
2.1.2; exact lifetime and global conflict semantics remain this project's
agent-selected decisions, not a claim of universal consensus.
