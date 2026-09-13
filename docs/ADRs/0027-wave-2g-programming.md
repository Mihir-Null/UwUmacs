# ADR-0027: Structural editing and programming integrations

- Status: **selected**
- Origin: **agent-selected**
- Recorded: 2026-09-13 (backfilled from the cited evidence; not an invented original decision date)
- Implementation: **planned**
- Decision maker: user for explicitly stated product requirements; Codex for the agent-selected design details described below. Inherited choices retain unknown historical authorship.

## Context

Meow selection and structural tools can interact; server/process-backed capabilities must remain deliberate and separately testable.

## Decision

Adopt the following individual contracts for this enabled-configuration wave. These are selected implementation decisions, not evidence that the packages have been reconfigured. The catalogue retains exact acceptance tests and file ownership.

| Ticket | Package / feature | Agent-selected integration decision |
|---|---|---|
| I103 | `eglot` | Keep SPC l as code-intelligence menu; retain explicit server startup |
| I104 | `eldoc` | Keep documentation popup access and state-neutral feedback |
| I105 | `flymake` | Keep diagnostics under F and LSP integration |
| I106 | `consult-flymake` | Treat as a Consult-provided command surface, not a separately installable package |
| I107 | `flymake-collection` | Retain selected backend hooks and capability checks |
| I108 | `emacs-lisp-mode` | Provide eval, check and test actions under localleader |
| I109 | `lisp-mode` | Preserve Lisp syntax and structural editing conventions |
| I110 | `sh-script` | Retain shell-script editing and syntax-specific local actions |
| I111 | `prog-mode` | Use shared programming localleader defaults inherited by derived modes |
| I112 | `treesit` | Keep pinned grammar policy and availability-gated remaps |
| I113 | `puni` | Integrate structural editing with selection and minibuffer exceptions |
| I114 | `embrace` | Expose wrapping as an explicit editing action |
| I115 | `iedit` | Keep its own edit session and exit semantics |
| I116 | `expand-region` | Keep explicit expansion alongside Meow selection |
| I117 | `elec-pair` | Preserve automatic pair insertion in Insert |
| I118 | `paren` | Preserve pair highlighting; no new keys |
| I119 | `aggressive-indent` | Retain currently configured mode hooks |
| I120 | `rainbow-delimiters` | Keep optional delimiter coloring |
| I121 | `rainbow-identifiers` | Keep optional identifier coloring |
| I122 | `highlight-indent-guides` | Keep indentation guides in supported buffers |
| I123 | `elisp-def` | Keep the explicit Elisp definition helper |
| I124 | `package-lint` | Add a development action for linting UwUmacs libraries |
| I125 | `multi-compile` | Retain the configured command selector |
| I126 | `compile` | Keep compilation start/recompile/error navigation |
| I127 | `kmacro` | Preserve native recording and execution through the command loop |
| I128 | `repeat` | Allow repeat maps to own their temporary keys |

## Alternatives considered

Enable every installed related package; apply identical navigation keys to every context; add a menu command for every support library. These options were rejected in favor of the scoped contracts below.

## Consequences

Each ticket is independently reviewable. Existing native package actions remain available except where an explicit state-scoped contract replaces them. Missing executable/build capabilities are recorded as limitations rather than passing behavior. Revision of a contract must update its ADR, catalogue and inventory together, or supersede the decision.

## Provenance and implementation references

[Integration catalogue](../uwumacs/integrations.md), wave 2G; [Implementation plan](../superpowers/plans/2026-09-13-uwumacs.md), P13; architecture sections 4/9/10. Input evidence is the 2026-09-13 configured-package census, not the installed directory alone.
