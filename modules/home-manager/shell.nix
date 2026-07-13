{ pkgs, config, ... }:
{
  # -----------------------------------------------------------------------
  # Zsh — all aliases and functions managed in Nix; no sourced dotfiles
  # -----------------------------------------------------------------------
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 20000;
      save = 20000;
      path = "${config.home.homeDirectory}/.zsh_history";
      extended = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      share = true;
    };

    dotDir = config.home.homeDirectory;

    # -------------------------------------------------------------------
    # Aliases
    # -------------------------------------------------------------------
    shellAliases = {
      # NixOS rebuild
      thoth = "sudo nixos-rebuild switch --flake \".#thoth\"";
      horus = "sudo nixos-rebuild switch --flake \".#horus\"";

      # General
      r        = ". ~/.zshrc";
      h        = "cd ~";
      v        = "nvim";
      config   = "nvim ~/.vimrc";
      q        = "exit";
      edit     = "nvim";
      c        = "clear";
      get      = "curl -O -L";
      dir      = "exa";
      download = "aria2c";
      l        = "ls -lh --color=auto --group-directories-first";
      ls       = "ls -h --color=auto --group-directories-first";
      la       = "ls -lah --color=auto --group-directories-first";
      lsblk    = "lsblk | bat -l conf -p";
      sensors  = "sensors | bat -l cpuinfo -p";
      daily    = "bash $HOME/.config/scripts/daily.sh";
      code-auth = "export CLAUDE_CODE_OAUTH_TOKEN=$(op read \"op://Private/claude_api_token/credential\")";
      spotify  = "spotify_player";

      # Network / VPN
      tor     = "docker run --rm --detach --name tor --publish 127.0.0.1:9050:9050 tor:local";
      weather = "curl https://wttr.in";
      public  = "curl wtfismyip.com/text";
      htb     = "sudo openvpn ~/.config/openvpn/lab_fr3d1eeT.ovpn";
      vpn     = "sudo openvpn ~/.config/openvpn/us-ny-599.protonvpn.udp.ovpn";

      # tmux / tmuxp
      t    = "tmux";
      kali = "tmuxp load ~/.config/tmuxp/security.yaml";
      dev  = "tmuxp load ~/.config/tmuxp/dev.yaml";

      # Python
      py         = "python3";
      py-virt    = "python3 -m venv ./venv && source ./venv/bin/activate";
      freeze     = "pip freeze > requirements.txt";
      py-install = "pip install -r requirements.txt";
      py-list    = "pipx list | grep package";

      # Docker
      d       = "docker";
      db      = "docker build";
      dimls   = "docker image ls";
      dim     = "docker image";
      dc      = "docker container";
      dnt     = "docker network";
      # Unprivileged shell in current dir — subshell expansions run at invocation time
      ds      = "docker run --rm -v \"$(pwd):$(pwd)\" -w \"$(pwd)\" -u \"$(id -u):$(id -g)\" -it debian:13-slim";
      kali-root = "docker run --tty --interactive kalilinux/kali-rolling /bin/bash";
      dup     = "docker compose up -d";
      down    = "docker compose down";
      dnuke   = "docker system prune -af && docker volume prune -f";
      lzd     = "docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock -v /yourpath:/.config/jesseduffield/lazydocker lazyteam/lazydocker";
      portainer      = "docker run --name portainer -p 9000:9000 -d -v \"/var/run/docker.sock:/var/run/docker.sock\" portainer/portainer-ce:latest";
      portainerstop  = "docker stop portainer";
      portainerstart = "docker start portainer";
      gcloud    = "docker run --rm --volumes-from gcloud-config gcr.io/google.com/cloudsdktool/google-cloud-cli gcloud";
      juiceshop = "docker run --name juiceshop -d --rm -p 3000:3000 bkimminich/juice-shop";

      # Git
      g        = "git";
      ga       = "git add";
      gaa      = "git add --all";
      gb       = "git branch";
      gbd      = "git branch -d";
      gcb      = "git checkout -b";
      gc       = "git clone";
      gcl      = "git clone --recurse-modules";
      clean    = "git reset --hard && git clean -dfxx";
      checkout = "git checkout";
      gpl      = "git pull";
      gp       = "git push";
      gs       = "git status";
      gt       = "git tag";
      gptf     = "git push --follow-tags";
      glog     = "git log --date-order --pretty=\"format:%C(yellow)%h%Cblue%d%Creset %s %C(white) %an, %ar%Creset\"";
      gl       = "glog --graph";
      gla      = "gl --all";

      # AWS — credentials via 1Password CLI plugin
      aws      = "op plugin run -- aws";
      ec2-check = "op plugin run -- aws ec2 describe-instances --query 'Reservations[*].Instances[*].{PublicIP:PublicIpAddress,PrivateIP:PrivateIpAddress,Name:Tags[?Key==`Name`]|[0].Value,Type:InstanceType,Status:State.Name,VpcId:VpcId,Id:InstanceId}' --filters 'Name=instance-state-name,Values=running' --output table";
      s3-list  = "op plugin run -- aws s3api list-buckets | jq -r '.Buckets[].Name'";
      vpc-check = "op plugin run -- aws ec2 --output text --query 'Vpcs[*].{VpcId:VpcId,Name:Tags[?Key==`Environment`].Value|[0],CidrBlock:CidrBlock}' describe-vpcs";
      s3-delete = "op plugin run -- aws s3api delete-bucket --bucket $BUCKET";
      iam-access-id-admin = "op plugin run -- aws iam get-user --user-name account-admin | jq -r '.User | .UserId'";
      aws-nuke  = "cloud-nuke aws --exclude-resource-type s3 --exclude-resource-type iam --exclude-resource-type secretsmanager --exclude-resource-type dynamodb";
      aws-inspect       = "cloud-nuke inspect-aws";
      aws-services-list = "~/.config/scripts/services.sh";
      aws-services-cost = "~/.config/scripts/service-cost.sh";
      aws-current-cost  = "~/.config/scripts/awscurrentcost.sh";
      aws-cost-overall  = "~/.config/scripts/awscost.sh";
      s3-backend-delete = "~/.config/scripts/s3-delete.sh";
      s3-file-list = "op plugin run -- aws s3api list-objects --query 'Contents[].Key' --output text";
      ami-search   = "op plugin run -- aws ec2 describe-images --owner self amazon --filters 'Name=architecture,Values=x86_64' 'Name=name,Values=ubuntu/images/hvm-ssd/*' 'Name=root-device-type,Values=ebs' --output table";
      s3-create    = "python3 ~/.config/scripts/s3.py";

      # Terraform — credentials via 1Password CLI plugin
      tf    = "op plugin run -- terraform";
      tfi   = "op plugin run -- terraform init";
      tfir  = "op plugin run -- terraform init -backend-config=\"remote.tfbackend\" -upgrade";
      tflint = "terraform fmt && terraform validate";
      tfv   = "terraform validate";
      tfp   = "op plugin run -- terraform plan";
      tfa   = "op plugin run -- terraform apply";
      tfs   = "op plugin run -- terraform state";
      tfsls = "op plugin run -- terraform state list";
      tfo   = "op plugin run -- terraform output";
      tfd   = "op plugin run -- terraform destroy";
      cost  = "infracost breakdown --path=.";
    };

    # -------------------------------------------------------------------
    # Shell options, completion, and function definitions
    # -------------------------------------------------------------------
    initContent = ''
      setopt AUTO_CD
      setopt AUTO_PUSHD
      setopt EXTENDED_GLOB
      setopt EXTENDED_HISTORY
      setopt NOMATCH
      setopt MENU_COMPLETE
      setopt GLOB_DOTS
      setopt INTERACTIVE_COMMENTS
      setopt HIST_IGNORE_DUPS
      setopt HIST_VERIFY
      setopt INC_APPEND_HISTORY
      setopt SHARE_HISTORY
      setopt PROMPT_SUBST
      unsetopt beep
      setopt HIST_IGNORE_SPACE

      # Completion styling
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
      zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

      # Autosuggestion styling
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#ffffff,standout"
      ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE="10"
      ZSH_AUTOSUGGEST_USE_ASYNC=1

      # Edit command in $EDITOR
      autoload -Uz edit-command-line
      zle -N edit-command-line
      bindkey '^X^E' edit-command-line

      # ---- Functions ----

      cheat-code() {
        curl cheat.sh/"$1" | bat
      }

      color-log() {
        tail -f "$1" | grep --color=always -E "$2|$"
      }

      # Quick busybox HTTP server on given port
      http() {
        busybox httpd -h "$HOME/webserver" -p "$1"
      }

      extract() {
        if [ -f "$1" ]; then
          case "$1" in
            *.tar.bz2) tar xjf "$1" ;;
            *.tar.gz)  tar xzf "$1" ;;
            *.bz2)     bunzip2 "$1" ;;
            *.rar)     rar x "$1" ;;
            *.gz)      gunzip "$1" ;;
            *.tar)     tar xf "$1" ;;
            *.tbz2)    tar xjf "$1" ;;
            *.tgz)     tar xzf "$1" ;;
            *.zip)     unzip "$1" ;;
            *.Z)       uncompress "$1" ;;
            *.7z)      uncompress "$1" ;;
            *.apk)     uncompress "$1" ;;
            *.tar.lz)  uncompress "$1" ;;
            *.war)     uncompress "$1" ;;
            *.xz)      xz -d -v "$1" ;;
            *)         echo "'$1' cannot be extracted via extract()" ;;
          esac
        else
          echo "'$1' is not a valid file"
        fi
      }

      # cd up N directories: `up 3`
      up() {
        for i in $(seq 1 $1); do
          cd ../
        done
      }

      virtual_env() {
        mkdir "$1" &&
          cd "$1" &&
          virtualenv .venv &&
          source .venv/bin/activate
      }

      # Runs aws-cli via Chainguard container, inheriting session credentials
      aws_cli() {
        docker run --rm -it \
          -e AWS_ACCESS_KEY_ID="''${AWS_ACCESS_KEY_ID}" \
          -e AWS_SECRET_ACCESS_KEY="''${AWS_SECRET_ACCESS_KEY}" \
          cgr.dev/chainguard/aws-cli:latest "$*"
      }

      s3-file-size() {
        aws s3 ls --summarize --human-readable --recursive "$1" | tail -2
      }

      timestamp() {
        date +%Y%m%d-%T
      }

      git-new() {
        [ -d "$1" ] || mkdir "$1" &&
          cd "$1" &&
          git init &&
          touch .gitignore &&
          git add .gitignore &&
          git commit -m "Add .gitignore."
      }

      web-server() {
        miniserve \
          -t "fr3d" -v -F -H \
          -c monokai -p 8001 \
          --header "Cache-Control:no-cache" \
          --auth-file "$HOME/.local/auth.txt" \
          --tls-cert "$HOME/.local/certs/cert.pem" \
          --tls-key "$HOME/.local/certs/key.pem" \
          -u
      }

      cert-gen() {
        mkcert \
          -key-file "$HOME/.local/$1-key.pem" \
          -cert-file "$HOME/.local/$1-cert.pem" \
          localhost
      }

      encrypt_age() {
        age --passphrase --output "$1.enc" "$2"
      }

      decrypt_age() {
        age -d "$1" > "$2"
      }

      tf-docs() {
        docker run --rm \
          --volume "$(pwd):/terraform-docs" \
          -u "$(id -u)" \
          quay.io/terraform-docs/terraform-docs:0.20.0 markdown /terraform-docs
      }

      doc2md() {
        local myfilename="$1"
        pandoc \
          -t markdown_strict \
          --extract-media="./attachments/$myfilename" \
          "$myfilename.docx" \
          -o "$myfilename.md"
      }

      # Switch AWS profile: `awsp personal` or `awsp default`
      awsp() {
        export AWS_PROFILE="''${1:-default}"
        echo "Switched to AWS profile: $AWS_PROFILE"
      }

      # Auto-activate Python virtualenv when entering a project directory
      auto_venv() {
        if [[ -n "$VIRTUAL_ENV" && "$PWD" != *"''${VIRTUAL_ENV:h}"* ]]; then
          deactivate
          return
        fi
        [[ -n "$VIRTUAL_ENV" ]] && return
        local dir="$PWD"
        while [[ "$dir" != "/" ]]; do
          if [[ -f "$dir/venv/bin/activate" ]]; then
            source "$dir/venv/bin/activate"
            return
          fi
          dir="''${dir:h}"
        done
      }

      autoload -Uz add-zsh-hook
      add-zsh-hook chpwd auto_venv
    '';
  };

  # -----------------------------------------------------------------------
  # Starship prompt — minimal security-research layout
  # ╭ ~/path  branch ±~+?  (venv)  vpn:10.10.14.5
  # ╰ ❯
  # -----------------------------------------------------------------------
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      format = "[╭](bold white) $directory$git_branch$git_status$python$custom.vpn\n[╰](bold white)$character\n";
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

      # Only show venv name when inside an activated virtualenv
      python = {
        format = ''[(\($virtualenv\))]($style) '';
        style = "bold yellow";
        python_binary = [ "./venv/bin/python" "python" "python3" ];
        detect_extensions = [ "py" ];
      };

      # VPN indicator — only shown when a tun/tap/wg interface is up
      # Displays tunnel IP, useful during HTB/CTF to know your tun0 address
      custom.vpn = {
        command = ''ip addr show | grep -E '^[0-9]+: (tun|tap|wg)' -A 2 | grep 'inet ' | head -1 | awk '{print $2}' | cut -d'/' -f1'';
        when = ''ip addr show | grep -qE '^[0-9]+: (tun|tap|wg)' '';
        format = "[vpn:$output]($style) ";
        style = "bold cyan";
      };

      # Disabled — not needed in daily prompt
      aws.disabled       = true;
      gcloud.disabled    = true;
      terraform.disabled = true;
      azure.disabled     = true;
      time.disabled      = true;
      pulumi.disabled    = true;
      golang.disabled    = true;
    };
  };

  # -----------------------------------------------------------------------
  # Miscellaneous home files
  # -----------------------------------------------------------------------
  home.file = {
    # Overwrite pre-NixOS .zprofile — it had bare > characters that zsh
    # interpreted as redirects, creating junk files in $HOME on every login.
    ".zprofile" = { text = "# Managed by Home Manager — do not edit\n"; force = true; };
  };
}
