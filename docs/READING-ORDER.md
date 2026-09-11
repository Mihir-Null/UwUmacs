# Reading order

Start with [the literate guide](../literate/index.org), which explains Emacs core,
Lambda, user configuration and later development as separate ownership layers.
Each chapter has nested headings, short code blocks and an explanation of why
that code belongs there.

1. [User policy](../literate/20-user-policy.org): trace package selection, the
   composition root, private overrides and staged loading.
2. [Platform and terminals](../literate/30-platform.org): understand portable
   paths, PowerShell and the explicit MSYS2 adapter.
3. [Editing](../literate/40-editing.org) and the
   [cheat sheet](../lambda-library/lambda-user/keybindings.org): learn Meow's
   selection grammar and how SPC reuses Lambda's semantic maps.
4. [Appearance](../literate/50-appearance.org) and
   [dashboard](../literate/55-dashboard.org): follow fonts before layout,
   conditional icons, theme changes and rendered-text centering.
5. [Programming](../literate/60-programming.org) and
   [Org](../literate/70-org.org): inspect the conservative subsystem choices.
6. [Maintenance](../literate/80-maintenance.org): distinguish portable source,
   generated deployment and private machine state.
7. [Bootstrap](../literate/10-bootstrap.org) and
   [framework map](../literate/framework.org): go deeper into Lambda's inherited
   startup and the selected vendor modules.

Use Emacs to inspect the running result: `C-h k` for a key, `C-h f` for a
function, `C-h v` for a variable, `C-h m` for active modes, and
`M-x describe-keymap` for a map. `M-x find-function` reaches the implementation;
if it is generated user Lisp, its first comment points back to the Org chapter.

For portable changes, edit the chapter, rebuild with `starter-literate-tangle`,
check with `starter-literate-check`, review both source and output, then restart.
Prefer variables, hooks, keymaps and deferred configuration in the user chapters.
Change vendor modules only when intentionally maintaining a documented framework
patch. See [upstream maintenance](UPSTREAM.md) and [deployment](DEPLOYMENT.md).
