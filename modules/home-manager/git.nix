{ pkgs, config, ... }:
{
  # -----------------------------------------------------------------------
  # Git — mirrors .config/git/config from dotfiles
  # SSH signing via 1Password op-ssh-sign
  # -----------------------------------------------------------------------
  programs.git = {
    enable = true;

    settings = {
      user = {
        name       = "alexrf45";
        email      = "fonalex45@gmail.com";
        signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAs2dHrHfbcfK0TdcaI2xU6pn5MaDfuDoYuhk5PumFYR";
      };

      init.defaultBranch = "main";

      commit = {
        gpgsign = true;
        verbose = true;
      };

      # emacsclient -t opens emacs in terminal; falls back to new emacs if no server.
      # Keep nvim here if you prefer a fast terminal editor for commit messages.
      core.editor = "emacsclient -t -a emacs";

      pull.rebase = true;

      gpg = {
        format = "ssh";
        ssh = {
          allowedSignersFile = "${config.home.homeDirectory}/.config/git/allowed_signers";
          program = "/run/current-system/sw/bin/op-ssh-sign";
        };
      };

      alias = {
        a    = "add";
        aa   = "add --all";
        b    = "branch";
        bd   = "branch -d";
        cb   = "checkout -b";
        cl   = "clone";
        clr  = "clone --recurse-modules";
        co   = "checkout";
        pl   = "pull";
        p    = "push";
        s    = "status";
        t    = "tag";
        ptf  = "push --follow-tags";
        nuke = "!git reset --hard && git clean -dfxx";
        lg   = "log --date-order --pretty=format:'%C(yellow)%h%Cblue%d%Creset %s %C(white) %an, %ar%Creset'";
        lgg  = "lg --graph";
        lga  = "lg --graph --all";
        new  = "!f() { [ -d \"$1\" ] || mkdir \"$1\" && cd \"$1\" && git init && touch .gitignore && git add .gitignore && git commit -m 'Add .gitignore.'; }; f";
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
