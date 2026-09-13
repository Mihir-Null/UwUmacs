# UwUmacs :3 — architecture contract

Status: implementation in progress. P01 native maps/customization exist; the host is not yet activated. See the tracked implementation-state log for reviewed revisions and later gates.
Date: 2026-09-13. Development branch: `uwumacs`.
Baseline: `1f70a93ff5e18b2c4b2fe3b6683ae4bc27243108`, plus the physical-hint implementation committed as `51c19c1` (originally carried from `feat/meow-physical-key-hints`).

Read the [implementation plan](../plans/2026-09-13-uwumacs.md) and [ordered integration catalogue](../../uwumacs/integrations.md) together with this contract. The [inventory](../../uwumacs/package-inventory.json) records source hashes, declaration evidence, installed versions and individual ticket IDs.

## 1. Product and scope

Decision records: [ADR-0002](../../ADRs/0002-meow-interaction-layer.md), [ADR-0012](../../ADRs/0012-branding.md), [ADR-0013](../../ADRs/0013-enabled-scope-and-inventory.md).

UwUmacs is a configurable Meow interaction layer: literal leader maps, discoverable command menus and individually selectable package integrations. Its first host is the existing Lambda-based Emacs-Dots configuration. Its identity is `:3 UwUmacs`; the ASCII `:3` mark must work without a font installation or image backend.

The initial roadmap covers **enabled configurations**, including configured packages that load on command or mode entry. An installed package with no enabled declaration or active dependency is outside this roadmap. Explicitly disabled language choices, unavailable guarded integrations, and provisioned-only packages are inventory-only. They receive no automatic activation, removal, installation or scheduled feature work.

A use-package declaration and an installed archive are not proof that a feature successfully loaded. Inventory `observed_loaded` is a startup observation, not an enablement flag. Mode names, command surfaces and internal libraries are labelled as such rather than counted as distinct user-facing packages.

## 2. Fixed decisions and constraints

Decision records: [ADR-0002](../../ADRs/0002-meow-interaction-layer.md), [ADR-0004](../../ADRs/0004-owned-state-layer.md), [ADR-0005](../../ADRs/0005-composition-and-conflicts.md), [ADR-0006](../../ADRs/0006-integration-registry.md), [ADR-0008](../../ADRs/0008-compatibility-floor.md), [ADR-0009](../../ADRs/0009-literate-files-and-modules.md), [ADR-0010](../../ADRs/0010-host-boundary.md).

- Minimum supported core runtime: GNU Emacs 30.1.
- First exercised host: native Windows Emacs 31.1, with GUI and daemon/terminal checks kept distinct.
- Initial Meow compatibility target: installed Meow snapshot 20260714.1200. Record its source revision before standalone release; do not invent an upstream tag for this snapshot.
- Meow owns editing grammar, selection, grabs, Beacon and states. UwUmacs owns its keymaps, registry, menu labels and compatibility hooks.
- UwUmacs core has no package manager, network access, machine paths, fonts, themes or `lem-*` dependencies.
- Keep PowerShell default, MSYS2 explicit, language-server startup opt-in and the independent notes vault untouched.
- Preserve the current completion stack and the frames-only preference. Frames-only is a host-selected adapter, not a mandatory dependency of core.
- Every runtime change is authored in literate Org and tangled; generated Lisp remains tracked. Startup never tangles.
- Keep generated files directly in `lambda-library/lambda-user/` initially. The current tangle validator rejects nested outputs; this design does not weaken that boundary.
- Do not modify installed files under `var/elpa/`. Preserve Lambda provenance and existing licenses.
- User overrides win deterministically. Re-enabling a mode or reloading an adapter must not duplicate bindings, hooks, advice or formatters.
- Package integrations are selected explicitly. Loading core must not force every selected target package to load.
- Temporary input interfaces retain control. UwUmacs must not globally commandeer minibuffers, Transient, query-replace, isearch or terminal character input.

These constraints apply verbatim to every implementation task.

## 3. Decision rationale

Decision records: [ADR-0002](../../ADRs/0002-meow-interaction-layer.md), [ADR-0003](../../ADRs/0003-native-literal-dispatch.md), [ADR-0004](../../ADRs/0004-owned-state-layer.md), [ADR-0006](../../ADRs/0006-integration-registry.md).

Decision context, alternatives, provenance and consequences now live in the [dedicated ADR folder](../../ADRs/README.md). The selected architecture uses UwUmacs-owned native emulation maps, with Meow retaining editing/state ownership and the host retaining package policy. ADR-0002 through ADR-0006 record why this was selected and what remains unimplemented.

