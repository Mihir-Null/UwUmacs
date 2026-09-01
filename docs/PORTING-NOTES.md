# Porting notes

## Source baseline

The initial pass was reviewed against the final GitHub mirrors available to the execution environment:

- `Lambda-Emacs/lambda-emacs`, final mirror commit `59d3429b8a5deca8d1c6b72bbd0c56e5b560e229` (2026-05-30, move-to-Codeberg notice);
- `mclear-tools/dotemacs`, archived when active development moved to Codeberg.

Active development for both is on Codeberg. This repository intentionally contains only the user layer so you can pair it with whichever Lambda revision you choose on each machine.

## Adapted from Colin's configuration

Kept as concepts or reduced code:

- staged module loading;
- Meow QWERTY normal-state vocabulary;
- exposing `lem+leader-map` as Meow's leader map;
- disabling Meow keypad modifier translation in favor of a semantic `SPC` leader;
- Magit normal-state and shell insert-state choices;
- semantic `SPC` groups backed by Lambda's existing prefix maps;
- normal Emacs inspection/discoverability rather than hiding framework internals.

Not ported:

- absolute `/Users/...` and Homebrew paths;
- mail and calendar;
- teaching modules;
- bibliography/citation workflow;
- macOS-only helpers;
- Colin's large explicit `package-selected-packages` list;
- personal workspace-opening commands;
- personal Org/Denote workflow;
- PDF/Elfeed/LLM stacks.

## Selective workflow migration

The first post-baseline migration keeps only workflows with a clear portable
boundary:

- built-in Eglot is exposed through a small leader map, but no server starts
  automatically until its modes are listed in `starter-eglot-auto-start-modes`;
- Nix, Racket, and Guile editing packages are opt-in through
  `starter-language-packages`.

The existing vault remains independent of this fresh starter configuration.
Org-roam, Org-remark annotations, Yasnippet/template libraries, agent-shell,
bibliography, mail, and calendar remain deferred until a proven workflow is
migrated at its canonical source rather than reconstructed as a compatibility
module here.

## Why this repo does not install Lambda

The repository is deliberately not a bootstrapper. Keeping Lambda and the user layer separable means you can choose per machine whether to:

- copy the files;
- symlink them;
- use a Git worktree/submodule arrangement;
- deploy them with Home Manager/Nix;
- keep a local Lambda fork and merge this layer into it.

The configuration therefore documents *where files belong* without deciding *how your machine should deploy them*.
