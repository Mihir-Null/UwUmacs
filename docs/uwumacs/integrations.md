# UwUmacs enabled integration catalogue

This is an ordered work queue, not a list of completed integrations. The user requested enabled configurations first; inventory-only packages at the end have **no scheduled integration work**.

The census came from an ordinary graphical Emacs 31.1 startup on 2026-09-13. Lazy-loaded, configured commands remain in scope. A false `observed_loaded` value in [the JSON evidence](package-inventory.json) does not mean disabled. Installed packages alone are not evidence of use. No private source, file contents, history or account values were exported.

Read [the architecture](../superpowers/specs/2026-09-13-uwumacs-design.md) and [implementation plan](../superpowers/plans/2026-09-13-uwumacs.md) first. Each row is an individual review ticket; adjacent rows can share the named adapter file. Supporting libraries receive explicit compatibility work, not artificial menus.

## Execution rules

1. Follow the numbered order within each wave. Provision the wave's existing dependencies before its first test; dependency tickets describe compatibility review order, not the package manager's installation order.
2. Resolve the API of the installed target version before binding an action. Tests use temporary buffers/files, repositories, process data and Org stores. Never use the real notes vault or working projects as test fixtures.
3. Add one focused ERT case named `uwumacs-<package>-<behavior>` for the acceptance outcome. A package without a public feature of the same name is tested through its owning package/command (not forced `require`).
4. Run the failing case; implement in the wave's adapter; rerun that case and the wave suite. Run graphical checks when popup, frame or state interaction changes. Commit only the completed ticket or small coherent adjacent set after review.
5. Gates for an optional external executable must distinguish unavailable capability from a passing execution test. No remote connection, server launch, installation or package upgrade occurs just by enabling UwUmacs.

## Package availability findings

- `embark-consult` is declared with demand-after-Embark/Consult but its library is unavailable. Its ticket repairs that enabled configuration gap; it is not counted as currently loaded or working.
- `diff-hl` and `vdiff-magit` are guarded out because their libraries are unavailable; neither is scheduled.
- `nix-mode`, `racket-mode`, `geiser`, and `geiser-guile` require explicit language opt-ins, currently empty; none is scheduled.
- `consult-flymake` and `emacs-lisp-mode` include command/mode surfaces rather than independently acquired packages. `emacs` is the use-package pseudo-package.
- Provisioned-only and install-only entries, including unrelated writing, notes, LSP and macOS packages, are recorded separately without activation or removal.

## Wave 1A: Engine, native input and support libraries

Agent-selected contracts and rationale: [decision record](../ADRs/0019-wave-1a-core.md).
Adapter: `lambda-library/lambda-user/uwumacs-integration-core.el`. Tests: `tests/uwumacs-core-tests.el`. The core/discovery waves may delegate to the core files defined by the architecture.
| Order | Package / surface | Integration contract | Acceptance check |
|---|---|---|---|
| I001 | `meow` | Keep existing normal grammar; enable literal SPC only in Normal/Motion; expose keypad as an optional command | Selection, numeric arguments, Escape and Beacon fixtures match the documented state policy |
| I002 | `emacs` | Keep native command-loop dispatch and command remapping | A leader-bound remapped command invokes its effective command once |
| I003 | `simple` | Keep ordinary text entry, region and cancellation behavior | Insert-state spaces and C-g in a prompt work without a leader interception |
| I004 | `files` | SPC f f invokes find-file; keep native C-x C-f | Open a temporary file through both keys and compare the selected buffer |
| I005 | `use-package` | Keep package acquisition in the composition root, outside UwUmacs | Loading the core does not call package-install or refresh archives |
| I006 | `bind-key` | Bridge existing Lambda declarations during migration; use native UwUmacs maps | Loading Lambda keybindings before or after the bridge does not duplicate leader maps |
| I007 | `cl-lib` | Support core data validation and test helpers; no menu | Core byte-compiles with explicit cl-lib require |
| I008 | `cl` | Retain legacy vendor dependency only; no new UwUmacs imports | A source scan finds no new require of obsolete cl in UwUmacs files |
| I009 | `subr-x` | Support string and conditional helpers; no menu | Core loads on the minimum supported Emacs with explicit requires |
| I010 | `compat` | Honor package dependency requirements; no menu | Core and the first adapter load with the provisioned compat implementation |
| I011 | `seq` | Support map filtering and registry validation; no menu | Dependency resolution includes seq without attempting a redundant package installation |
| I012 | `async` | Preserve Dired asynchronous operations | A temporary directory operation completes without changing the initiating buffer state |
| I013 | `dash` | Preserve dependencies of current utilities; no menu | Help and file adapters load with dash provisioned and do not add global bindings |
| I014 | `s` | Preserve string helper dependency; no menu | Help adapter byte-compilation resolves s functions |
| I015 | `f` | Preserve file helper dependency; no menu | File adapter initialization adds no filesystem actions |
| I016 | `anaphora` | Retain Lambda macro support in the bridge | The bridge loads before and after vendor macros without expansion errors |
| I017 | `let-alist` | Preserve the built-in dependency used by configured packages; no menu | Dependent adapters load without package acquisition or new bindings |
| I018 | `parent-mode` | Preserve derived-mode lookup used by configured packages; no menu | A derived-mode fixture selects the intended adapter once |
| I019 | `spinner` | Preserve package activity indicators; no menu | An indicator starts and stops without taking input or leaving a timer after cleanup |

