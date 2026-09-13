# ADR-0021: Completion and candidate-action integrations

- Status: **selected**
- Origin: **agent-selected**
- Recorded: 2026-09-13 (backfilled from the cited evidence; not an invented original decision date)
- Implementation: **planned**
- Decision maker: user for explicitly stated product requirements; Codex for the agent-selected design details described below. Inherited choices retain unknown historical authorship.

## Context

Completion interfaces consume text, TAB and candidate actions; they cannot safely inherit a blanket modal key override.

## Decision

Adopt the following individual contracts for this enabled-configuration wave. These are selected implementation decisions, not evidence that the packages have been reconfigured. The catalogue retains exact acceptance tests and file ownership.

| Ticket | Package / feature | Agent-selected integration decision |
|---|---|---|
| I026 | `vertico` | Keep minibuffer text entry; navigate candidates with C-n/C-p and arrows |
| I027 | `vertico-buffer` | Keep the configured completion presentation subject to frame policy |
| I028 | `vertico-directory` | Preserve directory entry, deletion and tidy behavior |
| I029 | `vertico-repeat` | Use SPC s l for completion history; retain the effective LSP owner of SPC l |
| I030 | `orderless` | Preserve orderless matching and file-category partial completion |
| I031 | `consult` | Retain SPC s s line search and SPC b b buffer selection; preserve preview and narrowing |
| I032 | `consult-dir` | Add SPC f D for directory switching within supported completion |
| I033 | `marginalia` | Prefer reachable UwUmacs bindings in the original editing buffer |
| I034 | `embark` | Preserve candidate-specific action maps and their own help |
| I035 | `embark-consult` | Repair the declared-but-missing integration through explicit package policy during this ticket |
| I036 | `corfu` | Keep completion navigation, acceptance and abort; honor Meow Insert exit |
| I037 | `cape` | Expose explicit completion providers through SPC c p and existing completion-at-point |
| I038 | `dabbrev` | Keep dynamic abbreviation as a completion provider |
| I039 | `yasnippet` | SPC i becomes an insert group; SPC i s inserts a snippet; relocate the old config shortcut to SPC C i |
| I040 | `kind-icon` | Choose one Corfu formatter via UwUmacs appearance policy; retain this as selectable alternative |
| I041 | `nerd-icons-corfu` | Default to the existing Nerd Icons visual family when available |

## Alternatives considered

Enable every installed related package; apply identical navigation keys to every context; add a menu command for every support library. These options were rejected in favor of the scoped contracts below.

## Consequences

Each ticket is independently reviewable. Existing native package actions remain available except where an explicit state-scoped contract replaces them. Missing executable/build capabilities are recorded as limitations rather than passing behavior. Revision of a contract must update its ADR, catalogue and inventory together, or supersede the decision.

## Provenance and implementation references

[Integration catalogue](../uwumacs/integrations.md), wave 2A; [Implementation plan](../superpowers/plans/2026-09-13-uwumacs.md), P07; architecture sections 4/9/10. Input evidence is the 2026-09-13 configured-package census, not the installed directory alone.
