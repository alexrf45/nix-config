{ inputs }:
# Custom derivations and version overrides.
final: prev: {
  # 1Password GUI beta — pinned to latest release, overrides the nixpkgs version.
  # See pkgs/1password-gui-beta.nix for update instructions.
  _1password-gui-beta = final.callPackage ../pkgs/1password-gui-beta.nix { };

  # Security tools not packaged in nixpkgs — consumed by the CTF/pentest
  # devShells (see flake.nix). Each pkgs/<name>.nix has its own update procedure.
  linpeas        = final.callPackage ../pkgs/linpeas.nix { };
  winpeas        = final.callPackage ../pkgs/winpeas.nix { };
  pspy           = final.callPackage ../pkgs/pspy.nix { };
  sharpcollection = final.callPackage ../pkgs/sharpcollection.nix { };
  nishang        = final.callPackage ../pkgs/nishang.nix { };
}
