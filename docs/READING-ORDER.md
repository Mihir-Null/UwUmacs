# Reading order

The goal is to understand the system while already having a useful editor.

## Pass 1 — understand the boundary

1. **Lambda `early-init.el`**
   - Find `lem-emacs-dir`, `lem-library-dir`, `lem-user-dir`, `lem-setup-dir`, package archives, and writable state directories.
   - Goal: know which parts are framework, user configuration, packages, and runtime state.

2. **Lambda `init.el`**
   - Read the section that chooses between `lambda-user/config.el` and Lambda's default config.
   - Goal: understand when control passes from the framework to your code.

3. **This repo's `lambda-library/lambda-user/config.el`**
   - This is the composition root.
   - Follow each `require` and note which startup phase owns it.

4. **`starter-platform.el`**
   - Goal: see how machine differences can be represented as policy without scattering OS checks through the config.

## Pass 2 — learn interaction

5. **Lambda `lem-setup-keybindings.el`**
   - Find `lem-prefix`, `lem+leader-map`, and the semantic prefix maps.
   - Inspect Lambda's built-in `which-key` configuration.

6. **`starter-setup-meow.el`**
   - Compare Meow's normal-state selection commands with the leader map.
   - Notice that `SPC` reuses Lambda's maps rather than creating a second command hierarchy.

7. Use Emacs to inspect itself:
   - `C-h k` — describe a key;
   - `C-h f` — describe a function;
   - `C-h v` — describe a variable;
   - `C-h m` — describe active modes;
   - `M-x describe-keymap` — inspect a keymap;
   - `M-x find-function` — jump to implementation.

## Pass 3 — learn subsystems as you need them

Read upstream modules in roughly this order:

- `lem-setup-completion.el` — minibuffer/completion stack;
- `lem-setup-dired.el` — file management;
- `lem-setup-projects.el` + `lem-setup-tabs.el` — projects and tab/workspace behavior;
- `lem-setup-vc.el` — Git/Magit;
- `lem-setup-org-base.el` + `lem-setup-org-settings.el` — Org;
- `lem-setup-programming.el` — programming defaults, tree-sitter, Flymake, etc.;
- `lem-setup-shell.el` + `lem-setup-eshell.el` — shell integration.

Then compare upstream behavior with the small user modules:

- `starter-platform.el`
- `starter-setup-org.el`
- `starter-setup-languages.el`

## Extension discipline

When changing behavior:

1. identify the command/variable with Emacs help;
2. identify which package or Lambda module owns it;
3. prefer `setopt`, hooks, keymap APIs, `with-eval-after-load`, or `use-package` in `lambda-user/`;
4. create another small user module when a subsystem becomes nontrivial;
5. patch `lambda-setup/` only when you intentionally want to maintain a framework fork.

This keeps the configuration explainable and makes upstream updates much easier to reason about.
