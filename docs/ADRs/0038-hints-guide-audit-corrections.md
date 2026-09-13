# ADR-0038: Reflect P00 audit findings in the hints-only guide

- Status: **accepted**
- Origin: **user-request-with-agent-documentation-scope**
- Recorded: 2026-09-13
- Implementation: **guide corrections; existing hints adapter retained**
- Decision maker: user requested the review findings on the lightweight hints branch and publication; Codex selected the guide wording and verification scope.

## Context

The user asked to retire the consumed UwUmacs handoff, inspect P00's changes/ADRs/review, and incorporate its findings into the lightweight hints branch's keybinding guide. They explicitly prohibited beginning the next roadmap task.

P00's reviewed code range is `21dbebc..ad49657` on `uwumacs`. The tracked alignment review and controller's scoped re-review record all eight fix findings addressed. The local graphical audit names full source commit `ad49657276a7da4dfc6af58431089d439465b56a`, a clean capture worktree, 144 activated packages and no capture errors. Its keypad traces use Meow's lookup functions; this is simulation within the observed configuration, not physically typed GUI coverage of every sequence.

## Decision

Apply only the original physical-hint commit (`51c19c1`, cherry-picked as `fbb3ca2`) and the guide corrections to `feat/meow-physical-key-hints`. Keep P00's framework, tooling and roadmap commits off this branch.

- Replace the advertised dead `SPC ?` shortcut with `M-x apropos-command`, while explicitly documenting that `consult-apropos` remains unbound as a function in the inspected installation. Do not assert an unverified upstream removal history.
- Explain that `SPC p b` resolves to `project-list-buffers`, `SPC p x` to the Control-x submap, and `SPC p x s` to `project-save-some-buffers`. Offer M-x and native Control-leader access for the shadowed commands. Preserve the four-path/25-entry correction.
- Document the already-working `SPC s l` path to `vertico-repeat`; `SPC l` is the LSP submenu.
- Restrict frame-remapping claims to the native keys exercised by P00's graphical tests. Do not claim equivalent keypad remapping without evidence.
- Record the missing/undeclared `embark-consult` integration and competing Corfu formatters as current limitations, without implementing the later integration repairs.

## Alternatives considered

Merge the full UwUmacs branch, which defeats the requested lightweight scope. Rebind project keys or repair packages immediately, which goes beyond incorporating findings into the guide. Leave inaccurate shortcuts in the quick-reference table because a raw-map test accepts them, which preserves precisely the problem the review discovered.

## Consequences

The guide distinguishes native leader input from keypad translation and provides usable command-name fallbacks. Runtime map defects remain explicit; the hint adapter changes presentation, not lookup policy. The existing startup row gate alone does not validate physical dispatch or command availability. Validate the corrected guide against actual Meow lookup and callable commands, as well as running the existing startup and focused hint checks. P01 and later work remain paused.

## Verification

On 2026-09-13, an isolated startup probe on this lightweight branch checked all 35 supported SPC/M-x table rows for callable commands and actual Meow lookup results. It also checked the three project keypad outcomes, four native project-leader alternatives, `SPC s l`, and the unavailable `consult-apropos` note: all passed. This is dispatch simulation, not a fresh graphical run. The first probe attempt hit the host's read-only native-trampoline cache; disabling trampoline compilation only in the temporary probe resolved that harness issue.

The existing isolated startup check passed, all five focused hint tests passed, the tangle check matched all 17 outputs, and guide/ADR links and whitespace checks passed. The temporary extended probe is local audit evidence rather than a newly installed runtime component. P00's graphical results remain prior evidence; no claim of rerunning them is made for these documentation edits.

## Provenance and implementation references

User request of 2026-09-13 following the P00 completion report. See the [keybinding guide](../../lambda-library/lambda-user/keybindings.org) and [hint tests](../../tests/key-hints-tests.el). On the separate `uwumacs` branch, `docs/ADRs/alignment-review.md` F4–F7, `docs/ADRs/implementation-state.md` FX1–FX3, `tools/observed-keys.el`, and the P00 scoped fix commit `ad49657` preserve the review context. The ignored audit artifact is not copied into this branch or published as user state.
