<h1 align="center">
  <a href="https://git.io/typing-svg">
    <img src="https://readme-typing-svg.demolab.com?font=Google+Sans+Code&weight=600&duration=4000&pause=250&color=1ADCD4EB&background=393939B1&center=true&vCenter=true&multiline=true&repeat=false&width=435&height=70&lines=UwUmacs;%3A3" alt=":3 UwUmacs" />
  </a>
  
![Emacs](https://img.shields.io/badge/gnuemacs-%237F5AB6.svg?style=for-the-badge&logo=gnuemacs&logoColor=white)
![Org Mode](https://img.shields.io/badge/orgmode-%2377AA99.svg?style=for-the-badge&logo=org&logoColor=white)
![Last Commit](https://img.shields.io/github/last-commit/Mihir-Null/UwUmacs?style=for-the-badge&logo=git&logoColor=white&color=%237F5AB6)
![License](https://img.shields.io/github/license/Mihir-Null/UwUmacs?style=for-the-badge&color=%2377AA99)
![CI/CD](https://img.shields.io/github/actions/workflow/status/Mihir-Null/UwUmacs/ci.yml?style=for-the-badge&logo=githubactions&logoColor=white&label=CI%2FCD&color=%237F5AB6)

</h1>

A user-friendly, batteries-included, opinionated Emacs configuration built around [Meow](https://github.com/meow-edit/meow): select first, then act. It is for Meow what Doom and evil-collection are for Evil: a real `SPC` leader instead of Meow's keypad, a labelled menu for every major mode under `SPC m`, integrations for the packages you actually use, and everything discoverable through which-key and `C-h`. New editing surfaces are OS windows, so your window manager arranges them.

The whole configuration is written as a literate book in [`literate/`](literate/index.org): every chapter explains one part of the editor, shows the small piece of Lisp that configures it, and says why.

## Install

Requires GNU Emacs 30.1 or later (developed on 31.1). Clone into your init directory, or point Emacs at the clone:

```sh
git clone https://github.com/Mihir-Null/Emacs-Dots.git ~/.emacs.d
```

```sh
emacs --init-directory=/path/to/Emacs-Dots
```

The first start installs the Emacs Lisp packages it needs into `var/elpa/`. Emacs verifies GNU ELPA's signed index with `gpg`, so install [Gpg4win](https://gpg4win.org/) on Windows (GnuPG is usually already present on Linux and macOS); the startup file points Emacs at it, because the `gpg` that Git for Windows ships cannot verify anything from Emacs. Without a native `gpg` the check is skipped. Language servers, `ripgrep`, Git, a spell checker (`hunspell`, on Windows most simply from MSYS2) and fonts are yours to install; the configuration checks for them and degrades quietly. Icons need [Symbols Nerd Font Mono](https://www.nerdfonts.com/); the editing font is Google Sans Code if present, otherwise the platform default.

## First ten minutes

- `SPC SPC` runs any command by name. `SPC` then a letter opens a group; wait for the popup or press `C-h`.
- `SPC h ?` opens the cheat sheet; `SPC h t` starts Meow's interactive tutorial; `SPC h k` explains any key.
- `SPC f f` opens a file, `SPC b b` switches buffers, `SPC s s` searches lines, `SPC v s` opens Magit.
- `SPC m` is the menu for the current mode: in Org it schedules and captures, in Dired it copies and renames, in Magit it stages and commits.
- `SPC C c` opens the reading guide when you want to change something.

## How it is organised

```
.emacs.d/
  early-init.el, init.el   the only files Emacs reads on its own, ~90 lines together
  literate/                the chapters; edit these
  lisp/                    generated modules (uwumacs-*.el), cheat sheet, themes, private.el
  tests/                   tangle tests, startup verifier, leader tests, frame tests
  tools/tangle.el          the builder
  var/                     packages, caches, custom.el (ignored by Git)
```

Startup is a flat, ordered list of `require`s in `init.el`. Each module comes from one chapter. Packages are declared where they are used with `use-package … :ensure t`. Machine-specific settings go in `lisp/private.el` (`SPC C p` creates it from the example); it is loaded once, early, and ignored by Git.

## Change it

Edit a chapter, then rebuild and check:

```
M-x uwumacs-literate-tangle      (SPC C t)
M-x uwumacs-literate-check       (SPC C k)
```

or from a shell, without loading the configuration:

```sh
emacs -Q --batch -l tools/tangle.el -- --write
```

Restart Emacs and commit the chapter with its generated file. Startup never tangles, so a clone works without a build step. [ARCHITECTURE.md](ARCHITECTURE.md) records the design and the decisions behind it; [`literate/index.org`](literate/index.org) explains how to add a chapter, a key, or a mode menu.

## Verify

From the repository root, with an existing package directory:

```sh
emacs -Q --batch -l tools/tangle.el -- --check
emacs -Q --batch -l tests/tangle-tests.el -f ert-run-tests-batch-and-exit
EMACS_DOTS_TEST_PACKAGES=/path/to/var/elpa emacs -Q --batch -l tests/uwumacs-leader-tests.el -f ert-run-tests-batch-and-exit
EMACS_DOTS_TEST_PACKAGES=/path/to/var/elpa emacs -Q --batch -l tests/verify-config.el
```

The verifier copies the configuration to a temporary directory, forbids package installation, starts it, and checks the leader, the localleader key, the dashboard buttons, the theme toggle and every `SPC` row of the cheat sheet against the live keymap. `tests/frames-tests.el` covers frame policy and needs a graphical session: `M-x ert RET ^dots-frames- RET`.

## Windows notes

Windows Emacs resolves `~` to `AppData/Roaming` when `HOME` is unset, so a `.emacs.d` under your profile folder is not found by default. On the machine this was built on, `AppData/Roaming/.emacs.d` is a directory junction to the repository at `C:/Users/walnu/.config/emacs-dots/`; `--init-directory` is the alternative. PowerShell is the default shell; `SPC o m` opens an MSYS2 UCRT64 shell in EAT when MSYS2 is at `C:/msys64/` (set `uwumacs-msys2-root` in `private.el` otherwise). Do not recursively delete a junction or its target.

## Licence

GPL-3.0-or-later. Copyright (C) 2026 Mihir Talati. Portions are distilled from Lambda-Emacs and Colin McLear's configuration, both GPL-3.0-or-later, and each generated module says so in its header.

## Credits

Much of the policy is distilled from [Lambda-Emacs](https://codeberg.org/Lambda-Emacs/lambda-emacs) and [Colin McLear's configuration](https://codeberg.org/mclear-tools/dotemacs) (GPL-3.0-or-later); each chapter says what it took. The Meow grammar follows Meow's documented layout. The Sonokai theme is a tracked port in `lisp/themes/`. Everything else is the work of the packages' authors, declared in the chapters that use them.
