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
    # One shell, composed from this engagement's .scrt/tools.toml: the categories
    # (web/ad/forensics/pwn/osint/cloud/wireless/mobile/c2), plus any `extra`
    # packages and minus any `exclude`d ones. base recon/pivoting is always on.
    #
    # No tools.toml (or an empty one) errors on purpose — every box declares its
    # own kit. `pathExists`/`readFile` see the git-tracked flake source, so
    # tools.toml must be committed (scrt's `git add -A` handles that).
    devShells.x86_64-linux.default =
      if builtins.pathExists ./.scrt/tools.toml
      then scrt.lib.mkEngagement (builtins.fromTOML (builtins.readFile ./.scrt/tools.toml))
      else throw "scrt: no .scrt/tools.toml — declare tool categories (see README)";
  };
}