## Wave 1B: Discovery, home page and frame policy

Agent-selected contracts and rationale: [decision record](../ADRs/0020-wave-1b-discovery.md).
Adapter: `lambda-library/lambda-user/uwumacs-integration-discovery.el`. Tests: `tests/uwumacs-discovery-tests.el`. The core/discovery waves may delegate to the core files defined by the architecture.
| Order | Package / surface | Integration contract | Acceptance check |
|---|---|---|---|
| I020 | `which-key` | Show actual prefix maps with readable group names; no keypad popup advice | Rendered SPC f lists the same reachable commands as describe-key |
| I021 | `dashboard` | SPC h opens home; SPC H opens live binding help; show :3 UwUmacs | Home buttons and H help work in Motion; logo remains legible in GUI and terminal |
| I022 | `frames-only-mode` | Keep OS-managed editing frames and attached completion | A leader split command creates a frame; quitting Help closes only the intended frame |
| I023 | `frame` | Keep frame creation, focus and deletion explicit in the w menu | Two-frame fixture retains buffers and never deletes the last frame through a generic quit |
| I024 | `window` | Use display-buffer and native remapping for display policy | Help display and return focus work with frame policy enabled and disabled |
| I025 | `popper` | Keep popup selection/history while frame policy owns placement | Toggle a popup without a competing split or stolen completion frame |

## Wave 2A: Completion and candidate actions

Agent-selected contracts and rationale: [decision record](../ADRs/0021-wave-2a-completion.md).
Adapter: `lambda-library/lambda-user/uwumacs-integration-completion.el`. Tests: `tests/uwumacs-completion-tests.el`. The core/discovery waves may delegate to the core files defined by the architecture.
| Order | Package / surface | Integration contract | Acceptance check |
|---|---|---|---|
| I026 | `vertico` | Keep minibuffer text entry; navigate candidates with C-n/C-p and arrows | Typing spaces filters candidates and never opens the global leader |
| I027 | `vertico-buffer` | Keep the configured completion presentation subject to frame policy | Rendered candidates stay attached to their initiating frame |
| I028 | `vertico-directory` | Preserve directory entry, deletion and tidy behavior | Enter and back out of a temporary directory without losing the prompt |
| I029 | `vertico-repeat` | Use SPC s l for completion history; retain the effective LSP owner of SPC l | Repeat a completed search and verify SPC l remains a prefix |
| I030 | `orderless` | Preserve orderless matching and file-category partial completion | Two out-of-order query components match the expected candidate |
| I031 | `consult` | Retain SPC s s line search and SPC b b buffer selection; preserve preview and narrowing | Search previews restore origin on abort; advertised command invokes the chosen candidate |
| I032 | `consult-dir` | Add SPC f D for directory switching within supported completion | Switch candidate directory without leaving stale minibuffer state |
| I033 | `marginalia` | Prefer reachable UwUmacs bindings in the original editing buffer | M-x shows exact SPC s s in Normal and a valid modified shortcut in Insert |
| I034 | `embark` | Preserve candidate-specific action maps and their own help | Invoke an action on a temporary file candidate without treating its keys as global leader keys |
| I035 | `embark-consult` | Repair the declared-but-missing integration through explicit package policy during this ticket | Embark collection previews work after both packages load; startup with either absent stays clear and non-installing |
| I036 | `corfu` | Keep completion navigation, acceptance and abort; honor Meow Insert exit | Accept one candidate, then leave Insert and confirm the popup closes |
| I037 | `cape` | Expose explicit completion providers through SPC c p and existing completion-at-point | File and dabbrev providers run without replacing the entire CAPF list |
| I038 | `dabbrev` | Keep dynamic abbreviation as a completion provider | Expand from a local fixture and preserve undo behavior |
| I039 | `yasnippet` | SPC i becomes an insert group; SPC i s inserts a snippet; relocate the old config shortcut to SPC C i | TAB advances snippet fields while leader maps stay inactive in Insert |
| I040 | `kind-icon` | Choose one Corfu formatter via UwUmacs appearance policy; retain this as selectable alternative | Switch icon provider twice and verify there is exactly one owned formatter |
| I041 | `nerd-icons-corfu` | Default to the existing Nerd Icons visual family when available | Exactly one completion icon column appears with a text fallback when the font is unavailable |

