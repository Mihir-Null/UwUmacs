# ADR-0002: Keep Meow as the editing engine and build an interaction layer

- Status: **selected**
- Origin: **user-direction-with-agent-design**
- Recorded: 2026-09-13 (backfilled from the cited evidence; not an invented original decision date)
- Implementation: **planned**
- Decision maker: user for explicitly stated product requirements; Codex for the agent-selected design details described below. Inherited choices retain unknown historical authorship.

## Context

The user chose a maintained literal leader, menus and cross-package integration for Meow, named UwUmacs, after comparing keypad, Evil and Helheim.

## Decision

Keep Meow selection, editing grammar, grabs, Beacon and states. UwUmacs owns leader/localleader maps, discovery and optional package adapters. Keep package acquisition, theme, fonts, machine paths and Lambda-specific commands out of portable core. Start in the current repository and extract a reusable package later.

## Alternatives considered

Forking Meow, switching to Evil/Hel, replacing the host package manager or building a new distribution bootstrap would enlarge scope without solving the chosen input/discovery problem.

## Consequences

The user retains Meow muscle memory and current packages. Maintaining a consistent cross-package command hierarchy is an explicit ongoing cost. Meow shims remain valuable and are not automatically duplicated.

## Provenance and implementation references

User request to build UwUmacs and approval of the three-milestone direction; [Architecture contract](../superpowers/specs/2026-09-13-uwumacs-design.md), sections 1–3; [Implementation plan](../superpowers/plans/2026-09-13-uwumacs.md), P01–P03/P17.
