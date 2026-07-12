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
    tmuxp                        # tmuxp session manager

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
    # wireshark now provided system-wide via programs.wireshark (modules/nixos/security.nix)
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
    gef                   # GDB enhancement for CTF (pwndbg not in nixpkgs)
    pwntools              # CTF toolkit
    gdb

    # -----------------------------------------------------------------------
    # Cloud-nuke / cleanup
    # -----------------------------------------------------------------------
    # cloud-nuke            # Available in nixpkgs-unstable

    # -----------------------------------------------------------------------
    # Unstable packages (accessed via pkgs.unstable.*)
    # -----------------------------------------------------------------------
    pkgs-unstable.claude-code
    _1password-gui-beta
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
    "$HOME/.local/bin"
  ];
}