## Wave 2B: Help and documentation

Agent-selected contracts and rationale: [decision record](../ADRs/0022-wave-2b-help.md).
Adapter: `lambda-library/lambda-user/uwumacs-integration-help.el`. Tests: `tests/uwumacs-help-tests.el`. The core/discovery waves may delegate to the core files defined by the architecture.
| Order | Package / surface | Integration contract | Acceptance check |
|---|---|---|---|
| I042 | `help` | Keep C-h and add live UwUmacs command/keymap inspection | Describe a leader sequence and verify it reports its effective command |
| I043 | `help-at-pt` | Preserve help-at-point feedback | Hover/keyboard help does not activate an integration map in the minibuffer |
| I044 | `helpful` | Provide contextual help with consistent Motion navigation and q | Open help from a source buffer and return to the correct frame |
| I045 | `elisp-demos` | Retain examples inside Helpful | An example is present without a duplicate help section after reload |
| I046 | `elisp-refs` | Support Helpful reference navigation; no duplicate global menu | Follow a reference and return through the xref stack |
| I047 | `info` | Keep Info navigation plus Motion j/k and a mode-specific localleader | Move between nodes, follow a link and return without shadowing essential Info commands |
| I048 | `info-colors` | Keep Info fontification; no new keys | Fontification survives state switches and theme changes |

## Wave 2C: File management

Agent-selected contracts and rationale: [decision record](../ADRs/0023-wave-2c-dired.md).
Adapter: `lambda-library/lambda-user/uwumacs-integration-dired.el`. Tests: `tests/uwumacs-dired-tests.el`. The core/discovery waves may delegate to the core files defined by the architecture.
| Order | Package / surface | Integration contract | Acceptance check |
|---|---|---|---|
| I049 | `dired` | SPC d opens Dired; Motion navigation and SPC m provide file operations | Mark, copy and rename only fixture files; q restores the origin |
| I050 | `wdired` | Use package-supported entry/finish/abort commands and Meow's existing shim | Edit names in Normal/Insert; finish and abort both return to Dired Motion |
| I051 | `dired-narrow` | Expose narrowing under the Dired localleader | Filter then clear a directory listing without altering marks |
| I052 | `dired-ranger` | Expose copy/paste operations under Dired localleader | Copy a marked temporary file to another fixture directory |
| I053 | `dired-hacks-utils` | Keep shared Dired dependency; no menu | Dired extensions load without duplicate hooks |
| I054 | `diredfl` | Preserve faces without changing navigation | Marked and executable fixture files retain their distinct faces |
| I055 | `peep-dired` | Make preview explicit and frame-aware | Preview a file, move selection and exit without an orphan preview frame |
| I056 | `dired-sidebar` | Keep sidebar invocation explicit; define its exception to frames-only placement | Open and close the sidebar without creating repeated splits or changing global frame policy |
| I057 | `nerd-icons-dired` | Keep optional icon presentation | Directory rows remain aligned with and without the Nerd Font |

## Wave 2D: Version control and temporary interfaces

Agent-selected contracts and rationale: [decision record](../ADRs/0024-wave-2d-vc.md).
Adapter: `lambda-library/lambda-user/uwumacs-integration-vc.el`. Tests: `tests/uwumacs-vc-tests.el`. The core/discovery waves may delegate to the core files defined by the architecture.
| Order | Package / surface | Integration contract | Acceptance check |
|---|---|---|---|
| I058 | `transient` | Give temporary maps control while a transient is active; use existing Magit menus | Transient suffix keys, help and quit win over UwUmacs maps |
| I059 | `magit-section` | Navigate sections with section-aware commands | j/k and fold operations act on sections rather than arbitrary text lines |
| I060 | `with-editor` | Preserve commit message entry and finish/cancel protocol | Finish and cancel editing in a disposable repository without losing the initiating session |
| I061 | `cond-let` | Preserve Magit dependency; no menu | Magit adapter compiles using the installed dependency API |
| I062 | `llama` | Preserve Magit dependency; no menu | Load Magit without adding a UwUmacs global binding for this library |
| I063 | `magit` | Keep SPC v entry points; use Motion in status/log and editing states in commit buffers | Stage and unstage a fixture; open a commit editor then cancel; q respects frame ownership |
| I064 | `git-commit` | Keep commit editing and checks separate from status navigation | A commit message accepts ordinary typing, completion and finish/cancel keys |
| I065 | `vc` | Keep native VC commands in the version-control menu | Open a diff for a disposable modified file |
| I066 | `vc-git` | Retain the selected Git backend | The fixture is detected as Git and status refresh completes |
| I067 | `vc-annotate` | Add localleader navigation for annotation buffers | Visit a revision and return without losing the original buffer |
| I068 | `diff-mode` | Expose hunk navigation and application as explicit local actions | Navigate a fixture diff and reverse a change only in its temporary target |
| I069 | `smerge-mode` | Group choose-upper/lower/both actions under a merge localleader subgroup | Resolve each choice in separate conflict fixtures and preserve undo |
| I070 | `ediff` | Keep Ediff's control interface and frame policy explicit | Compare temporary files and quit with all temporary control frames cleaned up |
| I071 | `wgrep` | Reuse supported edit/finish/abort entry points and Meow shim | Edit a search result fixture and test both commit and abort |
| I072 | `flyspell` | Honor the current git-commit hook; gate missing spelling executables | Commit text remains editable when no spelling executable exists |

