{inputs}:
# Version pins layered on top of the nixpkgs-unstable channel.
#
# Applied only to the `pkgs-unstable` import in flake.nix — NOT exported via
# overlays/default.nix, because these overrides assume unstable's packaging and
# would break against stable (see the claude-code note below).
final: prev: {
  claude-code = prev.claude-code.override {
    manifest = prev.lib.importJSON ../pkgs/claude-code-manifest.json;
  };
}
