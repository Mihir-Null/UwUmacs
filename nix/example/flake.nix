# A complete nix-darwin system that uses the UwUmacs module.  Copy it as a
# starting point.  To evaluate it against the checkout you are in, rather
# than the published repository, override the input (CI does this on Linux;
# building the system needs a Mac):
#
#   nix eval --no-write-lock-file --override-input uwumacs path:$PWD #     --json ./nix/example#darwinConfigurations.example.config.programs.uwumacs.enable
{
  description = "Example nix-darwin host with UwUmacs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    uwumacs.url = "github:Mihir-Null/UwUmacs";
    uwumacs.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, nix-darwin, home-manager, uwumacs, ... }: {
    darwinConfigurations.example = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        uwumacs.darwinModules.default
        home-manager.darwinModules.home-manager
        ({ pkgs, ... }: {
          # Emacs, ripgrep, fd, git, gnupg, hunspell, gls, trash, the icon font.
          programs.uwumacs.enable = true;
          programs.uwumacs.daemon = false;

          # The checkout stays writable outside the store; home-manager links
          # it into place.  Packages are already installed system-wide.
          users.users.me.home = "/Users/me";
          home-manager.users.me = {
            imports = [ uwumacs.homeManagerModules.default ];
            programs.uwumacs = {
              enable = true;
              installPackages = false;
              source = "/Users/me/src/UwUmacs";
            };
            home.stateVersion = "24.11";
          };

          system.primaryUser = "me";
          system.stateVersion = 6;
          nixpkgs.hostPlatform = "aarch64-darwin";
        })
      ];
    };
  };
}