## Wave 2E: Projects, buffers, search and workspaces

Agent-selected contracts and rationale: [decision record](../ADRs/0025-wave-2e-navigation.md).
Adapter: `lambda-library/lambda-user/uwumacs-integration-navigation.el`. Tests: `tests/uwumacs-navigation-tests.el`. The core/discovery waves may delegate to the core files defined by the architecture.
| Order | Package / surface | Integration contract | Acceptance check |
|---|---|---|---|
| I073 | `project` | Own a literal project submenu; bind commands directly rather than sharing project-prefix-map | SPC p f opens the intended fixture file even if native project C-f bindings change |
| I074 | `bookmark` | Retain bookmark creation/jump under the file menu | Create, jump to and delete a temporary bookmark without touching the user's bookmark file |
| I075 | `recentf` | Keep recent-file access through Consult and dashboard | Fixture entries display without rewriting the user's recentf store |
| I076 | `ibuffer` | Expose buffer-list actions in a Motion adapter | Mark and delete only temporary buffers, then return to origin |
| I077 | `revert-buffer-all` | Keep explicit reload-all action with existing confirmation semantics | Only fixture buffers are reverted and modified-buffer handling is preserved |
| I078 | `tab-bar` | Keep W workspace menu and next/previous workspace shortcuts | Switch tabs in two frames and preserve the documented frame-local behavior |
| I079 | `tabspaces` | Keep project/buffer filtering without replacing workspace architecture | Two project fixtures show their own buffer sets after switching |
| I080 | `ace-window` | Keep explicit window selection and define scope when frames-only is enabled | Selection can be cancelled and never deletes a frame implicitly |
| I081 | `avy` | Retain candidate-label selection used by ace-window; no extra global movement grammar | Candidate labels receive literal input and cancellation returns to the preceding state |
| I082 | `windmove` | Keep directional navigation scoped to available Emacs windows | A one-window frame reports no neighbor without creating a split |
| I083 | `winner` | Keep layout undo within its supported window scope | Restore a fixture layout; document that it does not undo OS window-manager placement |
| I084 | `imenu-list` | Provide explicit outline display and frame-policy exception | Open, follow a symbol and close the outline without an orphan display |
| I085 | `goto-last-change` | Retain change navigation in the search/navigation menu | Jump between two fixture edits without modifying text |
| I086 | `goto-addr` | Preserve address recognition; no forced global key | Address activation remains available in compilation and text buffers |
| I087 | `xref` | Use existing definition/reference commands in the LSP menu with a back action | Definition jump and back restore point and origin frame |
| I088 | `deadgrep` | Expose a project search command and a Motion results adapter | Search a temporary project, open a match and return; skip with a clear message when rg is absent |
| I089 | `rg` | Keep its existing configurable search interface | Repeat a fixture search through its own transient without key precedence conflicts |
| I090 | `visual-regexp` | Retain visual query replacement | Preview, accept and abort replacements in separate temporary buffers |
| I091 | `visual-regexp-steroids` | Keep its alternate regexp engine as an explicit action | Report missing external engine without changing text; run fixture when available |
| I092 | `isearch` | Allow the search map to own typing and search repetition | Space and repeated search keys work without entering the leader |
| I093 | `replace` | Preserve y/n/!/q query-replace interaction | Replace selected fixture matches and abort safely |
| I094 | `register` | Keep Consult register access and native register semantics | Store and restore a fixture point without modifying unrelated registers |

## Wave 2F: Org workflows

