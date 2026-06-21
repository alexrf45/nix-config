{ inputs }:
# Attribute overrides for existing nixpkgs derivations.
# Usage: override version pins, apply patches, etc.
final: prev: {
  # Example:
  # somePackage = prev.somePackage.override { enableFeature = true; };
}