## 4. Components and file ownership

Decision records: [ADR-0009](../../ADRs/0009-literate-files-and-modules.md).

The Lisp outputs live in `lambda-library/lambda-user/`. P01 has implemented `uwumacs.el`, `uwumacs-maps.el` and the initial files binding in `uwumacs-integration-core.el`; remaining components are planned until recorded in the implementation-state log.

| File | Single responsibility |
|---|---|
| `uwumacs.el` | Public entry point, customization group, global activation and shutdown |
| `uwumacs-maps.el` | Canonical global/user maps, buffer-local composition and conflict checking |
| `uwumacs-state.el` | Meow state observation and owned emulation-map activation |
| `uwumacs-registry.el` | Integration descriptors, dependency ordering, lazy readiness and cleanup |
| `uwumacs-discovery.el` | Which-key labels, live help, effective binding lookup and Marginalia adapter |
| `uwumacs-compat-lambda.el` | Temporary host bindings to `lem-*` / `starter-*` commands and legacy prefix policy |
| `uwumacs-branding.el` | Optional dashboard/modeline `:3` presentation |
| `uwumacs-integration-core.el` | Compatibility contracts for built-ins and foundational libraries |
| `uwumacs-integration-discovery.el` | Home/help entry points and current frame/popup policy |
| `uwumacs-integration-completion.el` | Individual completion descriptors |
| `uwumacs-integration-help.el` | Help, Helpful and Info descriptors |
| `uwumacs-integration-dired.el` | Dired and its enabled extensions |
| `uwumacs-integration-vc.el` | Magit, VC, diff/merge and temporary editing interfaces |
| `uwumacs-integration-navigation.el` | Projects, buffers, searches, workspaces and display tools |
| `uwumacs-integration-org.el` | Current Org/agenda/capture/export policy |
| `uwumacs-integration-programming.el` | Structural editing, diagnostics, compilation and current language surfaces |
| `uwumacs-integration-terminal.el` | EAT, Eshell, native shells and process-buffer compatibility |
| `uwumacs-integration-appearance.el` | Existing presentation compatibility and icon-provider policy |
| `uwumacs-integration-runtime.el` | Persistence, large-buffer, input and remaining core compatibility |

Individual packages have their own descriptor and acceptance ticket even when closely related descriptors share a file. Split a wave file later when its features no longer change together; do not create an empty package file solely to make the file count match the census.

Literate authoring chapters:

- `literate/41-uwumacs-core.org`: entry point, maps, state, registry, core compatibility.
- `literate/42-uwumacs-discovery.org`: discovery, branding, home/frame integration.
- `literate/43-uwumacs-integrations.org`: remaining wave adapters, in adjacent topical sections.
- `literate/44-uwumacs-lambda.org`: temporary Lambda compatibility boundary.

Existing composition changes belong in `20-user-policy.org`; Meow grammar stays in `40-editing.org`. Update `literate/manifest.json` with every new source and flat output before tangling.

## 5. Public interfaces

Decision records: [ADR-0005](../../ADRs/0005-composition-and-conflicts.md), [ADR-0006](../../ADRs/0006-integration-registry.md).

The following signatures are implementation contracts. P01 customization and public maps are present; state, registry and discovery APIs remain pending their tasks.

