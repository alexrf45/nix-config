# Shell environment for security work, ported from SCRT's resources/ directory:
# zsh (oh-my-zsh + autosuggestions + syntax highlighting), starship prompt,
# tmux, neovim, fzf, and the operator quality-of-life CLI tools.
{ ... }:
{
  imports = [
    ./shell.nix
    ./starship.nix
    ./tmux.nix
    ./neovim.nix
    ./tools.nix
  ];
}
