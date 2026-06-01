# starship prompt — ported from resources/starship.toml. Keeps the operator's
# custom UTC clock, VPN-IP, and $TARGET segments that are handy on engagements.
{ ... }:
{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      "$schema" = "https://starship.rs/config-schema.json";

      format = ''
        [╭─❯](grey) UTC ''${custom.tztime}
        [┣─❯](grey) VPN: ''${custom.vpn}
        [┣─❯](grey) Target: ''${custom.target} $directory
        [╰](grey)$character'';

      scan_timeout = 10;
      add_newline = true;

      directory = {
        read_only = " 🔒";
        home_symbol = "~";
        truncation_length = 3;
        truncate_to_repo = true;
        format = "Directory: [\\[$path\\]]($style)";
        style = "bold cyan";
      };

      character = {
        success_symbol = " [>](bold green)";
        error_symbol = " [×](bold red)";
      };

      custom.tztime = {
        command = ''date -u +"%a %b %d %Y %T"'';
        disabled = false;
        when = "true";
        format = " [\\[🕙 $symbol($output)\\]]($style)";
        style = "bold yellow";
      };

      custom.target = {
        command = "echo $TARGET";
        disabled = false;
        when = "true";
        format = "[\\[$symbol($output)\\]]($style)";
        style = "bold purple";
      };

      custom.vpn = {
        command = "ip addr show | grep -E '^[0-9]+: (tun|tap|wg)' -A 2 | grep 'inet ' | head -1 | awk '{print $2}' | cut -d'/' -f1";
        disabled = false;
        when = "true";
        format = " [\\[$symbol($output)\\]]($style)";
        style = "bold red";
      };

      line_break.disabled = false;

      python = {
        symbol = " ";
        format = "via [\${symbol}python (\${version} )(\\($virtualenv\\) )]($style)";
        style = "bold yellow";
        pyenv_prefix = "venv ";
        python_binary = [ "./venv/bin/python" "python" "python3" "python2" ];
        detect_extensions = [ "py" ];
        version_format = "v\${raw}";
      };

      git_branch = {
        format = " [ $symbol $branch]($style) ";
        style = "bold green";
        symbol = " ";
      };

      git_status = {
        conflicted = "⚔️ ";
        ahead = "🏎️ 💨 ×\${count} ";
        behind = "🐢 ×\${count} ";
        diverged = "🔱 🏎️ 💨 ×\${ahead_count} 🐢 ×\${behind_count} ";
        untracked = "🛤️  ×\${count} ";
        stashed = "📦 ";
        modified = "📝 ×\${count} ";
        staged = "🗃️  ×\${count} ";
        renamed = "📛 ×\${count} ";
        deleted = "🗑️  ×\${count} ";
        style = "bright-white";
        format = "$all_status$ahead_behind";
      };

      git_commit = {
        commit_hash_length = 5;
        style = "bold yellow";
      };

      kubernetes = {
        format = "[k8s: $context \\($namespace\\)]($style) ";
        disabled = false;
        style = "bold green";
        contexts = [
          { context_pattern = "^admin@osiris$"; context_alias = "prod"; style = "bold red"; }
          { context_pattern = "^admin@anubis$"; context_alias = "dev"; style = "bold yellow"; }
          { context_pattern = "^admin@horus$"; context_alias = "testing"; style = "italic purple"; }
        ];
      };
    };
  };
}