| Interface | Contract |
|---|---|
| `(uwumacs-mode ARG)` | Global minor mode. Positive ARG enables once; nonpositive disables and removes owned hooks/maps/advice. |
| `uwumacs-leader-key` | Custom string, default `"SPC"`. Only active in eligible Normal/Motion buffers. |
| `uwumacs-localleader-key` | Custom suffix, default `"m"`, underneath the leader. |
| `uwumacs-leader-alt-key` | Custom string, default `"C-c C-SPC"`. Available in ordinary editing buffers, including Insert. |
| `uwumacs-integrations` | Ordered list of enabled descriptor IDs. The host selects a tested subset; core default is nil. |
| `uwumacs-leader-map` | Public base prefix map. Commands/submaps are ordinary Emacs bindings. |
| `uwumacs-user-leader-map` | Public override map composed above base and adapter leader bindings. |
| `uwumacs-user-state-maps` | Alist from Normal/Motion state symbols to user maps. |
| `(uwumacs-localleader-map &optional BUFFER)` | Return the effective composed localleader map for BUFFER; never mutate another buffer's map. |
| `(uwumacs-register-integration ID &rest SPEC)` | Validate/replace descriptor data and return ID. Registration never installs a package. |
| `(uwumacs-enable-integration ID)` | Enable a registered ID and its declared selected dependencies; return status symbol. |
| `(uwumacs-disable-integration ID)` | Remove owned effects. Refuse while enabled dependants require ID, naming those dependants. |
| `(uwumacs-refresh &optional BUFFER)` | Recompute readiness/maps for BUFFER, or all live eligible buffers if nil. |
| `(uwumacs-command-keys COMMAND &optional BUFFER)` | Return effective physical sequence strings valid in BUFFER, preferred leader first; empty list if none. Honor command remapping and overriding input maps. |
| `(uwumacs-describe-bindings)` | Interactive searchable live binding view, with native help fallback. |
| `(uwumacs-describe-localleader)` | Interactive help for the current localleader, including an explanation if empty. |
| `(uwumacs-doctor)` | Interactive report of status, missing capabilities and binding conflicts; no repairs or installs. |
| `uwumacs-after-integration-hook` | Called with ID after it becomes ready, for documented user overrides followed by map refresh. |

A descriptor has these exact keys:

- `:features`: list of actual feature symbols used for readiness. This is not necessarily the package name.
- `:modes`: list of major-mode symbols; derived modes inherit the descriptor unless a more-specific descriptor overrides it.
- `:requires`: list of integration IDs, validated for cycles.
- `:leader-bindings`: list of `(KEY COMMAND LABEL)`.
- `:local-bindings`: list of `(KEY COMMAND LABEL)`.
- `:state-bindings`: list of `(STATE KEY COMMAND)`, where STATE is `normal` or `motion`.
- `:initial-state`: nil (preserve Meow policy), `normal`, `motion` or `insert`.
- `:setup`: nil or a zero-argument function returning nil or a zero-argument cleanup function.
- `:capability`: nil or a zero-argument function returning t or an explanatory string. Used for optional executables/build features; never starts them.

Example descriptor shape:

```elisp
(uwumacs-register-integration
 'dired
 :features '(dired)
 :modes '(dired-mode)
 :requires nil
 :leader-bindings '(("d" dired-jump "Directory"))
 :local-bindings '(("r" dired-do-rename "Rename")
                   ("c" dired-do-copy "Copy"))
 :state-bindings '((motion "j" dired-next-line)
                   (motion "k" dired-previous-line))
 :initial-state 'motion)
```

Lazy readiness states are `disabled`, `pending`, `ready`, `unavailable` and `failed`. Package autoload commands may appear in the global leader before their target feature loads. Package-state maps and setup functions become active only when their features and mode context are ready. Disabling an integration prevents pending callbacks from activating it later.

## 6. Lookup and lifecycle algorithm

Decision records: [ADR-0003](../../ADRs/0003-native-literal-dispatch.md), [ADR-0004](../../ADRs/0004-owned-state-layer.md), [ADR-0005](../../ADRs/0005-composition-and-conflicts.md).

1. Register one symbol, `uwumacs--emulation-alist`, ahead of Meow's ordinary state entries in `emulation-mode-map-alists`. Meow adds its three state entries as literal alists with `add-to-ordered-list` and **no ORDER argument**, so they sort to the end of that list; UwUmacs must therefore pass an explicit numeric ORDER. An unordered `add-to-list` would land after Meow and be shadowed. Do not alter terminal-local overriding maps. Verified against Meow 20260714.1200 in [the alignment review](../../ADRs/alignment-review.md) finding F3.
2. Keep that symbol's value and active-state flags buffer-local. Maps for Normal, Motion and the modified fallback are built from UwUmacs-owned data.
3. Observe Meow state/mode hooks and major-mode changes. Refresh eligibility after state changes; do not replace Meow state commands or call a state minor-mode function repeatedly to force its existing state.
4. Disable literal leader maps in Insert, minibuffers, terminal character input and unsupported Meow states. Beacon is excluded initially; its keypad/macro workflow remains available explicitly.
5. Compose user overrides above the most-specific mode adapter, inherited adapter maps, and common UwUmacs maps. Undefined keys fall through to Meow and native package maps.
6. Compose a buffer-local leader root, with its localleader child computed for that buffer. Bind the literal and modified leader to that same effective map. Do not implement localleader using a function that reads another key loop.
7. On disable, remove only the owned alist entry, hooks, named advice and cleanup effects. Do not restore an entire old package map over subsequent user changes.

