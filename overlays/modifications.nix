{ inputs }:
# Attribute overrides for existing nixpkgs derivations.
# Usage: override version pins, apply patches, etc.
final: prev: {
  spotify-player = inputs.spotify-player.defaultPackage.${prev.stdenv.hostPlatform.system};
}
