# Emacs-Dots — Firemacs × Meow branch

This branch is a Meow-first, cross-platform adaptation of the visual and
interaction ideas in [Firemacs](https://github.com/66-firebat/firemacs), built
as a user layer for [Lambda-Emacs](https://codeberg.org/Lambda-Emacs/lambda-emacs).

It is intentionally **not** an Evil port and does not copy Firemacs' unlicensed
source.  It recreates the useful architecture with maintained Emacs 30 APIs and
packages while keeping Lambda's modular framework.

## Layout

```text
Lambda tab-bar + tabspaces       project/workspace layer
Built-in grouped tab-line        per-window MRU buffer layer
Editing window                   line rail + Diff HL + smooth feedback
Doom Modeline                    Meow state + file/project/VCS/diagnostics
Which-key / Eldoc child frames   discoverability at point
```

## What this branch adds

- **Meow remains authoritative:** selection-first verbs and things are kept;
  Firemacs-inspired shortcuts only occupy unused modified keys.
- **Firemacs-style buffer strip:** grouped `Code`, `Docs`, `Config`, `Tools`,
  `Terminal`, and `Buffers` tabs using Emacs 30's built-in `tab-line`.
- **Motion and animation:** built-in interpolated keyboard scrolling, optional
  Ultra Scroll for high-resolution input, and Pulsar feedback after jumps.
- **Visible command discovery:** which-key in a GUI posframe, Eldoc child-frame
  hover/help, Helpful, Embark actions, Casual transient menus, native menus and
  tool bar, plus an opt-in Keycast log.
- **Firemacs presentation:** Doom Dark+, an orange accent layer, Meow-aware Doom
  Modeline, Nerd Icons, spacious padding, line numbers, and Diff HL.
- **Native Windows behavior:** decorated non-fullscreen frames, built-in
  clipboard, `pwsh.exe` preference, Explorer reveal support, and no dependency
  on OSC cursor control, Wayland clipboard utilities, or Unix shell scripts.

## Installation

The repository is configuration source, not a bootstrapper.  Lambda currently
requires Emacs 30.1 or later.

```text
<lambda-emacs>/
├── early-init.el
├── init.el
└── lambda-library/
    ├── lambda-setup/       # upstream Lambda
    └── lambda-user/        # copy/symlink this repository's user layer here
```

Launch examples:

```sh
emacs --init-directory="$HOME/.config/lambda-emacs"
```

```powershell
emacs --init-directory="$env:USERPROFILE\.config\lambda-emacs"
```

On first startup, `use-package` installs the enabled Elisp packages.  For icon
glyphs, run `M-x nerd-icons-install-fonts`; on Windows, install the downloaded
font files through Explorer and restart Emacs.

## Core interaction

```text
SPC             Lambda semantic leader + which-key
SPC SPC         M-x
SPC h .         documentation at point
SPC h f/v/k     function, variable, or key help
SPC j c/l/w     Avy character, line, or word jump
SPC .           Embark contextual actions
SPC m           native menu bar
C-d / C-u       animated half-page down/up (Meow normal state)
C-f             animated full page down (Meow normal state)
C-b             Consult buffer switcher (Meow normal state)
C-o / C-i       Meow mark-ring backward/forward
C-TAB           next grouped buffer tab
C-S-TAB         previous grouped buffer tab
S               project ripgrep (Meow normal state)
```

Run `M-x meow-tutor` first.  The non-modal Lambda prefix remains
`C-c C-SPC` as a recovery and learning path.

## Configuration switches

Copy `lambda-library/lambda-user/private.example.el` to `private.el` for local
overrides.  Common choices include:

```elisp
(setq starter-ui-theme 'doom-dark+
      starter-ui-accent "#ff5a36"
      starter-ui-icons 'auto
      starter-ui-enable-menu-bar t
      starter-ui-enable-tool-bar t
      starter-discoverability-posframes t
      starter-discoverability-eldoc-hover t
      starter-motion-enable-ultra-scroll t)
```

See [docs/FIREMACS-ADAPTATION.md](docs/FIREMACS-ADAPTATION.md) for the design
mapping and Windows fallbacks, and [docs/READING-ORDER.md](docs/READING-ORDER.md)
for the Lambda learning path.

The branch also runs a delimiter/parser check under Emacs 30.1 on both Linux
and Windows GitHub runners.

## Upstreams

- Lambda-Emacs: <https://codeberg.org/Lambda-Emacs/lambda-emacs>
- Meow: <https://github.com/meow-edit/meow>
- Firemacs design reference: <https://github.com/66-firebat/firemacs>
- Doom Modeline: <https://github.com/seagle0128/doom-modeline>
- Casual Suite: <https://github.com/kickingvegas/casual-suite>
- Ultra Scroll: <https://github.com/jdtsmith/ultra-scroll>
- Pulsar: <https://github.com/protesilaos/pulsar>

Keep user changes inside `lambda-library/lambda-user/` unless you intentionally
decide to maintain a Lambda framework fork.
