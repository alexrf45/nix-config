{ inputs }:
# Custom derivations and version overrides.
final: prev: {
  # 1Password CLI beta — includes Terraform and additional shell plugins.
  # See pkgs/1password-cli-beta.nix for update instructions.
  _1password-cli-beta = final.callPackage ../pkgs/1password-cli-beta.nix { };

  # imessage-exporter — export iMessage/SMS from an iOS backup to TXT/HTML.
  # Not in nixpkgs; see pkgs/imessage-exporter.nix for update instructions.
  imessage-exporter = final.callPackage ../pkgs/imessage-exporter.nix { };
}
