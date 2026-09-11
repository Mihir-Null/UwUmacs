# Lambda framework provenance

Emacs-Dots contains a source snapshot of Lambda-Emacs, not a second checkout or a submodule.
The upstream repository, exact revision, and SHA-256 of every original imported file are recorded in `LAMBDA-UPSTREAM.json`. The original GPL-3.0 license is included as `LICENSE` and file copyright notices are retained.

Included: `init.el`, `early-init.el`, `lambda-library/lambda-setup/`, Lambda logos and splash text, and `lambda-library/lem-default-config.el`. The personal `lambda-user/` directory remains Emacs-Dots source. Upstream Git metadata, developer-agent instructions, tests and runtime data are not part of this snapshot.

Local integration patch in `lambda-library/lambda-setup/lem-setup-settings.el`:

- Store Customize preferences in persistent `var/etc/custom.el`, rather than disposable `var/cache/custom.el`.
- Let the personal `config.el` own the single `private.el` load, after platform defaults are defined.

The original file hashes remain in the manifest, so this patch is identifiable. All other vendored module files should match upstream after normalizing Git's Windows line endings. The root `early-init.el` and `init.el` are now generated from `literate/10-bootstrap.org`: their Lisp forms and attribution are retained, but the generated-source notice and block formatting differ from the original byte hashes. Those hashes remain the record of the unmodified import.

Personal package policy is authored in `literate/20-user-policy.org` and generated into `lambda-user/early-config.el`: install only the listed topics used by enabled modules. This does not uninstall old packages. When enabling an additional upstream module, also add its package topic if needed. Explicit personal `use-package :ensure` declarations remain supported.

## Updating

1. Start on a feature branch with a clean repository and backed-up local state.
2. Review the desired upstream revision. Update root startup code in `literate/10-bootstrap.org`; copy the vendor module/assets paths from the upstream snapshot.
3. Update the manifest from the unmodified upstream files, then reapply the documented integration patch.
4. Review changes to Lambda module variables, hooks, package policy and startup order against the user chapters in `literate/`. Update `literate/framework.org` if the module selection or local patch changes.
5. Regenerate with `tools/tangle.el -- --write`, check with `--check`, then run `tests/tangle-tests.el`. Run `tests/verify-config.el` using an existing package directory, then check ordinary graphical startup before deploying.

Package archives retain the existing policy (ELPA development and MELPA priority). The framework is pinned; individual ELPA package versions are not locked. A fresh install can therefore receive newer package versions than this machine. The migration preserves the existing installed package directory without updating it.
