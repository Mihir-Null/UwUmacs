# Firemacs adaptation map

## Boundary

Firemacs is a terminal-first Evil configuration.  This branch preserves its
information architecture and feedback loop while changing the substrate to
Meow, Lambda, Emacs 30 built-ins, and graphical native Windows support.

The upstream Firemacs repository does not currently declare a license.  This
branch therefore ports concepts and behavior, not its implementation text.

| Firemacs concept | This branch | Reason |
|---|---|---|
| Evil normal/visual grammar | Meow normal/motion/insert/beacon | Selection-first editing is the primary interaction model. |
| Hand-built grouped MRU header line | Built-in `tab-line-tabs-buffer-groups` over MRU `buffer-list` | Per-window, mouse-aware, maintained in Emacs 30, and compatible with Windows GUI. |
| Tab header as the only grouping layer | Buffer `tab-line` below Lambda `tab-bar`/tabspaces | Buffers and project workspaces remain distinct concepts. |
| Permanent status-column jump letters | Meow expansion hints + Avy jump map + line/Diff-HL rail | Keeps Meow's `f` and `;` semantics and avoids continuous redisplay work. |
| Evil-specific animated scroll advice | Pixel interpolation + Ultra Scroll | Works with Meow commands and native graphical input. |
| OSC cursor shape/color | Meow cursor types and faces | Native GUI frames, including Windows, do not need terminal escape sequences. |
| Wayland clipboard bridge | Emacs system clipboard | Portable across Windows, macOS, and graphical Linux. |
| Custom mode line | Doom Modeline's maintained Meow integration | Shows modal state, project, file, VCS, position, and diagnostics without Evil assumptions. |
| Firebat palette | Doom Dark+ with configurable orange accent | Retains the user's preferred base theme while preserving Firemacs' visual identity. |
| Which-key | which-key + posframe fallback | Tooltip-like graphical discovery with ordinary side-window behavior in terminals. |

## Module ownership

```text
config.el
├── starter-platform.el              OS paths, shells, Explorer/Finder reveal
├── starter-setup-motion.el          scrolling and destination feedback
├── starter-setup-meow.el            selection grammar and semantic leader
├── starter-setup-ui.el              frames, theme, modeline, rail, icons
├── starter-setup-tabs.el            grouped MRU buffer strip
├── starter-setup-discoverability.el help, posframes, Casual, keycast
└── starter-setup-org.el             minimal portable Org policy
```

## Windows policy

- Frame decorations stay enabled; no module requests fullscreen or recenters a
  frame. FancyWM remains responsible for tiling and sizing.
- `pwsh.exe`, `powershell.exe`, then `cmd.exe` are discovered in that order.
- Explorer reveal replaces Lambda's macOS-only Finder binding at `SPC b f`.
- Clipboard integration is Meow + Emacs' native interprogram clipboard.
- Child frames are enabled only when `display-graphic-p`; terminal sessions keep
  normal which-key and Eldoc buffers.
- Nerd Font icons are conditional. Missing fonts produce text labels rather
  than tofu glyphs.
- Ultra Scroll is an enhancement. Built-in pixel scrolling remains the keyboard
  animation backend, and terminal commands fall back to line scrolling.

## Meow constraints

The branch does not redefine plain `f`, `;`, `s`, movement keys, thing keys, or
selection verbs to imitate Vim.  Firemacs-like commands use modified keys or the
semantic leader.  This keeps `meow-tutor` and upstream Meow documentation useful.

Application-like modes use Meow motion state so Dired, Help, Info, Compilation,
and Magit retain their native mode maps. Shell/terminal modes begin in insert
state.

## Verification targets

1. Every `.el` file parses with balanced delimiters under Emacs 30.
2. Startup never loads `lem-setup-frames`.
3. A Windows GUI frame reports `fullscreen=nil` and `undecorated=nil`.
4. Meow normal state exposes both selection commands and the `SPC` semantic map.
5. `C-TAB` cycles the current buffer group; `SPC {`/`SPC }` cycles workspaces.
6. Posframe/Eldoc child-frame features degrade to built-in help in terminals.
7. Missing Nerd Fonts and missing external executables do not block startup.
