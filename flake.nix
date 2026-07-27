{
  description = "fr3d's NixOS configuration — Acer Nitro 5";

  nixConfig = {
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://devenv.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
    ];
  };

  inputs = {
    # Primary stable channel
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    # Unstable channel — used via overlay for select packages only
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home Manager pinned to matching stable release
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # SOPS-nix for secrets management
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, sops-nix, ... }@inputs:
  let
    system = "x86_64-linux";
    inherit (self) outputs;

    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
  in
  {
    formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;

    # -------------------------------------------------------------------------
    # Project templates — bootstrap a new project with:
    #   nix flake init -t /path/to/nix-config#python
    # -------------------------------------------------------------------------
    templates = {
      python = {
        path        = ./templates/python;
        description = "Python devenv: APIs, scraping, data analysis + Docker";
      };
      mkdocs = {
        path        = ./templates/mkdocs;
        description = "MkDocs documentation site for Cloudflare Pages";
      };
    };

    overlays = import ./overlays { inherit inputs; };

    nixosConfigurations.horus = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs outputs pkgs-unstable;
      };
      modules = [
        ./hosts/horus
      ];
    };

    # Intel i5-1155G7 laptop, i3 (X11).
    nixosConfigurations.thoth = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs outputs pkgs-unstable;
      };
      modules = [
        ./hosts/thoth
      ];
    };
  };
}
