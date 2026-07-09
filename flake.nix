{
  description = "fr3d's NixOS configuration — Acer Nitro 5";

  nixConfig = {
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    # Primary stable channel
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    # Unstable channel — used via overlay for select packages only
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home Manager pinned to matching stable release
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # SOPS-nix for secrets management
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, sops-nix, ... }@inputs:
  let
    system = "x86_64-linux";
    inherit (self) outputs;

    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };

    # Security toolchest for the CTF/pentest devShells. Built from unstable so
    # the fast-moving ProjectDiscovery/AD tooling stays current, with the repo's
    # `additions` overlay applied so the vendored tools (linpeas, winpeas, pspy,
    # sharpcollection, nishang) resolve as pkgs-sec.<name>.
    pkgs-sec = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
      overlays = [ outputs.overlays.additions ];
    };

    # Common base shared by every security shell — recon, pivoting, file utils.
    secBase = with pkgs-sec; [
      nmap masscan socat netcat-gnu proxychains-ng chisel openvpn
      dnsutils whois
      jq fzf ripgrep fd bat aria2 p7zip exiftool
    ];

    mkSecShell = { name, extra, banner }:
      pkgs-sec.mkShell {
        name = "scrt-${name}";
        packages = secBase ++ extra;
        shellHook = ''
          export WINPEAS=${pkgs-sec.winpeas}/bin/winPEASx64.exe
          export RUBEUS=${pkgs-sec.sharpcollection}/bin/Rubeus.exe
          export CERTIFY=${pkgs-sec.sharpcollection}/bin/Certify.exe
          export NISHANG_DIR=${pkgs-sec.nishang}/share/nishang
          echo "── scrt:${name} ── ${banner}"
        '';
      };
  in
  {
    formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;

    overlays = import ./overlays { inherit inputs; };

    nixosConfigurations.horus = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs outputs pkgs-unstable;
      };
      modules = [
        ./hosts/horus
      ];
    };

    # Security-research daily driver — Intel i5-1155G7 laptop, i3 (X11).
    nixosConfigurations.thoth = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs outputs pkgs-unstable;
      };
      modules = [
        ./hosts/thoth
      ];
    };

    # -------------------------------------------------------------------------
    # Security devShells — disposable, per-engagement toolchains modeled on the
    # SCRT container variants (https://github.com/alexrf45/SCRT).
    #   nix develop .#web        — recon + web app testing
    #   nix develop .#ad         — Active Directory / Windows
    #   nix develop .#forensics  — forensics / stego / password cracking
    #   nix develop .#ctf        — pwn / RE / crypto umbrella (also `default`)
    # Pwn basics (pwntools/gdb/gef) also live in the always-on dev-tools.nix.
    # -------------------------------------------------------------------------
    devShells.${system} = {
      web = mkSecShell {
        name = "web";
        banner = "recon + web fuzzing";
        extra = with pkgs-sec; [
          subfinder httpx katana nuclei dnsx naabu amass
          ffuf gobuster feroxbuster wfuzz
          sqlmap whatweb wpscan
          waybackurls gau gron
          mitmproxy cewl crunch
          # unfurl  # verify attr (`nix search nixpkgs unfurl`) then enable
        ];
      };

      ad = mkSecShell {
        name = "ad";
        banner = "Active Directory / Windows ($RUBEUS $CERTIFY $WINPEAS $NISHANG_DIR)";
        extra = with pkgs-sec; [
          impacket netexec bloodhound evil-winrm kerbrute responder
          enum4linux-ng samba openldap krb5
          # Vendored (not in nixpkgs) — see pkgs/ and overlays/additions.nix
          sharpcollection nishang winpeas linpeas pspy
          # Verify these attr names (`nix search nixpkgs <name>`) then enable:
          # python3Packages.ldapdomaindump
          # bloodhound-py   # may be python3Packages.bloodhound-py
          # certipy-ad
        ];
      };

      forensics = mkSecShell {
        name = "forensics";
        banner = "forensics / stego / cracking";
        extra = with pkgs-sec; [
          steghide foremost binwalk volatility3 sqlitebrowser testdisk sleuthkit
          zsteg stegseek outguess
          fcrackzip pdfcrack hashid john hashcat
          seclists wordlists
          # name-that-hash  # verify attr name then enable
        ];
      };

      ctf = mkSecShell {
        name = "ctf";
        banner = "pwn / RE / crypto";
        extra = with pkgs-sec; [
          radare2 python3Packages.ropgadget one_gadget gdb gef pwntools z3
          binwalk ffuf gobuster sqlmap seclists
          # ghidra  # large (~1GB closure); enable for the GUI decompiler
        ];
      };

      default = self.devShells.${system}.ctf;
    };
  };
}
