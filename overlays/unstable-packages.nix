{ inputs }:
# Exposes select unstable packages as pkgs.unstable.*
# All overlays are declared at the NixOS level (hosts/nitro5/default.nix),
# NOT inside home.nix — useGlobalPkgs = true makes home.nix overlays silent no-ops.
final: prev: {
  unstable = import inputs.nixpkgs-unstable {
    system = prev.system;
    config.allowUnfree = true;
  };
}
