# Home Manager module index.
# Within this repo, modules are imported by path in home-manager/horus/fr3d/default.nix.
{
  shell      = import ./shell.nix;
  terminal   = import ./terminal.nix;
  editor     = import ./editor.nix;
  tmux       = import ./tmux.nix;
  git        = import ./git.nix;
  desktop    = import ./desktop.nix;      # horus — Sway (Wayland)
  desktopI3  = import ./desktop-i3.nix;   # thoth — i3 (X11)
  devTools   = import ./dev-tools.nix;
  packages   = import ./packages.nix;
}
