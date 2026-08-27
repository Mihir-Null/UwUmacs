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
        └── starter-setup-org.el
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

- Lambda window, buffer, frame, font, face, and theme defaults;
- Vertico/Consult-style completion and search from Lambda;
- built-in `which-key` discoverability;
- Dired;
- project.el + Lambda tab/workspace integration;
- Magit / VC integration;
- Org base/settings plus a minimal inbox capture setup;
- Lambda's general programming layer;
- shell + Eshell;
- **Meow** with Colin-inspired QWERTY selection-first bindings;
- Lambda's semantic leader maps exposed directly through **`SPC`**.

Not loaded initially:

- mail/calendar;
- bibliography/citation workflow;
- Colin's teaching modules;
- personal note-system choices;
- PDF/Elfeed/LLM stacks;
- language-specific IDE packages beyond Lambda's general programming layer.

`starter-setup-languages.el` is an intentionally optional example for Nix, Racket, and Guile/Scheme. Read it before enabling it.

## Portable defaults

`starter-platform.el` avoids account- or machine-specific absolute paths.

- **Windows:** prefers `pwsh.exe`, then `powershell.exe`, then `cmd.exe`.
- **GNU/Linux / Nix:** prefers `zsh`, then `bash`, then `sh`.
- **macOS:** prefers `zsh`, then `bash`, then `sh`.
- Projects default to `~/Projects/`.
- Org defaults to `~/Documents/org/`.
- No font is forced.

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

This initial port was checked against the final GitHub mirrors available on 2026-05-30, when both Lambda and Colin's config moved active development to Codeberg. Because Codeberg was not reachable from the execution environment that prepared this pass, treat this as a conservative user layer rather than a claim of exact compatibility with every later upstream change.

## Learning rule

While learning the system, keep this boundary:

> **Do not edit `lambda-library/lambda-setup/` unless you have intentionally decided to fork framework behavior.** Prefer normal Emacs extension points from `lambda-user/`: variables, hooks, keymaps, `use-package`, and `with-eval-after-load`.
