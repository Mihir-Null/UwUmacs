{
  description = "UwUmacs: a Meow-first Emacs configuration, with the tools it looks for";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      # nixpkgs-unstable dropped x86_64-darwin in 26.11; an Intel Mac can
      # point this flake's nixpkgs input at the nixpkgs-26.05-darwin branch.
      systems = [ "aarch64-darwin" "aarch64-linux" "x86_64-linux" ];
      forEachSystem = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      # nix-darwin: `imports = [ uwumacs.darwinModules.default ];` then
      # `programs.uwumacs.enable = true;`.  Installs Emacs, every program the
      # configuration discovers, and the icon font.  See nix/README.org.
      darwinModules.default = import ./nix/darwin-module.nix;
      darwinModules.uwumacs = self.darwinModules.default;

      # home-manager: links the checkout into place as ~/.config/emacs and can
      # install the same tools for a user without nix-darwin.
      homeManagerModules.default = import ./nix/home-module.nix;
      homeManagerModules.uwumacs = self.homeManagerModules.default;

      # The programs the configuration discovers at startup, as one list, so a
      # plain `nix profile install` or a NixOS configuration can use them too.
      packages = forEachSystem (pkgs:
        let tools = import ./nix/tools.nix { inherit pkgs; };
        in {
          tools = pkgs.buildEnv {
            name = "uwumacs-tools";
            paths = tools.programs ++ tools.fonts;
          };
          default = tools.emacs;
        });

      # `nix develop` gives a shell with Emacs and the tools for the batch
      # checks in AGENTS.md; no configuration is loaded.
      devShells = forEachSystem (pkgs:
        let tools = import ./nix/tools.nix { inherit pkgs; };
        in {
          default = pkgs.mkShell {
            packages = [ tools.emacs ] ++ tools.programs;
            shellHook = ''
              echo "UwUmacs: emacs -Q --batch -l tools/tangle.el -- --check"
            '';
          };
        });
    };
}
