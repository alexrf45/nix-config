{...}: {
  # infra aws:prod/us-east-1 k8s:anubis tf:default   (line only shown when non-empty)
  # ╭ ~/path  branch ~+?  go v1.25  py v3.13 (venv)
  # ╰ ❯
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      # ''${custom.vpn} escapes to the literal ${custom.vpn}; the (…) group hides the infra line when empty.
      format = ''
        ([infra](dimmed white) $aws$kubernetes$terraform''${custom.vpn}
        )[╭](bold white) $directory$git_branch$git_status$golang$python
        [╰](bold white)$character
      '';
      scan_timeout = 10;
      add_newline = true;

      directory = {
        home_symbol = "~";
        truncation_length = 3;
        truncate_to_repo = true;
        style = "bold blue";
        read_only = " ro";
      };

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };

      git_branch = {
        format = "[ $branch]($style) ";
        style = "bold green";
      };

      git_status = {
        format = "([$all_status$ahead_behind]($style) )";
        style = "bright-white";
        conflicted = "⚔";
        ahead = "↑";
        behind = "↓";
        diverged = "⇕";
        untracked = "?";
        stashed = "≡";
        modified = "~";
        staged = "+";
        renamed = "»";
        deleted = "✘";
      };

      aws = {
        format = "[aws:$profile(/$region)]($style) ";
        style = "italic #bf5700";
        profile_aliases = {
          Admin = "Administrator";
          account-admin = "acct-adm";
        };
      };

      kubernetes = {
        disabled = false;
        format = "[k8s:$context( \\($namespace\\))]($style) ";
        style = "bold cyan";
      };

      terraform = {
        format = "[tf:$workspace]($style) ";
        style = "bold purple";
      };

      golang = {
        format = "[go $version]($style) ";
        style = "bold cyan";
        version_format = "v\${raw}";
      };

      python = {
        format = ''[py $version( \($virtualenv\))]($style) '';
        style = "bold yellow";
        python_binary = ["./venv/bin/python" "python" "python3"];
        version_format = "v\${raw}";
      };

      # Only OpenVPN tun[0-9]; never tailscale0.
      custom.vpn = {
        when = "ip link show | grep -qE '^[0-9]+: tun[0-9]'";
        command = "ip -4 addr | awk '/^[0-9]+: tun[0-9]/{found=1} found && /inet /{print $2; exit}' | cut -d/ -f1";
        format = "[vpn:$output]($style) ";
        style = "bold cyan";
      };

      gcloud.disabled = true;
      azure.disabled = true;
      pulumi.disabled = true;
      time.disabled = true;
    };
  };
}