Agent-selected contracts and rationale: [decision record](../ADRs/0026-wave-2f-org.md).
Adapter: `lambda-library/lambda-user/uwumacs-integration-org.el`. Tests: `tests/uwumacs-org-tests.el`. The core/discovery waves may delegate to the core files defined by the architecture.
| Order | Package / surface | Integration contract | Acceptance check |
|---|---|---|---|
| I095 | `org` | Own a mode-specific localleader while retaining Meow editing | Heading movement, TODO change, visibility cycling and editing work in one fixture |
| I096 | `org-agenda` | Use Motion with agenda-specific navigation and actions | Open an agenda from a temporary org-directory and visit a source heading |
| I097 | `org-capture` | Keep task/note templates; give capture finish/cancel priority | Capture and abort write only to a temporary inbox, never the independent notes vault |
| I098 | `org-id` | Preserve ID creation and links | Create an ID in a fixture and resolve its link using a temporary ID database |
| I099 | `org-refile` | Expose refile under Org localleader | Move a fixture subtree and preserve its content and ID |
| I100 | `org-inlinetask` | Keep inline task insertion explicit | Insert and edit an inline task without corrupting surrounding headings |
| I101 | `org-contrib` | Audit only contributed features actually enabled by the Org module | Org starts with org-contrib installed; no blanket enabling of contributed modes |
| I102 | `ox` | Use Org's export dispatch rather than a replacement export UI | Export a temporary document and close the dispatch cleanly |

## Wave 2G: Structural editing and programming

Agent-selected contracts and rationale: [decision record](../ADRs/0027-wave-2g-programming.md).
Adapter: `lambda-library/lambda-user/uwumacs-integration-programming.el`. Tests: `tests/uwumacs-programming-tests.el`. The core/discovery waves may delegate to the core files defined by the architecture.
| Order | Package / surface | Integration contract | Acceptance check |
|---|---|---|---|
| I103 | `eglot` | Keep SPC l as code-intelligence menu; retain explicit server startup | Without a server, menu is usable and startup launches none; use a fixture server for rename/format validation |
| I104 | `eldoc` | Keep documentation popup access and state-neutral feedback | Open documentation, follow help and return without clearing an unrelated selection |
| I105 | `flymake` | Keep diagnostics under F and LSP integration | Navigate fixture diagnostics and preserve buffer state |
| I106 | `consult-flymake` | Treat as a Consult-provided command surface, not a separately installable package | The F c command resolves to Consult's diagnostic selector |
| I107 | `flymake-collection` | Retain selected backend hooks and capability checks | Missing external linters do not prevent startup; enabled fixture backend reports diagnostics |
| I108 | `emacs-lisp-mode` | Provide eval, check and test actions under localleader | Evaluate a harmless form and run an ERT fixture without losing the source buffer |
| I109 | `lisp-mode` | Preserve Lisp syntax and structural editing conventions | Indent and evaluate a fixture using only an available configured Lisp environment |
| I110 | `sh-script` | Retain shell-script editing and syntax-specific local actions | Open a shell fixture and preserve literal input, indentation and comments |
| I111 | `prog-mode` | Use shared programming localleader defaults inherited by derived modes | Two derived modes inherit defaults while one local override stays buffer-specific |
| I112 | `treesit` | Keep pinned grammar policy and availability-gated remaps | A missing grammar retains the working fallback major mode |
| I113 | `puni` | Integrate structural editing with selection and minibuffer exceptions | Wrap, delete and undo nested forms; ordinary completion typing remains intact |
| I114 | `embrace` | Expose wrapping as an explicit editing action | Wrap an active fixture region once and undo once |
| I115 | `iedit` | Keep its own edit session and exit semantics | Edit two occurrences and exit without leaving stale overlays or state flags |
| I116 | `expand-region` | Keep explicit expansion alongside Meow selection | Expand and contract a fixture region without corrupting Meow's next selection |
| I117 | `elec-pair` | Preserve automatic pair insertion in Insert | Typing a delimiter inserts the expected pair exactly once |
| I118 | `paren` | Preserve pair highlighting; no new keys | Matching delimiters remain highlighted after mode changes |
| I119 | `aggressive-indent` | Retain currently configured mode hooks | A structural fixture is indented once and undo remains coherent |
| I120 | `rainbow-delimiters` | Keep optional delimiter coloring | Nested fixture delimiters retain faces without taking navigation keys |
| I121 | `rainbow-identifiers` | Keep optional identifier coloring | Toggle it without changing text or completion bindings |
| I122 | `highlight-indent-guides` | Keep indentation guides in supported buffers | Guides do not alter line movement or overlay precedence |
| I123 | `elisp-def` | Keep the explicit Elisp definition helper | Navigate a fixture definition and return through the documented path |
| I124 | `package-lint` | Add a development action for linting UwUmacs libraries | Lint a fixture library and show results with usable navigation |
| I125 | `multi-compile` | Retain the configured command selector | Choose a harmless fixture command and navigate its output |
| I126 | `compile` | Keep compilation start/recompile/error navigation | Run a harmless fixture command and jump to a simulated error |
| I127 | `kmacro` | Preserve native recording and execution through the command loop | Record and replay a literal leader action without duplicate execution |
| I128 | `repeat` | Allow repeat maps to own their temporary keys | Repeat a supported fixture action and exit without a stuck leader state |

