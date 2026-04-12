{ pkgs, pkgs-unstable, ... }:
{
  home.packages = with pkgs; [
    # -----------------------------------------------------------------------
    # Go development
    # -----------------------------------------------------------------------
    go
    golangci-lint
    gotools          # goimports, godoc, etc.
    delve            # Go debugger

    # -----------------------------------------------------------------------
    # Python
    # -----------------------------------------------------------------------
    python3
    python3Packages.pip
    python3Packages.virtualenv
    python3Packages.tmuxp        # tmuxp session manager

    # -----------------------------------------------------------------------
    # Kubernetes / Home Lab
    # -----------------------------------------------------------------------
    kubectl
    k9s
    kubecolor        # Colorized kubectl output
    kubectx          # kubectx / kubens
    kubernetes-helm
    fluxcd
    krew             # kubectl plugin manager

    # -----------------------------------------------------------------------
    # Infrastructure / IaC
    # -----------------------------------------------------------------------
    terraform
    terraform-docs
    infracost
    tflint

    # -----------------------------------------------------------------------
    # AWS
    # -----------------------------------------------------------------------
    awscli2
    aws-vault

    # -----------------------------------------------------------------------
    # Secrets management
    # -----------------------------------------------------------------------
    sops
    age
    age-plugin-yubikey    # YubiKey age plugin (optional)

    # -----------------------------------------------------------------------
    # Security / CTF
    # -----------------------------------------------------------------------
    nmap
    netcat-gnu
    wireshark
    tcpdump
    gobuster
    ffuf
    sqlmap
    hydra
    john                  # John the Ripper
    hashcat
    burpsuite             # Requires unfree; from unstable for latest
    metasploit            # Requires unfree
    binutils              # objdump, strings, nm
    pwndbg                # GDB enhancement for CTF
    pwntools              # CTF toolkit
    gdb

    # -----------------------------------------------------------------------
    # Cloud-nuke / cleanup
    # -----------------------------------------------------------------------
    # cloud-nuke            # Available in nixpkgs-unstable

    # -----------------------------------------------------------------------
    # Unstable packages (accessed via pkgs.unstable.*)
    # -----------------------------------------------------------------------
    pkgs-unstable._1password-cli
    pkgs-unstable.claude-code
  ] ++ (with pkgs-unstable; [
    # Any additional unstable packages
  ]);

  # -----------------------------------------------------------------------
  # Go environment variables
  # -----------------------------------------------------------------------
  home.sessionVariables = {
    GOPATH   = "$HOME/go";
    GOBIN    = "$HOME/go/bin";
    GOPROXY  = "https://proxy.golang.org,direct";
    GOSUMDB  = "sum.golang.org";
  };

  home.sessionPath = [
    "$HOME/go/bin"
    "$HOME/.krew/bin"
    "$HOME/.local/bin"
  ];
}