Conflicting non-user bindings at the same specificity are configuration errors. Validation names both owners and retains the last valid map set. No silent last-writer-wins behavior. User maps intentionally override defaults without error.

Temporary input has higher authority. Transient, isearch, query-replace, completion and process input fixtures must prove that ordinary input and cancellation remain usable. Text/overlay keymaps can also affect lookup; discovery uses effective maps in the actual context rather than assuming the emulation layer always wins.

The framework must preserve native command-loop behavior: remapping, prefix arguments, recording/replay, `this-command`, hooks and ordinary quit semantics. Bind command symbols rather than manufacturing keyboard macros or calling a command through a generic dispatcher.

## 7. Initial key vocabulary and deliberate migrations

Decision records: [ADR-0011](../../ADRs/0011-key-vocabulary.md).

Keep established useful sequences. Own the maps rather than mutating shared vendor maps.

| Prefix / key | Meaning |
|---|---|
| `SPC SPC` | M-x |
| `SPC f`, `b`, `s`, `p` | Files, buffers, search, projects |
| `SPC m` | Current mode's commands |
| `SPC c`, `e`, `i` | Change/wrap, evaluation, insertion |
| `SPC l`, `F` | Code intelligence, diagnostics |
| `SPC v` | Version control; preserve the existing v namespace |
| `SPC w`, `W` | Window/frame actions, workspaces |
| `SPC o`, `t`, `q`, `C` | Open applications, toggles, quit, configuration |
| `SPC h`, `H` | Dashboard, live keybinding help |
| `SPC /` | Describe UwUmacs bindings, replacing keypad-specific help |
| `SPC ?` | Command discovery; retain the existing apropos entry |
| `SPC s l` | Completion history, replacing the shadowed early `SPC l` binding |
| `SPC C i` | Configuration file lookup previously on single `SPC i` |
| `SPC i s` | Snippet insertion |
| `SPC f D` | Consult directory action |
| `SPC c p` | Explicit completion provider actions |

The project submenu must be explicitly defined, because the existing `project-prefix-map` can contain modified events that keypad previously handled. Capture the existing reachable commands before selecting literal aliases. Never flatten every Control/Meta binding algorithmically: collisions require individual choices and tests.

Publish a migration table for every changed sequence. Keep the modified recovery prefix. Do not add new keypad behavior while retiring the current hint adapter.

## 8. Discovery and menu contract

Decision records: [ADR-0007](../../ADRs/0007-discovery-from-effective-maps.md), [ADR-0012](../../ADRs/0012-branding.md).

The executable keymaps are authoritative. Labels decorate the maps; they are not a second independently maintained command tree.

- Which-key uses its normal public configuration and effective prefix maps. Remove the new private keypad-popup advice when literal leader takes over.
- Marginalia calls `uwumacs-command-keys` in the original editing buffer. Only its binding annotation changes; command descriptions, matching and category behavior remain intact.
- Keep a targeted, removable compatibility adapter if Marginalia lacks a suitable hook. Do not globally rewrite `key-description`, `substitute-command-keys` or package documentation strings.
- Live help shows sequence, command, integration owner, state/mode scope and whether an override is active. Static introductory docs teach the vocabulary and link to live help.
- Temporary menus show the keys active inside that menu; do not annotate a transient suffix with an unrelated global leader sequence.
- Transient remains the richer options/repeated-action interface. Embark remains the candidate/object action interface.
- `:3` branding never replaces the visible Meow state indicator.

## 9. Existing configuration changes

Decision records: [ADR-0009](../../ADRs/0009-literate-files-and-modules.md), [ADR-0010](../../ADRs/0010-host-boundary.md), [ADR-0017](../../ADRs/0017-frames-only-integration.md), [ADR-0018](../../ADRs/0018-physical-hint-adapter.md).

