{ inputs }: {
  additions    = import ./additions.nix { inherit inputs; };
  modifications = import ./modifications.nix { inherit inputs; };
  unstable-packages = import ./unstable-packages.nix { inherit inputs; };

  # Deliberately absent: unstable-pins.nix. It overrides packages as unstable
  # packages them, so it is applied to the pkgs-unstable import in flake.nix
  # rather than exported here, where it could be applied to stable pkgs.
}