## Wave 2H: Shells, terminals and processes

Agent-selected contracts and rationale: [decision record](../ADRs/0028-wave-2h-terminal.md).
Adapter: `lambda-library/lambda-user/uwumacs-integration-terminal.el`. Tests: `tests/uwumacs-terminal-tests.el`. The core/discovery waves may delegate to the core files defined by the architecture.
| Order | Package / surface | Integration contract | Acceptance check |
|---|---|---|---|
| I129 | `eat` | Keep PowerShell default and explicit MSYS2 entry; preserve Meow's EAT shims | Normal/Insert transitions and subprocess input work; terminal spaces never launch a leader |
| I130 | `eshell` | Use Insert for the prompt and Motion/Normal only when explicitly requested | Run a harmless command, navigate history and return to editing the prompt |
| I131 | `esh-mode` | Preserve Eshell prompt editing boundaries | A localleader action does not edit read-only prompt text |
| I132 | `em-alias` | Retain aliases in the user's existing storage policy | A temporary alias expands in a fixture Eshell |
| I133 | `em-banner` | Preserve the configured banner without rebranding subprocess output | A new Eshell has one banner |
| I134 | `em-cmpl` | Preserve Eshell completion behavior | Complete a fixture command/path and cancel cleanly |
| I135 | `em-dirs` | Keep directory navigation and stack commands | Push and pop temporary directories without changing unrelated buffers |
| I136 | `em-glob` | Keep shell glob expansion | A glob matches only the fixture files |
| I137 | `em-hist` | Keep command history and search | Recall a harmless command from a temporary history file |
| I138 | `em-ls` | Keep listing output and link actions | List a temporary directory and visit a fixture entry |
| I139 | `em-prompt` | Preserve prompt recognition and point motion | Prompt navigation lands at the editable command position |
| I140 | `em-term` | Retain visual-command handoff | A supported fixture command returns to Eshell without stale state |
| I141 | `pcmpl-args` | Keep command argument completion | Completion handles an available command and missing executables gracefully |
| I142 | `pcmpl-homebrew` | Gate Homebrew-specific completion to hosts with brew | Windows startup and Eshell perform no Homebrew invocation |
| I143 | `pcomplete-extension` | Keep extension completion handlers | A fixture handler completes without replacing the whole completion stack |
| I144 | `esh-help` | Keep command-help access in Eshell | Help opens and closes while preserving the pending command line |
| I145 | `eshell-up` | Expose directory-up explicitly | Move upward from a temporary nested path and preserve prompt state |
| I146 | `eshell-syntax-highlighting` | Preserve prompt highlighting | Highlighting updates without changing key ownership |
| I147 | `shell` | Keep native shell/comint interaction and PowerShell policy | Send a harmless command and interrupt without a leader interception |
| I148 | `comint` | Respect process input, history and completion maps | Spaces, C-c C-c and history work in a fixture process buffer |
| I149 | `term` | Keep terminal character-mode maps authoritative | A fixture terminal receives literal input and can exit to navigation state |
| I150 | `exec-path-from-shell` | Preserve platform gating; keep native Windows environment policy | Windows startup does not spawn a login shell merely to activate UwUmacs |
| I151 | `tramp` | Preserve remote filename handling; do not start connections during activation | Parsing a remote filename causes no connection until an explicit file operation |
| I152 | `server` | Keep existing server naming and explicit daemon lifecycle | UwUmacs activation does not start or stop an Emacs server |

## Wave 2I: Appearance and visual feedback

