{ pkgs, ... }:
{
  # -----------------------------------------------------------------------
  # Neovim — package installed by Nix, config managed via xdg.configFile
  # mason manages LSPs at runtime (avoids nixvim complexity)
  # LazyExtras: editor.fzf (replaces telescope), ui.mini-starter
  # -----------------------------------------------------------------------
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withRuby = false;
    withPython3 = false;

    # System-level packages that LSP servers or plugins need
    extraPackages = with pkgs; [
      # Language servers (mason can also manage these; listed here for availability)
      lua-language-server
      gopls
      pyright
      terraform-ls
      yaml-language-server
      typescript-language-server
      bash-language-server

      # Tools used by plugins
      ripgrep
      fd
      tree-sitter
      gcc      # Required by nvim-treesitter to compile parsers
      nodejs   # Required by many mason-installed LSPs
    ];
  };

  # Neovim config directory — symlinked from the repo's dotfiles/nvim directory.
  # mason.nvim inside neovim manages plugin installation at runtime.
  # To update: run :Mason inside neovim.
  xdg.configFile."nvim" = {
    source = ../../dotfiles/nvim;
    recursive = true;
    force = true;
  };
}
