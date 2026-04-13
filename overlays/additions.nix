{ inputs }:
# Custom derivations and version overrides.
final: prev: {
  # 1Password GUI beta — pinned to latest release, overrides the nixpkgs version.
  # See pkgs/1password-gui-beta.nix for update instructions.
  _1password-gui-beta = final.callPackage ../pkgs/1password-gui-beta.nix { };
}
