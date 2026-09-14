{
  pkgs,
  config,
  ...
}: {
  # -----------------------------------------------------------------------
  # Bash — all aliases and functions managed in Nix; no sourced dotfiles.
  #
  # Migrated from zsh (2026-09-13). Design rule: stay close to stock bash so
  # muscle memory transfers to work boxes. Anything that only works because
  # Home Manager installed it lives behind a feature test.
  # -----------------------------------------------------------------------
  programs.bash = {
    enable = true;
    enableCompletion = true;

    historySize = 20000;
    historyFileSize = 20000;
    historyFile = "${config.home.homeDirectory}/.bash_history";

    # erasedups ~ zsh ignoreAllDups; ignorespace ~ zsh HIST_IGNORE_SPACE
    historyControl = ["erasedups" "ignorespace"];

    # autocd        ~ setopt AUTO_CD
    # extglob       ~ setopt EXTENDED_GLOB
    # dotglob       ~ setopt GLOB_DOTS
    # histappend    ~ setopt INC_APPEND_HISTORY (paired with `history -a` below)
    # histverify    ~ setopt HIST_VERIFY
    # NOTE: `failglob` (~ setopt NOMATCH) is deliberately NOT set. It aborts
    # commands whose globs match nothing, which is standard zsh behaviour but
    # surprising in bash and absent on work boxes — a portability footgun.
    shellOptions = [
      "autocd"
      "checkjobs"
      "checkwinsize"
      "cdspell"
      "dotglob"
      "extglob"
      "globstar"
      "histappend"
      "histverify"
    ];

    # -------------------------------------------------------------------
    # Aliases
    # -------------------------------------------------------------------
    shellAliases = {
      # NixOS rebuild
      thoth = "sudo nixos-rebuild switch --flake \"github:alexrf45/nix-config#thoth\"";
      horus = "sudo nixos-rebuild switch --flake \"github:alexrf45/nix-config#horus\"";

      # General
      r = ". ~/.bashrc";
      h = "cd ~";
      v = "nvim";
      config = "nvim ~/.vimrc";
      q = "exit";
      edit = "nvim";
      c = "clear";
      get = "curl -O -L";
      dir = "exa";
      download = "aria2c";
      l = "ls -lh --color=auto --group-directories-first";
      ls = "ls -h --color=auto --group-directories-first";
      la = "ls -lah --color=auto --group-directories-first";
      sensors = "sensors | bat -l cpuinfo -p";
      daily = "bash $HOME/.config/scripts/daily.sh";
      spotify = "spotify_player";

      # Network / utils
      tor = "docker run --rm --detach --name tor --publish 127.0.0.1:9050:9050 tor:local";
      weather = "curl https://wttr.in";
      public = "curl wtfismyip.com/text";
      vpn = "sudo openvpn ~/.config/openvpn/us-ny-599.protonvpn.udp.ovpn";
      serve = "python3 -m http.server 8000"; # serve cwd over HTTP :8000
      servep = "python3 -m http.server"; # servep <port>
      ports = "ss -tulpn"; # listening sockets
      myip = "ip -4 -brief addr";
      b64d = "base64 -d";
      b64e = "base64";
      urldecode = "python3 -c 'import sys,urllib.parse as u; print(u.unquote(sys.argv[1]))'";
      urlencode = "python3 -c 'import sys,urllib.parse as u; print(u.quote(sys.argv[1]))'";

      # tmux / tmuxp
      t = "tmux";
      dev = "tmuxp load ~/.config/tmuxp/dev.yaml";

      # Python
      py = "python3";
      py-virt = "python3 -m venv ./venv && source ./venv/bin/activate";
      freeze = "pip freeze > requirements.txt";
      py-install = "pip install -r requirements.txt";
      py-list = "pipx list | grep package";

      # Docker
      d = "docker";
      db = "docker build";
      dimls = "docker image ls";
      dim = "docker image";
      dc = "docker container";
      dnt = "docker network";
      # Unprivileged shell in current dir — subshell expansions run at invocation time
      ds = "docker run --rm -v \"$(pwd):$(pwd)\" -w \"$(pwd)\" -u \"$(id -u):$(id -g)\" -it debian:13-slim";
      kali-root = "docker run --tty --interactive kalilinux/kali-rolling /bin/bash";
      dup = "docker compose up -d";
      down = "docker compose down";
      dnuke = "docker system prune -af && docker volume prune -f";
      lzd = "docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock -v /yourpath:/.config/jesseduffield/lazydocker lazyteam/lazydocker";
      portainer = "docker run --name portainer -p 9000:9000 -d -v \"/var/run/docker.sock:/var/run/docker.sock\" portainer/portainer-ce:latest";
      portainerstop = "docker stop portainer";
      portainerstart = "docker start portainer";
      gcloud = "docker run --rm --volumes-from gcloud-config gcr.io/google.com/cloudsdktool/google-cloud-cli gcloud";
      juiceshop = "docker run --name juiceshop -d --rm -p 3000:3000 bkimminich/juice-shop";

      # Git — shell shortcuts pointing to git aliases (defined in git.nix)
      g = "git";
      ga = "git a";
      gaa = "git aa";
      gb = "git b";
      gbd = "git bd";
      gcb = "git cb";
      gc = "git cl";
      gcl = "git clr";
      clean = "git nuke";
      checkout = "git co";
      gpl = "git pl";
      gp = "git p";
      gs = "git s";
      gt = "git t";
      gptf = "git ptf";
      glog = "git lg";
      gl = "git lgg";
      gla = "git lga";

      # AWS — credentials via 1Password CLI plugin
      aws = "op plugin run -- aws";
      ec2-check = "op plugin run -- aws ec2 describe-instances --query 'Reservations[*].Instances[*].{PublicIP:PublicIpAddress,PrivateIP:PrivateIpAddress,Name:Tags[?Key==`Name`]|[0].Value,Type:InstanceType,Status:State.Name,VpcId:VpcId,Id:InstanceId}' --filters 'Name=instance-state-name,Values=running' --output table";
      s3-list = "op plugin run -- aws s3api list-buckets | jq -r '.Buckets[].Name'";
      vpc-check = "op plugin run -- aws ec2 --output text --query 'Vpcs[*].{VpcId:VpcId,Name:Tags[?Key==`Environment`].Value|[0],CidrBlock:CidrBlock}' describe-vpcs";
      s3-delete = "op plugin run -- aws s3api delete-bucket --bucket $BUCKET";
      iam-access-id-admin = "op plugin run -- aws iam get-user --user-name account-admin | jq -r '.User | .UserId'";
      aws-nuke = "cloud-nuke aws --exclude-resource-type s3 --exclude-resource-type iam --exclude-resource-type secretsmanager --exclude-resource-type dynamodb";
      aws-inspect = "cloud-nuke inspect-aws";
      aws-services-list = "~/.config/scripts/services.sh";
      aws-services-cost = "~/.config/scripts/service-cost.sh";
      aws-current-cost = "~/.config/scripts/awscurrentcost.sh";
      aws-cost-overall = "~/.config/scripts/awscost.sh";
      s3-backend-delete = "~/.config/scripts/s3-delete.sh";
      s3-file-list = "op plugin run -- aws s3api list-objects --query 'Contents[].Key' --output text";
      ami-search = "op plugin run -- aws ec2 describe-images --owner self amazon --filters 'Name=architecture,Values=x86_64' 'Name=name,Values=ubuntu/images/hvm-ssd/*' 'Name=root-device-type,Values=ebs' --output table";
      s3-create = "python3 ~/.config/scripts/s3.py";

      # Terraform — credentials via 1Password CLI plugin
      tf = "op plugin run -- terraform";
      tfi = "op plugin run -- terraform init";
      tfir = "op plugin run -- terraform init -backend-config=\"remote.tfbackend\" -upgrade";
      tflint = "terraform fmt && terraform validate";
      tfv = "terraform validate";
      tfp = "op plugin run -- terraform plan";
      tfa = "op plugin run -- terraform apply";
      tfs = "op plugin run -- terraform state";
      tfsls = "op plugin run -- terraform state list";
      tfo = "op plugin run -- terraform output";
      tfd = "op plugin run -- terraform destroy";
      cost = "infracost breakdown --path=.";
    };

    # -------------------------------------------------------------------
    # Interactive setup, prompt, and function definitions
    # -------------------------------------------------------------------
    initExtra = ''
      # ~ setopt EXTENDED_HISTORY — timestamps in `history` output
      HISTTIMEFORMAT="%F %T  "

      # ===================================================================
      # Prompt
      #
      # ╭ ~/nix-config  main *% (venv)
      # ╰ ❯
      #
      # Renders: cwd · git branch + dirty state · active virtualenv ·
      # exit-status-coloured ❯. No prompt daemon — everything below is
      # portable bash and can be pasted into a work box's ~/.bashrc as-is.
      # ===================================================================

      # git-prompt.sh ships inside git itself. Try the Nix store path first,
      # then the usual distro locations, so this block survives being copied
      # onto a RHEL/Debian box.
      for __gp in \
        "${pkgs.git}/share/bash-completion/completions/git-prompt.sh" \
        /usr/share/git-core/contrib/completion/git-prompt.sh \
        /etc/bash_completion.d/git-prompt.sh
      do
        [ -r "$__gp" ] && . "$__gp" && break
      done
      unset __gp

      # No-op fallback so PS1 never errors if git-prompt.sh is missing entirely
      declare -F __git_ps1 >/dev/null 2>&1 || __git_ps1() { :; }

      GIT_PS1_SHOWDIRTYSTATE=1      # * unstaged, + staged
      GIT_PS1_SHOWUNTRACKEDFILES=1  # %
      GIT_PS1_SHOWSTASHSTATE=1      # $
      GIT_PS1_SHOWCOLORHINTS=       # we colour it ourselves
      VIRTUAL_ENV_DISABLE_PROMPT=1  # we render the venv ourselves

      # Auto-activate a Python virtualenv when entering a project directory,
      # and deactivate on leaving it. This is the bash port of zsh's
      # `add-zsh-hook chpwd auto_venv` — bash has no chpwd hook, so it runs
      # from PROMPT_COMMAND behind a cwd-change guard.
      auto_venv() {
        [ "$PWD" = "''${__LAST_PWD-}" ] && return
        __LAST_PWD="$PWD"

        if [ -n "''${VIRTUAL_ENV-}" ] && [[ "$PWD" != *"''${VIRTUAL_ENV%/*}"* ]]; then
          deactivate
          return
        fi
        [ -n "''${VIRTUAL_ENV-}" ] && return

        local dir="$PWD"
        while [ -n "$dir" ] && [ "$dir" != "/" ]; do
          if [ -f "$dir/venv/bin/activate" ]; then
            # shellcheck disable=SC1091
            . "$dir/venv/bin/activate"
            return
          fi
          dir="''${dir%/*}"
        done
      }

      # PS1 is rebuilt each prompt so the ❯ can carry the last exit status.
      # $? must be captured on the very first line of this function.
      __prompt() {
        local __exit=$?

        history -a          # ~ setopt INC_APPEND_HISTORY: flush immediately
        # Uncomment for full zsh-style SHARE_HISTORY across live sessions:
        # history -c; history -r

        auto_venv

        local __char
        if [ "$__exit" -eq 0 ]; then
          __char='\[\e[1;32m\]'   # green
        else
          __char='\[\e[1;31m\]'   # red
        fi

        PS1='\[\e[1;37m\]╭\[\e[0m\] \[\e[1;34m\]\w\[\e[0m\]'
        PS1+='\[\e[1;32m\]$(__git_ps1 "  %s")\[\e[0m\]'
        PS1+='\[\e[1;33m\]''${VIRTUAL_ENV:+ (''${VIRTUAL_ENV##*/})}\[\e[0m\]'
        PS1+='\n\[\e[1;37m\]╰\[\e[0m\] '"$__char"'❯\[\e[0m\] '
      }
      PROMPT_COMMAND=__prompt

      # ===================================================================
      # Functions
      # ===================================================================

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
        local i
        for i in $(seq 1 "$1"); do
          cd ../ || return
        done
      }

      virtual_env() {
        mkdir "$1" &&
          cd "$1" &&
          virtualenv .venv &&
          . .venv/bin/activate
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

      # Bootstrap a new Python devenv project:
      #   pydev <name>   — create dir, init flake template, drop into devenv shell
      #   pydev <name>   — if dir exists, just enter the devenv shell
      pydev() {
        if [ -z "$1" ]; then
          echo "Usage: pydev <project-name>"
          return 1
        fi
        local name="$1"

        if [ -d "$name" ]; then
          echo "→ '$name' already exists — entering devenv shell"
          cd "$name" && devenv shell
          return
        fi

        echo "→ Creating $PWD/$name"
        mkdir -p "$name" || return 1
        cd "$name" || return 1

        echo "→ Initializing Python devenv template"
        nix flake init -t '/home/fr3d/nix-config#python' || return 1

        echo "→ Starting devenv shell (first run installs packages, may take a moment)"
        devenv shell
      }
    '';
  };

  # -----------------------------------------------------------------------
  # Readline — replaces the zsh `zstyle` completion styling and `unsetopt beep`
  # -----------------------------------------------------------------------
  programs.readline = {
    enable = true;

    variables = {
      # ~ zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
      completion-ignore-case = true;
      # treat - and _ as interchangeable while completing
      completion-map-case = true;
      show-all-if-ambiguous = true;
      menu-complete-display-prefix = true;
      # ~ zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
      colored-stats = true;
      colored-completion-prefix = true;
      # ~ unsetopt beep
      bell-style = "none";
    };

    bindings = {
      # ~ setopt MENU_COMPLETE
      "TAB" = "menu-complete";
      "\\e[Z" = "menu-complete-backward"; # Shift-Tab cycles backwards
    };
  };

  # -----------------------------------------------------------------------
  # zoxide — previously installed as a bare package in packages.nix with no
  # shell integration, so `z` never existed. Wired up properly here.
  # -----------------------------------------------------------------------
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };
}
