{ inputs }:
# Custom derivations and version overrides.
final: prev: {
  # 1Password CLI beta — includes Terraform and additional shell plugins.
  # See pkgs/1password-cli-beta.nix for update instructions.
  _1password-cli-beta = final.callPackage ../pkgs/1password-cli-beta.nix { };

  # Security tools not packaged in nixpkgs — consumed by the CTF/pentest
  # devShells (see flake.nix). Each pkgs/<name>.nix has its own update procedure.
  linpeas        = final.callPackage ../pkgs/linpeas.nix { };
  winpeas        = final.callPackage ../pkgs/winpeas.nix { };
  pspy           = final.callPackage ../pkgs/pspy.nix { };
  sharpcollection = final.callPackage ../pkgs/sharpcollection.nix { };
  nishang        = final.callPackage ../pkgs/nishang.nix { };
}