| Source | Change |
|---|---|
| `literate/20-user-policy.org` | Load UwUmacs after Meow, select current integration IDs and preserve host policy. Explicitly provision a selected missing dependency only in its implementation ticket. |
| `literate/40-editing.org` | Retain Meow grammar; remove global leader ownership/modifier sentinel policy after the migration gate; stop requiring the translation hint module. |
| `starter-setup-key-hints.el` and its literate blocks | Retire translation reconstruction and keypad display advice; replace the annotation functionality in discovery. Remove its manifest output atomically with source removal. |
| `literate/45-frames.org` | Retain default display policy; put UwUmacs key/menu interaction in its host adapter. |
| `literate/50-appearance.org` | Make the Corfu formatter choice explicit; add optional branding while retaining Sonokai and visible state. |
| `literate/55-dashboard.org` | `:3 UwUmacs` banner/title and live-help button, preserving centering and text fallback. |
| `literate/60-programming.org` | Move its leader contributions into owned descriptors; preserve grammar pins and opt-in servers. |
| `literate/70-org.org` | Keep paths/templates; add adapter selection without migrating user content. |
| `lambda-library/lambda-setup/` | Keep vendor files unchanged during initial implementation. Bridge useful commands, not whole mutable keymaps. |
| `tests/verify-config.el` | Assert core and selected adapters instead of the retiring hint feature. |
| `tests/key-hints-*.el` | Preserve as baseline evidence, then replace translation-specific cases with native-lookup and discovery cases. |
| `literate/index.org`, `keybindings.org` | Link architecture, live help and the key migration table. |

Current source findings requiring explicit tickets, each re-verified in [the alignment review](../../ADRs/alignment-review.md): `SPC l` has two writers with the LSP submenu taking precedence (F6); both kind-icon and nerd-icons-corfu add formatters, the kind-icon writer living in the vendored `lambda-setup` tree so the duplicate must be resolved at runtime (F5); `embark-consult` is **not declared anywhere** — it is only assumed to install transitively by a comment in `10-bootstrap.org`, and it is absent from `var/elpa` (F4); native project prefixes must not be imported blindly, the two unreachable modified keys being `C-x` (giving `C-x s`) and `C-b` (F7). These are planning findings, not claims of completed fixes.

## 10. Verification and release gates

Decision records: [ADR-0008](../../ADRs/0008-compatibility-floor.md), [ADR-0015](../../ADRs/0015-verification-and-recovery.md), [ADR-0016](../../ADRs/0016-standalone-release.md).

Milestone 1 requires ordinary startup plus real GUI key execution and rendered menu/annotation checks. Test a buffer pair with different localleaders, Insert and Motion states, disabling/re-enabling, prefix arguments, command remapping, recording/replay, callback load order and missing packages.

Meow keypad has special selection/grab/Beacon behavior. Literal maps do not promise automatic equivalence. A fixture suite must explicitly establish which actions retain the same semantics. Keep Beacon unchanged initially and label any documented differences before migration.

Milestone 2 is complete only when every scheduled catalogue ticket has passed its stated acceptance check or has a documented capability limitation accepted for the current host. A skip due to a missing external executable is not a passed execution test. Integration registration must not be called complete merely because a package downloaded.

Milestone 3 validates loading the reusable core without Lambda, starts a minimal example with selected adapters only, proves core unload/disable behavior and documents the supported version matrix. Keep Windows GUI, Windows daemon/terminal and Linux smoke runs distinct. Do not inherit the sibling dev-ci checkout's CI claims as evidence for this branch.

## 11. Research basis

Decision records: [ADR-0002](../../ADRs/0002-meow-interaction-layer.md), [ADR-0003](../../ADRs/0003-native-literal-dispatch.md), [ADR-0004](../../ADRs/0004-owned-state-layer.md), [ADR-0007](../../ADRs/0007-discovery-from-effective-maps.md).

The architecture is a synthesis of documented mechanisms, not a claim of universal community consensus.

- [GNU Emacs: active keymaps](https://www.gnu.org/software/emacs/manual/html_node/elisp/Active-Keymaps.html): native precedence, emulation maps and temporary overriding maps.
- [Meow customizations](https://github.com/meow-edit/meow/blob/master/CUSTOMIZATIONS.org): state keymaps and mode/state policy.
- [Meow design rationale](https://github.com/meow-edit/meow/blob/master/EXPLANATION.org): native-binding reuse versus the maintenance of an additional hierarchy.
- [Evil Collection](https://github.com/emacs-evil/evil-collection): independently selected package integrations and coherent conventions.
- [Evil keymaps](https://evil.readthedocs.io/en/latest/keymaps.html): state-scoped mappings and leader abstractions.
- [Doom framework](https://github.com/doomemacs/core): separation of framework/leader conventions from editing emulation.
- [Helheim](https://github.com/helheim-emacs/helheim): modular host configuration; its current leader uses translation.
- [Which-key](https://github.com/justbur/emacs-which-key): keymap-driven discovery.
- [General with Meow](https://github.com/noctuid/general.el/issues/546): keymap convenience is optional; it does not replace the state/lifecycle design.
