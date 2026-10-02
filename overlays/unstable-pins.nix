{inputs}:
# Version pins layered on top of the nixpkgs-unstable channel.
#
# Applied only to the `pkgs-unstable` import in flake.nix — NOT exported via
# overlays/default.nix, because these overrides assume unstable's packaging and
# would break against stable (see the claude-code note below).
final: prev: {
  # claude-code pinned ahead of nixpkgs-unstable. Upstream ships ~daily; the
  # channel trails by days to weeks, and bumping the whole nixpkgs-unstable pin
  # to move one binary also rebuilds spotify-player from source (its flake
  # follows nixpkgs-unstable). Overriding `manifest` is the seam nixpkgs exposes
  # for exactly this — upstream's own manifest, committed verbatim, carries the
  # version and the per-platform sha256, so a bump needs no hash computation.
  #
  # Update procedure:
  #   1. V=$(curl -fsSL https://downloads.claude.ai/claude-code-releases/stable)
  #   2. curl -fsSL "https://downloads.claude.ai/claude-code-releases/$V/manifest.zst.json" \
  #        -o pkgs/claude-code-manifest.json
  #   (swap `stable` for `latest` to take same-day releases)
  #
  # Drop this override once the nixpkgs-unstable pin carries a newer version —
  # compare `nix eval .#nixosConfigurations.thoth.pkgs.unstable.claude-code.version`
  # against pkgs/claude-code-manifest.json after a /flake-update.
  #
  # Note `manifest` is an unstable-channel interface: it changed shape once
  # already (stable 26.05 takes an uncompressed `manifest.json` as a let-binding,
  # not an argument). A shape change breaks loudly at eval; the fallback is
  # deleting this override.
  claude-code = prev.claude-code.override {
    manifest = prev.lib.importJSON ../pkgs/claude-code-manifest.json;
  };
}
