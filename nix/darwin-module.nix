# nix-darwin module: Emacs, the tools UwUmacs discovers, and the icon font.
#
#   inputs.uwumacs.url = "github:Mihir-Null/UwUmacs";
#   inputs.uwumacs.inputs.nixpkgs.follows = "nixpkgs";
#   ...
#   imports = [ inputs.uwumacs.darwinModules.default ];
#   programs.uwumacs.enable = true;
#
# The configuration itself is not put in the Nix store: it writes packages,
# caches and private.el under its own directory, so clone it somewhere
# writable (~/.config/emacs) or let the home-manager module link it there.
{ config, lib, pkgs, ... }:

let
  cfg = config.programs.uwumacs;
  tools = import ./tools.nix { inherit pkgs; emacs = cfg.package; };
in
{
  options.programs.uwumacs = {
    enable = lib.mkEnableOption "UwUmacs: Emacs with the tools its configuration looks for";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.emacs;
      defaultText = lib.literalExpression "pkgs.emacs";
      description = ''
        The Emacs to install.  UwUmacs needs 30.1 or later.  `pkgs.emacs` is
        nixpkgs' current release as the Cocoa build; `pkgs.emacs-macport` is
        the Mitsuharu port.
      '';
    };

    daemon = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Start the Emacs server at login through launchd, so `emacsclient`
        opens files in frames of one running Emacs.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ] ++ tools.programs;
    fonts.packages = tools.fonts;

    services.emacs = lib.mkIf cfg.daemon {
      enable = true;
      package = cfg.package;
    };
  };
}
