{
  description = "Security engagement — pinned toolset";

  # The whole point of this flake is its lock file: it records the exact
  # toolset revision this box was solved with, so the environment can be
  # reproduced months later when writing it up.
  #
  # Pinned to `dev` while the engagement workflow is being user-tested — `main`
  # does not carry it yet. Flip back to the default branch once testing is green.
  inputs.scrt.url = "github:alexrf45/nix-config/dev";

  outputs = { self, scrt, ... }: {
    # Inherit every shell from the toolset flake: `default` (full kit) plus
    # the per-domain variants for a lighter closure.
    devShells = scrt.devShells;
  };
}
