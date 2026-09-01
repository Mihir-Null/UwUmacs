# Emacs-Dots — Lambda-Emacs user layer

A small, inspectable configuration layer for [Lambda-Emacs](https://codeberg.org/Lambda-Emacs/lambda-emacs), using [Meow](https://github.com/meow-edit/meow) for selection-first modal editing and adapting the useful, portable parts of [Colin McLear's configuration](https://codeberg.org/mclear-tools/dotemacs).

This repository intentionally contains **configuration source, not an installer**. It is meant to be read first and then placed, copied, symlinked, or managed declaratively however makes sense on each machine.

## Intended placement

Lambda owns the framework:

```text
<lambda-emacs>/
├── early-init.el
├── init.el
└── lambda-library/
    ├── lambda-setup/       # upstream Lambda — leave unchanged while learning
    └── lambda-user/        # this repository's user layer
```

The files in this repository already mirror that destination:

```text
.
├── README.md
├── docs/
│   ├── PORTING-NOTES.md
│   └── READING-ORDER.md
└── lambda-library/
    └── lambda-user/
        ├── config.el
        ├── early-config.el
        ├── private.example.el
        ├── starter-platform.el
        ├── starter-setup-languages.el
        ├── starter-setup-meow.el
        ├── starter-setup-org.el
        ├── starter-setup-terminal.el
        ├── starter-setup-treesit.el
        └── starter-setup-ui.el
```

No bootstrap script is required or provided. Clone Lambda however you prefer, then make `lambda-library/lambda-user/` contain these files.

## Manual setup

Lambda currently requires Emacs 30.1+.

1. Obtain Lambda-Emacs from `https://codeberg.org/Lambda-Emacs/lambda-emacs`.
2. Put the contents of this repo's `lambda-library/lambda-user/` into Lambda's corresponding directory.
3. Start Emacs with that Lambda checkout as its init directory, for example:

```sh
emacs --init-directory="$HOME/.config/lambda-emacs"
```

On Windows the equivalent is conceptually:

```powershell
emacs --init-directory="$env:USERPROFILE\.config\lambda-emacs"
```

The actual checkout location is deliberately your choice.

### Nix / NixOS

The initial model is deliberately simple:

```text
Nix / NixOS / Home Manager
    -> Emacs 30.1+
    -> Git, ripgrep, fd, language servers, compilers, etc.

Lambda-Emacs
    -> Emacs Lisp packages and framework configuration

lambda-user/
    -> your policy and extensions
```

That keeps the Emacs configuration easy to understand while learning it. If you later want Nix to own Elisp packages too, migrate that responsibility deliberately rather than mixing both approaches from the start.

## What loads by default

The starter keeps enough of Lambda to be a useful daily text editor without importing Colin's personal environment:

- Lambda buffer/window/font/face foundations, while retaining ordinary OS-managed frame decorations;
- Vertico/Consult-style completion and search from Lambda;
- built-in `which-key` discoverability;
- Dired;
- project.el + Lambda tab/workspace integration;
- Magit / VC integration;
- Org base/settings plus a minimal inbox capture setup;
- Lambda's general programming layer;
- pinned Emacs-30-compatible Tree-sitter grammar recipes with safe mode fallback;
- built-in Eglot commands, with automatic server startup left opt-in;
- shell + Eshell;
- **Meow** with Colin-inspired QWERTY selection-first bindings;
- Lambda's semantic leader maps exposed directly through **`SPC`**;
- the starter UI layer described below.

Not loaded initially:

- mail/calendar;
- bibliography/citation workflow;
- Colin's teaching modules;
- personal note-system choices;
- PDF/Elfeed/LLM stacks;
- language-specific IDE packages beyond Lambda's general programming layer.

Nix, Racket, and Guile/Scheme packages remain explicit choices through
`starter-language-packages`; no language runtime or server is silently assumed.

## Tree-sitter grammars

Lambda's upstream recipes follow grammar repository heads.  This user layer
replaces those entries with exact revisions whose generated parsers use ABI 13
or 14, keeping every recipe within Emacs 30's supported parser ABI range.

Install one grammar with:

```text
M-x starter-treesit-install-language-grammar
```

Or install every pinned grammar with:

```text
M-x starter-treesit-install-all-grammars
```

You need Git plus a C/C++ compiler visible to Emacs.  On the current Windows
setup, `C:/msys64/ucrt64/bin/` supplies GCC.  A `*-ts-mode` remap is added only
after its grammar loads successfully; otherwise the classic major mode remains
active.  `M-x starter-treesit-refresh-mode-remaps` rechecks this without a
restart.

## Integrated terminals

The terminal leader namespace is:

```text
SPC o e   EAT using the platform's normal shell
SPC o p   project-local EAT
SPC o m   MSYS2 UCRT64 Bash in EAT (native Windows)
```

On native Windows, EAT still expects a POSIX `/usr/bin/env sh` launch helper.
The starter terminal module translates that helper to the configured MSYS2
installation while leaving the actual ordinary terminal shell as PowerShell.
Set `starter-msys2-root` (or `MSYS2_ROOT`) if MSYS2 is not in `C:/msys64/`.

Native Windows Emacs uses pipes rather than a Unix PTY.  Ordinary command-line
work is supported, but job control and some full-screen terminal applications
may remain limited by that upstream constraint.

## Language tooling

Eglot is built into Emacs and is available without enabling Lambda's broader LSP
module, which currently auto-starts servers and duplicates Tree-sitter policy.
The starter uses a smaller `SPC l` namespace:

```text
SPC l e   start/manage Eglot
SPC l a   code actions
SPC l R   rename symbol
SPC l f   format buffer
SPC l d   find definition
SPC l r   find references
SPC l q   shut down server
```

Eglot does not auto-start by default.  Once a language server is installed, add
its modes in `private.el`, for example:

```elisp
(setq starter-eglot-auto-start-modes '(python-mode python-ts-mode))
```

Optional editing packages use the same policy:

```elisp
(setq starter-language-packages '(nix racket guile))
```

## Starter UI

`starter-setup-ui.el` is deliberately separate from behavior/navigation. It can be replaced without changing the editor architecture.

Default presentation:

- **Doom Dark+** through the standalone `doom-themes` package;
- **doom-modeline** at the bottom of the frame;
- Lambda's built-in `tab-bar`/`tabspaces` workspaces, with the tab bar shown only once there is more than one workspace;
- modest `spacious-padding`, while keeping native frame decorations so Windows/FancyWM and normal Linux/macOS window managers can resize the frame;
- line numbers + current-line highlighting in programming buffers;
- matching-parenthesis highlighting;
- optional Nerd Icons in the modeline, completion UI, and Dired.

This takes presentation cues from Firemacs while deliberately not importing its custom terminal-first statuscolumn or MRU-tab implementation. The existing Lambda workspace abstraction remains the canonical tab/workspace model.

### Theme selection

The default is:

```elisp
(setq starter-ui-theme 'doom-dark+)
```

Change it in `private.el` or before `starter-setup-ui` loads. Other `doom-themes` themes can be used the same way, for example:

```elisp
(setq starter-ui-theme 'doom-one)
;; or
(setq starter-ui-theme 'doom-gruvbox)
```

### Nerd Icons

Icons are set to `auto` by default:

```elisp
(setq starter-ui-icons 'auto)
```

In a graphical frame they are enabled only if `Symbols Nerd Font Mono` is actually installed. Missing fonts therefore produce a normal text modeline rather than broken glyphs.

After the `nerd-icons` package has been installed by first startup, run:

```text
M-x nerd-icons-install-fonts
```

On Linux/macOS this can install the font directly. On Windows the command downloads the font files, after which they still need to be installed through Windows (right-click the downloaded font files and choose **Install**, then restart Emacs).

To force icons in a terminal that already uses a Nerd Font:

```elisp
(setq starter-ui-icons t)
```

To disable them everywhere:

```elisp
(setq starter-ui-icons nil)
```

## Portable defaults

`starter-platform.el` avoids account- or machine-specific absolute paths.

- **Windows:** prefers `pwsh.exe`, then `powershell.exe`, then `cmd.exe`.
- **GNU/Linux / Nix:** prefers `zsh`, then `bash`, then `sh`.
- **macOS:** prefers `zsh`, then `bash`, then `sh`.
- Projects default to `~/Projects/` (using `USERPROFILE` on native Windows where appropriate).
- Org defaults to `~/Documents/org/`.
- No primary text font is forced.

For values that should not be committed, copy `private.example.el` to `private.el`. It is ignored by Git and is loaded after portable defaults are defined but before they are applied.

## Interaction model

Lambda defines semantic keymaps such as buffer, file, search, VC, project, window, and workspace maps. The Meow layer reuses those maps instead of duplicating them.

```text
SPC b ...   buffers
SPC f ...   files
SPC p ...   projects
SPC s ...   search
SPC v ...   version control
SPC w ...   windows
SPC W ...   tabs/workspaces
SPC SPC     M-x
SPC /       describe Meow/keypad key
```

The important architectural point is:

```text
SPC + which-key
      ↓
Meow leader
      ↓
Lambda semantic keymaps
      ↓
ordinary Emacs commands/keymaps
```

So the interface is modal and discoverable without hiding the underlying Emacs machinery.

## First things to learn

Run `M-x meow-tutor`, then make frequent use of:

```text
C-h k   describe-key
C-h f   describe-function
C-h v   describe-variable
C-h m   describe-mode
M-x describe-keymap
M-x find-function
```

See `docs/READING-ORDER.md` for a guided source-reading sequence.

## Upstream / provenance

Active upstreams:

- Lambda-Emacs: `https://codeberg.org/Lambda-Emacs/lambda-emacs`
- Colin McLear's configuration: `https://codeberg.org/mclear-tools/dotemacs`
- Meow: `https://github.com/meow-edit/meow`

Presentation references/packages:

- Doom themes: `https://github.com/doomemacs/themes`
- doom-modeline: `https://github.com/seagle0128/doom-modeline`
- Nerd Icons: `https://github.com/rainstormstudio/nerd-icons.el`
- Spacious Padding: `https://github.com/protesilaos/spacious-padding`
- Firemacs (design reference): `https://github.com/66-firebat/firemacs`

The original Lambda/Colin port was checked against the final GitHub mirrors available on 2026-05-30, when both projects moved active development to Codeberg. Because Codeberg was not reachable from the execution environment that prepared that pass, treat the Lambda user layer as conservative rather than a claim of exact compatibility with every later upstream change.

## Learning rule

While learning the system, keep this boundary:

> **Do not edit `lambda-library/lambda-setup/` unless you have intentionally decided to fork framework behavior.** Prefer normal Emacs extension points from `lambda-user/`: variables, hooks, keymaps, `use-package`, and `with-eval-after-load`.
