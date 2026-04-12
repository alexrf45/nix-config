{ inputs }:
# Custom derivations not yet in nixpkgs.
# Usage: pkgs.my-package
final: prev: {
  # Example:
  # my-tool = final.callPackage ../pkgs/my-tool { };
}
