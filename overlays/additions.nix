{ inputs }:
# Custom derivations and version overrides.
final: prev: {
  # 1Password CLI beta — includes Terraform and additional shell plugins.
  # See pkgs/1password-cli-beta.nix for update instructions.
  _1password-cli-beta = final.callPackage ../pkgs/1password-cli-beta.nix { };

  # 1Password GUI beta — pinned ahead of the nixpkgs beta (which lags and
  # expires). Without this line the config silently used nixpkgs' own
  # _1password-gui-beta. See pkgs/1password-gui-beta.nix for update steps.
  _1password-gui-beta = final.callPackage ../pkgs/1password-gui-beta.nix { };

  # imessage-exporter — export iMessage/SMS from an iOS backup to TXT/HTML.
  # Not in nixpkgs; see pkgs/imessage-exporter.nix for update instructions.
  imessage-exporter = final.callPackage ../pkgs/imessage-exporter.nix { };
}
