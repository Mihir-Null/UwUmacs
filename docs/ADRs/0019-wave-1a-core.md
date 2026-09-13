# ADR-0019: Foundational library contracts

- Status: **selected**
- Origin: **agent-selected**
- Recorded: 2026-09-13 (backfilled from the cited evidence; not an invented original decision date)
- Implementation: **P03 implements eight foundational acceptance checks; remaining Wave 1A acceptance pending**
- Decision maker: user for explicitly stated product requirements; Codex for the agent-selected design details described below. Inherited choices retain unknown historical authorship.

## Context

Core and foundational libraries need compatibility guarantees, not a new command hierarchy for internal helpers.

## Decision

Adopt the following individual contracts for this enabled-configuration wave. These are selected implementation decisions, not evidence that the packages have been reconfigured. The catalogue retains exact acceptance tests and file ownership.

| Ticket | Package / feature | Agent-selected integration decision |
|---|---|---|
| I001 | `meow` | Keep existing normal grammar; enable literal SPC only in Normal/Motion; expose keypad as an optional command |
| I002 | `emacs` | Keep native command-loop dispatch and command remapping |
| I003 | `simple` | Keep ordinary text entry, region and cancellation behavior |
| I004 | `files` | SPC f f invokes find-file; keep native C-x C-f |
| I005 | `use-package` | Keep package acquisition in the composition root, outside UwUmacs |
| I006 | `bind-key` | Bridge existing Lambda declarations during migration; use native UwUmacs maps |
| I007 | `cl-lib` | Support core data validation and test helpers; no menu |
| I008 | `cl` | Retain legacy vendor dependency only; no new UwUmacs imports |
| I009 | `subr-x` | Support string and conditional helpers; no menu |
| I010 | `compat` | Honor package dependency requirements; no menu |
| I011 | `seq` | Support map filtering and registry validation; no menu |
| I012 | `async` | Preserve Dired asynchronous operations |
| I013 | `dash` | Preserve dependencies of current utilities; no menu |
| I014 | `s` | Preserve string helper dependency; no menu |
| I015 | `f` | Preserve file helper dependency; no menu |
| I016 | `anaphora` | Retain Lambda macro support in the bridge |
| I017 | `let-alist` | Preserve the built-in dependency used by configured packages; no menu |
| I018 | `parent-mode` | Preserve derived-mode lookup used by configured packages; no menu |
| I019 | `spinner` | Preserve package activity indicators; no menu |

## Alternatives considered

Enable every installed related package; apply identical navigation keys to every context; add a menu command for every support library. These options were rejected in favor of the scoped contracts below.

## Consequences

Each ticket is independently reviewable. Existing native package actions remain available except where an explicit state-scoped contract replaces them. Missing executable/build capabilities are recorded as limitations rather than passing behavior. Revision of a contract must update its ADR, catalogue and inventory together, or supersede the decision.

## Provenance and implementation references

[Integration catalogue](../uwumacs/integrations.md), wave 1A; [Implementation plan](../superpowers/plans/2026-09-13-uwumacs.md), P01; architecture sections 4/9/10. Input evidence is the 2026-09-13 configured-package census, not the installed directory alone.

Acceptance execution owners are clarified in [ADR-0038](0038-foundational-acceptance-ownership.md) and the inventory; task references do not imply blanket ticket completion.

P03 adds individual named tests for I005, I007, I008, I009, I010, I011, I018 and
I019 in `tests/uwumacs-compatibility-tests.el`. They exercise native Windows
30.1 from source, built-in cl-lib/seq/compat/subr-x, installed parent-mode source
20240210.1906 and spinner source 1.7.4.0.20220915.94959. These are eight distinct
acceptance cases, not blanket acceptance of all Wave 1A libraries. I009 requires
final standalone-artifact revalidation at P17. Core needs no redundant support
library installation; parent-mode and spinner remain test/host dependencies,
not compulsory portable-core imports. Controller records reviewed ticket status
and code-commit evidence separately in the progress ledger.
