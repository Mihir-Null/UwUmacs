# :3 UwUmacs development map

Status: architecture and roadmap prepared; runtime implementation starts at P00. Work is on branch `uwumacs`, based on `1f70a93`, with the physical-key-hint implementation committed separately as `51c19c1`.

Read the [dedicated ADRs](../ADRs/README.md) for decision provenance, alternatives and consequences.

Read the implementation documents in this order:

1. [Architecture contract](../superpowers/specs/2026-09-13-uwumacs-design.md): ownership, public interfaces, keymap precedence, lifecycle, localleader behavior and migration decisions.
2. [Implementation plan](../superpowers/plans/2026-09-13-uwumacs.md): P00–P17, exact source/output/test files, dependencies, review steps and release gates.
3. [Enabled integration catalogue](integrations.md): 194 individual package, command-surface and support-library tickets in execution order. These are not 194 external packages.
4. [Inventory evidence](package-inventory.json): graphical startup observations, configured declarations, package dependencies, source hashes and 63 inventory-only exclusions.

## Roadmap

| Milestone | Work | Exit condition |
|---|---|---|
| 1 | Native literal leader/localleader, state-aware maps, lazy registry, accurate menus, `:3` branding and frame policy | Real key execution, GUI hints and disable/re-enable checks pass |
| 2 | Completion → help → Dired → version control → projects/search/workspaces → Org → programming → terminals → appearance → remaining runtime compatibility | Every scheduled integration has its stated acceptance evidence |
| 3 | Independently loadable package, minimal example, extension guide and supported-version checks | Core works without Lambda or machine-local policy |

Enabled packages that load on invocation remain scheduled. Disabled configurations, unavailable guarded features, explicit language opt-ins and installed-only packages are outside the initial roadmap. The declared-but-missing `embark-consult` integration is an enabled-configuration repair ticket.

The package manager remains with the existing host configuration. UwUmacs uses native Emacs keymaps, keeps Meow's editing grammar and owns only its maps, descriptors and compatibility hooks. The `:3` symbol is plain text, independent of Nerd Fonts.

## Validate the plan

From the repository root:

```powershell
python docs/uwumacs/validate-plan.py --check-source-snapshot
git diff --check
```

The optional snapshot check compares the original inspected source files with their recorded hashes. It is expected to report drift once implementation changes those files; update the census deliberately when re-planning. Without that flag, the validator checks document links, inventory coverage, ticket order, shared constraints and ADR coverage/status metadata.

The planning commit contains only these documents and their validation helper. Hint code is committed separately as `51c19c1`; the UwUmacs runtime is still planned. No package was installed, no UwUmacs runtime was enabled, and no remote publication is implied by this roadmap.
