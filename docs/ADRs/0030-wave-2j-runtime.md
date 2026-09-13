# ADR-0030: Remaining runtime compatibility

- Status: **selected**
- Origin: **agent-selected**
- Recorded: 2026-09-13 (backfilled from the cited evidence; not an invented original decision date)
- Implementation: **planned**
- Decision maker: user for explicitly stated product requirements; Codex for the agent-selected design details described below. Inherited choices retain unknown historical authorship.

## Context

Persistence, input methods, widgets and performance guards are compatibility surfaces, not reasons to widen interaction scope.

## Decision

Adopt the following individual contracts for this enabled-configuration wave. These are selected implementation decisions, not evidence that the packages have been reconfigured. The catalogue retains exact acceptance tests and file ownership.

| Ticket | Package / feature | Agent-selected integration decision |
|---|---|---|
| I174 | `autorevert` | Keep automatic refresh behavior |
| I175 | `desktop` | Keep desktop persistence opt-in |
| I176 | `savehist` | Keep minibuffer history storage policy |
| I177 | `saveplace` | Keep saved cursor positions |
| I178 | `uniquify` | Keep buffer-name disambiguation |
| I179 | `multisession` | Keep existing persistence choices |
| I180 | `time-stamp` | Preserve configured timestamp behavior |
| I181 | `ws-butler` | Keep save-time whitespace cleanup in configured modes |
| I182 | `subword` | Preserve word-boundary behavior |
| I183 | `so-long` | Keep long-line protection authoritative |
| I184 | `display-line-numbers` | Keep the explicit line-number toggle |
| I185 | `pixel-scroll` | Retain the effective configured scrolling behavior |
| I186 | `mouse` | Preserve native mouse selection and links |
| I187 | `mwheel` | Preserve wheel scrolling |
| I188 | `xwidget` | Gate graphical embedded widgets by build capability |
| I189 | `mule-cmds` | Preserve coding-system commands |
| I190 | `gnutls` | Keep transport policy with Emacs, outside UwUmacs |
| I191 | `advice` | Use named, removable advice only at documented compatibility boundaries |
| I192 | `cus-edit` | Expose UwUmacs customization without replacing Customize |
| I193 | `wid-edit` | Keep widget field typing and navigation |
| I194 | `crux` | Retain useful file/buffer helper commands through the Lambda bridge |

## Alternatives considered

Enable every installed related package; apply identical navigation keys to every context; add a menu command for every support library. These options were rejected in favor of the scoped contracts below.

## Consequences

Each ticket is independently reviewable. Existing native package actions remain available except where an explicit state-scoped contract replaces them. Missing executable/build capabilities are recorded as limitations rather than passing behavior. Revision of a contract must update its ADR, catalogue and inventory together, or supersede the decision.

## Provenance and implementation references

[Integration catalogue](../uwumacs/integrations.md), wave 2J; [Implementation plan](../superpowers/plans/2026-09-13-uwumacs.md), P16; architecture sections 4/9/10. Input evidence is the 2026-09-13 configured-package census, not the installed directory alone.
