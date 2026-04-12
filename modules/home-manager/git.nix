{ pkgs, config, ... }:
{
  # -----------------------------------------------------------------------
  # Git — mirrors .config/git/config from dotfiles
  # SSH signing via 1Password op-ssh-sign
  # -----------------------------------------------------------------------
  programs.git = {
    enable = true;

    userName  = "alexrf45";
    userEmail = "fonalex45@gmail.com";

    signing = {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL12pfw++v9LFlLvug4OaZ9biScTIq8hcm6uiYM9kO4j";
      signByDefault = true;
    };

    extraConfig = {
      init.defaultBranch = "main";

      commit = {
        gpgsign = true;
        verbose = true;
      };

      core.editor = "nvim";

      pull.rebase = true;

      gpg = {
        format = "ssh";
        "ssh" = {
          allowedSignersFile = "${config.home.homeDirectory}/.config/git/allowed_signers";
          program = "/run/current-system/sw/bin/op-ssh-sign";
        };
      };

      column.ui = "auto";
      branch.sort = "-committerdate";
      tag.sort = "version:refname";

      push = {
        default = "simple";
        autoSetupRemote = true;
        followTags = true;
      };

      fetch = {
        prune = true;
        pruneTags = true;
        all = true;
      };
    };
  };

  # allowed_signers file — required for SSH signature verification
  xdg.configFile."git/allowed_signers".text = ''
    fonalex45@gmail.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL12pfw++v9LFlLvug4OaZ9biScTIq8hcm6uiYM9kO4j
  '';
}