Agent-selected contracts and rationale: [decision record](../ADRs/0029-wave-2i-appearance.md).
Adapter: `lambda-library/lambda-user/uwumacs-integration-appearance.el`. Tests: `tests/uwumacs-appearance-tests.el`. The core/discovery waves may delegate to the core files defined by the architecture.
| Order | Package / surface | Integration contract | Acceptance check |
|---|---|---|---|
| I153 | `doom-modeline` | Add :3 branding while retaining N/I/M state and useful status | The state indicator stays visible in narrow and wide frames |
| I154 | `doom-themes` | Keep current theme package and tracked Sonokai port | Dark/light toggles leave exactly one active theme |
| I155 | `lambda-themes` | Keep the vendor theme lifecycle in the compatibility layer | Theme hooks run once after reload and preserve the personal theme choice |
| I156 | `nerd-icons` | Keep optional font-based icons with text fallbacks | No missing-glyph box is required for the :3 logo or command help |
| I157 | `nerd-icons-completion` | Retain candidate icons independently of key annotations | M-x shows one icon and one accurate key annotation |
| I158 | `spacious-padding` | Retain existing spacing policy | Menu and dashboard geometry remain usable after toggling padding |
| I159 | `svg-lib` | Preserve visual dependency and cache policy; no menu | Missing SVG support falls back without failing startup |
| I160 | `svg-tag-mode` | Keep availability-gated tags | A tagged fixture is readable on SVG and non-SVG builds |
| I161 | `shrink-path` | Preserve modeline path formatting; no menu | A long fixture path is shortened without changing its underlying filename |
| I162 | `dimmer` | Preserve inactive-buffer dimming | Focus changes do not dim an active completion interface incorrectly |
| I163 | `outline` | Keep folding commands available through localleader | Fold/unfold a fixture without hiding the current command menu |
| I164 | `outline-minor-faces` | Keep outline presentation only | Heading faces survive folds and state changes |
| I165 | `highlight-numbers` | Keep its explicit mode/toggle behavior | Numeric fixtures gain faces without new global keys |
| I166 | `hl-todo` | Keep highlighting and expose navigation only when enabled | Navigate TODO markers in a fixture without enabling unrelated note modules |
| I167 | `goggles` | Preserve edit feedback overlays | An edit and undo leave no permanent overlay |
| I168 | `pulse` | Keep momentary navigation feedback | A jump highlights briefly and returns to ordinary faces |
| I169 | `rainbow-mode` | Retain explicit color preview toggle | Color literals remain editable and no popup captures input |
| I170 | `reveal` | Preserve visibility behavior around hidden text | Entering hidden fixture text reveals it without changing leader maps |
| I171 | `font-lock` | Keep syntax highlighting independent of modal state | Fontification is unchanged after repeated state switches |
| I172 | `fontset` | Keep the existing font mapping policy | The ASCII logo works without installing fonts |
| I173 | `fringe` | Keep existing fringe settings and indicators | Diagnostics and selection fringes coexist in a narrow frame |

## Wave 2J: Persistence, input and remaining built-in configuration

Agent-selected contracts and rationale: [decision record](../ADRs/0030-wave-2j-runtime.md).
Adapter: `lambda-library/lambda-user/uwumacs-integration-runtime.el`. Tests: `tests/uwumacs-runtime-tests.el`. The core/discovery waves may delegate to the core files defined by the architecture.
| Order | Package / surface | Integration contract | Acceptance check |
|---|---|---|---|
| I174 | `autorevert` | Keep automatic refresh behavior | External fixture changes refresh without erasing a modified buffer |
| I175 | `desktop` | Keep desktop persistence opt-in | Loading UwUmacs does not enable desktop saving |
| I176 | `savehist` | Keep minibuffer history storage policy | Completion history survives a fixture save/load without private history leakage |
| I177 | `saveplace` | Keep saved cursor positions | Reopen a fixture at its saved position |
| I178 | `uniquify` | Keep buffer-name disambiguation | Two same-named fixture files remain distinguishable in menus |
| I179 | `multisession` | Keep existing persistence choices | Activating the layer creates no new machine-wide persistence store |
| I180 | `time-stamp` | Preserve configured timestamp behavior | Saving a matching fixture updates only its timestamp field |
| I181 | `ws-butler` | Keep save-time whitespace cleanup in configured modes | Saving a fixture cleans intended whitespace without modifying untouched lines unexpectedly |
| I182 | `subword` | Preserve word-boundary behavior | CamelCase fixture movement follows the existing subword setting |
| I183 | `so-long` | Keep long-line protection authoritative | A long-line fixture can suspend expensive integrations without startup failure |
| I184 | `display-line-numbers` | Keep the explicit line-number toggle | Toggle in two buffers without leaking state |
| I185 | `pixel-scroll` | Retain the effective configured scrolling behavior | Keyboard navigation and scrolling coexist on GUI and terminal |
| I186 | `mouse` | Preserve native mouse selection and links | Clicking a fixture link is not converted into a keyboard leader sequence |
| I187 | `mwheel` | Preserve wheel scrolling | Wheel events do not change Meow state |
| I188 | `xwidget` | Gate graphical embedded widgets by build capability | A build without xwidgets loads the layer successfully |
| I189 | `mule-cmds` | Preserve coding-system commands | A UTF-8 fixture round-trips without altered coding settings |
| I190 | `gnutls` | Keep transport policy with Emacs, outside UwUmacs | Core activation changes no TLS variables or network settings |
| I191 | `advice` | Use named, removable advice only at documented compatibility boundaries | Disable removes only UwUmacs-owned advice |
| I192 | `cus-edit` | Expose UwUmacs customization without replacing Customize | Changing leader keys through Customize recomposes maps once |
| I193 | `wid-edit` | Keep widget field typing and navigation | A Customize text field accepts spaces and ordinary text |
| I194 | `crux` | Retain useful file/buffer helper commands through the Lambda bridge | A rename helper operates only on a temporary file and updates its buffer |

