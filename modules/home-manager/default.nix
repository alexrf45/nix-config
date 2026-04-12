# Home Manager module index.
# Within this repo, modules are imported by path in home-manager/nitro5/fr3d/default.nix.
{
  shell      = import ./shell.nix;
  terminal   = import ./terminal.nix;
  editor     = import ./editor.nix;
  tmux       = import ./tmux.nix;
  git        = import ./git.nix;
  desktop    = import ./desktop.nix;
  devTools   = import ./dev-tools.nix;
  packages   = import ./packages.nix;
}
