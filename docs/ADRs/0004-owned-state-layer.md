# ADR-0004: Own a reversible state-aware emulation layer

- Status: **selected**
- Origin: **agent-selected**
- Recorded: 2026-09-13 (backfilled from the cited evidence; not an invented original decision date)
- Implementation: **P02 owned activation and buffer lifecycle implemented**
- Decision maker: user for explicitly stated product requirements; Codex for the agent-selected design details described below. Inherited choices retain unknown historical authorship.

## Context

Directly editing shared Meow/package maps becomes difficult to disable safely as mode-specific integrations grow. Ordinary minor-mode maps can lose to Meow state maps.

## Decision

Register one UwUmacs-owned emulation alist before ordinary Meow state entries. Keep its maps and eligibility flags buffer-local; observe Meow/major-mode hooks. Literal SPC is eligible in Normal/Motion, not Insert, minibuffers, terminal character input or Beacon. The modified fallback remains available in eligible editing buffers. Cleanup removes only owned entries, hooks and advice.

## Alternatives considered

Mutate all global Meow maps; restore snapshots of entire package maps; use a permanent overriding-terminal-local-map. These complicate ownership or steal temporary input.

## Consequences

Adds lifecycle code that needs state, mode, reload and disable tests. Temporary maps, text/overlay contexts, Transient, search and process input must retain their normal authority. No claim that this layer can override every context safely.

## Provenance and implementation references

[Architecture contract](../superpowers/specs/2026-09-13-uwumacs-design.md), sections 3/6; [Implementation plan](../superpowers/plans/2026-09-13-uwumacs.md), P02. [GNU active keymaps](https://www.gnu.org/software/emacs/manual/html_node/elisp/Active-Keymaps.html).

## P02 implementation details

The literate core installs `uwumacs--emulation-alist` with numeric order `-100`.
Meow's installed snapshot uses unordered entries, so native lookup reaches the
owned Normal/Motion map first. Meow mode/state hooks update buffer eligibility;
major-mode and newly visited buffers receive fresh roots. A lightweight
pre-command observer also covers input-mode flags that change without a Meow
state transition. Disabling removes these exact hooks and the owned alist, clears
buffer flags, restores the owned `list-order` hash entry, and removes an initially
absent empty ordering table. Other owners' metadata is retained. No advice or
vendor keymap changes are installed.

P02 conservatively excludes whole `term-mode`, `vterm-mode` and `eat-mode`
buffers, plus Eshell buffers with a live `eat-terminal`. Built-in
`term-in-char-mode` tests the current local map against `term-raw-map`; using it
alone would require extra transition observation. EAT 0.9.4's `eat-eshell-mode`
is global, so it is explicitly not an exclusion predicate. Dedicated terminal
adapters may later narrow the conservative policy. Beacon, Keypad and minibuffers
have neither literal nor modified leader activation.

Verification: 11 batch state cases and a bounded graphical suite with a native
command-loop case; see `tests/uwumacs-state-tests.el`,
`tests/uwumacs-state-gui-tests.el` and the P02 execution report. Terminal process
integration and package-specific temporary-interface fixtures remain with their
own tasks; the overriding-terminal-local-map priority gate passes here.
