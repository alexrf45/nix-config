{
  description = "Security research NixOS + Home Manager config (offensive & defensive). Ports the SCRT toolkit to Nix.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, home-manager, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
      pkgsFor = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true; # ghidra, some forensics tools, etc.
      };
    in
    {
      # ----------------------------------------------------------------------
      # Reusable modules — import these into your own hosts/users.
      # ----------------------------------------------------------------------
      nixosModules = {
        securityLab = ./modules/security/nixos.nix;
        default = ./modules/security/nixos.nix;
      };

      homeManagerModules = {
        # Security toolkit as per-user packages (works on non-NixOS too).
        securityLab = ./modules/security/home.nix;
        # The shell environment: zsh + starship + tmux + neovim + fzf, ported
        # faithfully from the SCRT resources/ directory.
        shell = ./modules/home;
        default = ./modules/home;
      };

      # ----------------------------------------------------------------------
      # Example NixOS host. Replace hosts/lab/hardware-configuration.nix with
      # the output of `nixos-generate-config` on your real machine, then:
      #   sudo nixos-rebuild switch --flake .#lab
      # ----------------------------------------------------------------------
      nixosConfigurations.lab = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          self.nixosModules.securityLab
          home-manager.nixosModules.home-manager
          ./hosts/lab
        ];
      };

      # ----------------------------------------------------------------------
      # Example standalone Home Manager profile (for non-NixOS machines):
      #   home-manager switch --flake .#fr3d
      # ----------------------------------------------------------------------
      homeConfigurations.fr3d = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsFor "x86_64-linux";
        modules = [
          self.homeManagerModules.securityLab
          self.homeManagerModules.shell
          ./home/fr3d.nix
        ];
      };

      formatter = forAllSystems (system: (pkgsFor system).nixpkgs-fmt);

      devShells = forAllSystems (system:
        let pkgs = pkgsFor system; in {
          default = pkgs.mkShell {
            packages = [ pkgs.nixpkgs-fmt pkgs.nil pkgs.statix pkgs.deadnix ];
          };
        });
    };
}