## Inventory only: not scheduled

These entries are outside the initial enabled-configuration roadmap. Presence here is not a recommendation to enable or remove them.

| Package | Reason |
|---|---|
| `aio` | Installed, but no enabled declaration or active dependency established |
| `alert` | Installed, but no enabled declaration or active dependency established |
| `auctex` | Installed, but no enabled declaration or active dependency established |
| `bug-hunter` | Installed, but no enabled declaration or active dependency established |
| `bui` | Installed, but no enabled declaration or active dependency established |
| `cfrs` | Installed, but no enabled declaration or active dependency established |
| `citar` | Installed, but no enabled declaration or active dependency established |
| `citar-denote` | Installed, but no enabled declaration or active dependency established |
| `citeproc` | Installed, but no enabled declaration or active dependency established |
| `consult-flyspell` | Installed, but no enabled declaration or active dependency established |
| `consult-notes` | Installed, but no enabled declaration or active dependency established |
| `dap-mode` | Installed, but no enabled declaration or active dependency established |
| `define-word` | Installed, but no enabled declaration or active dependency established |
| `denote` | Installed, but no enabled declaration or active dependency established |
| `diff-hl` | Guarded declaration; target library is unavailable |
| `elfeed` | Installed, but no enabled declaration or active dependency established |
| `elfeed-tube` | Installed, but no enabled declaration or active dependency established |
| `esup` | Installed, but no enabled declaration or active dependency established |
| `flyspell-correct` | Installed, but no enabled declaration or active dependency established |
| `geiser` | Explicit language opt-in is empty on this host |
| `geiser-guile` | Explicit language opt-in is empty on this host |
| `gntp` | Installed, but no enabled declaration or active dependency established |
| `grab-mac-link` | Installed, but no enabled declaration or active dependency established |
| `hide-mode-line` | Installed, but no enabled declaration or active dependency established |
| `ht` | Installed, but no enabled declaration or active dependency established |
| `htmlize` | Installed, but no enabled declaration or active dependency established |
| `hydra` | Installed, but no enabled declaration or active dependency established |
| `lambda-line` | Installed, but no enabled declaration or active dependency established |
| `log4e` | Installed, but no enabled declaration or active dependency established |
| `lorem-ipsum` | Installed, but no enabled declaration or active dependency established |
| `lsp-docker` | Installed, but no enabled declaration or active dependency established |
| `lsp-mode` | Installed, but no enabled declaration or active dependency established |
| `lsp-treemacs` | Installed, but no enabled declaration or active dependency established |
| `lv` | Installed, but no enabled declaration or active dependency established |
| `markdown-mode` | Installed, but no enabled declaration or active dependency established |
| `markdown-toc` | Installed, but no enabled declaration or active dependency established |
| `nix-mode` | Explicit language opt-in is empty on this host |
| `ns-auto-titlebar` | Installed, but no enabled declaration or active dependency established |
| `org-appear` | Installed, but no enabled declaration or active dependency established |
| `org-autolist` | Installed, but no enabled declaration or active dependency established |
| `org-download` | Installed, but no enabled declaration or active dependency established |
| `org-mac-link` | Installed, but no enabled declaration or active dependency established |
| `org-modern` | Installed, but no enabled declaration or active dependency established |
| `org-pomodoro` | Installed, but no enabled declaration or active dependency established |
| `osx-dictionary` | Installed, but no enabled declaration or active dependency established |
| `osx-lib` | Installed, but no enabled declaration or active dependency established |
| `ox-hugo` | Installed, but no enabled declaration or active dependency established |
| `ox-pandoc` | Installed, but no enabled declaration or active dependency established |
| `page-break-lines` | Provisioned by a selected topic but no enabled declaration or active dependency established |
| `palimpsest` | Installed, but no enabled declaration or active dependency established |
| `parsebib` | Installed, but no enabled declaration or active dependency established |
| `pfuture` | Installed, but no enabled declaration or active dependency established |
| `posframe` | Installed, but no enabled declaration or active dependency established |
| `queue` | Installed, but no enabled declaration or active dependency established |
| `racket-mode` | Explicit language opt-in is empty on this host |
| `reveal-in-osx-finder` | Installed, but no enabled declaration or active dependency established |
| `string-inflection` | Installed, but no enabled declaration or active dependency established |
| `tomelr` | Installed, but no enabled declaration or active dependency established |
| `treemacs` | Installed, but no enabled declaration or active dependency established |
| `vdiff-magit` | Guarded declaration; target library is unavailable |
| `visual-fill-column` | Installed, but no enabled declaration or active dependency established |
| `writeroom-mode` | Installed, but no enabled declaration or active dependency established |
| `yaml` | Installed, but no enabled declaration or active dependency established |
