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

  # proton-drive-cli — Proton's official Drive CLI (prebuilt binary).
  # Not in nixpkgs yet (PR #557198 still open); swap to
  # pkgs-unstable.proton-drive-cli once it lands and settles.
  # See pkgs/proton-drive-cli.nix for update instructions.
  proton-drive-cli = final.callPackage ../pkgs/proton-drive-cli.nix { };

  # avd4linux — Azure Virtual Desktop client with CAC redirection.
  # Not in nixpkgs; see pkgs/avd4linux.nix for update instructions.
  # FreeRDP from unstable (3.31) rather than stable (3.26): upstream tests
  # against 3.32, and its AAD/RD-gateway handshake is parsed off FreeRDP's
  # terminal output, so stay close to that. Both channels ship pcsclite 2.4.1,
  # so it still speaks the same protocol as the stable pcscd. Drop the
  # override once stable reaches >= 3.31.
  avd4linux = final.callPackage ../pkgs/avd4linux.nix { freerdp = final.unstable.freerdp; };
}
