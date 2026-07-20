{
  description = "fr3d's NixOS configuration — Acer Nitro 5";

  nixConfig = {
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://devenv.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
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
      config = {
        allowUnfree = true;
        # apksigner (mobile bundle) pulls the Android SDK build-tools, which are
        # gated behind the Android SDK license.
        android_sdk.accept_license = true;
      };
      overlays = [ outputs.overlays.additions ];
    };

    # -------------------------------------------------------------------------
    # Security tool bundles.
    #
    # These are plain lists, each also exposed as a `packages.sec-<name>` buildEnv
    # below. `mkShell` is all-or-nothing: one broken leaf out of ~40 fast-moving
    # Python security packages takes down the entire shell, and that *will* recur
    # on every `nix flake update` (see the wfuzz breakage, commit 74f02f1).
    # Named outputs mean `nix build .#sec-web` catches a break before it bites
    # mid-box, and the fix is one `overrideAttrs` in one place.
    # -------------------------------------------------------------------------
    secBundles = with pkgs-sec; {
      # Recon, pivoting, file utils — present in every shell.
      base = [
        nmap masscan socat netcat-gnu proxychains-ng chisel openvpn
        dnsutils whois
        jq fzf ripgrep fd bat aria2 p7zip exiftool
      ];

      web = [
        subfinder httpx katana nuclei dnsx naabu amass
        # wfuzz dropped 2026-07: dead upstream (last release 2021), its
        # helpers/file_func.py imports pkg_resources which Python 3.14 no
        # longer ships. ffuf/feroxbuster/gobuster cover the same ground.
        ffuf gobuster feroxbuster
        sqlmap whatweb wpscan
        waybackurls gau gron unfurl
        mitmproxy cewl crunch
      ];

      ad = [
        python3Packages.impacket netexec bloodhound evil-winrm kerbrute responder
        enum4linux-ng samba openldap krb5
        # Vendored (not in nixpkgs) — see pkgs/ and overlays/additions.nix
        sharpcollection nishang winpeas linpeas pspy
        # `certipy` is the top-level attr; it builds certipy-ad.
        certipy python3Packages.ldapdomaindump python3Packages.bloodhound-py
      ];

      forensics = [
        steghide foremost binwalk volatility3 sqlitebrowser testdisk sleuthkit
        zsteg stegseek outguess
        fcrackzip pdfcrack hashid john hashcat
        seclists
        # `wordlists` pulls wfuzz by default, which no longer builds on
        # Python 3.14 (see the web bundle). Override `lists` to drop it — the
        # wordlists/wordlists_path helpers and rockyou/seclists/nmap survive.
        (wordlists.override { lists = [ nmap rockyou seclists ]; })
        nth  # name-that-hash
      ];

      pwn = [
        radare2 python3Packages.ropgadget one_gadget gdb gef pwntools z3
        binwalk seclists
        # ghidra  # large (~1GB closure); enable for the GUI decompiler
      ];

      # Passive/people/domain intel.
      osint = [
        theharvester recon-ng dnsrecon fierce
        sherlock maigret holehe
      ];

      # Cloud + container attack and audit.
      cloud = [
        awscli2 azure-cli google-cloud-sdk kubectl
        # kube-hunter dropped: archived upstream, and 0.6.8 imports pkg_resources
        # which modern Python no longer ships (same failure class as wfuzz).
        # trivy + kubescape cover k8s scanning.
        trivy prowler scoutsuite pacu kubescape
      ];

      # Wi-Fi / RF. Needs a capable adapter at runtime; packaging it does not.
      wireless = [
        aircrack-ng wifite2 reaverwps bully
        hcxtools hcxdumptool bettercap kismet cowpatty
      ];

      # Android / iOS reverse engineering.
      mobile = [
        apktool jadx dex2jar frida-tools objection
        scrcpy apksigner apkeep
      ];

      # Command-and-control / adversary emulation. `sliver` is vendored (not in
      # nixpkgs) — see pkgs/sliver.nix; its server binary is ~267MB, so this
      # bundle is heavy by design and opt-in only.
      c2 = [
        metasploit havoc starkiller
        sliver
      ];
    };

    # Every bundle except `base`, which is implicit in each shell.
    secAddOns = builtins.removeAttrs secBundles [ "base" ];

    # A shell is `base` plus zero or more add-on bundles. `nix develop` with no
    # add-ons named is the full kit — the domain split was a Docker image-size
    # artifact that buys little against a shared, deduped Nix store, and it
    # creates real friction when a target needs tools from two categories.
    # Shared shell assembly over an explicit package list: the env exports
    # ($RUBEUS/$CERTIFY/$WINPEAS/$NISHANG_DIR for the vendored Windows tools) and
    # the `.scrt/env` sourcing that every scrt shell needs.
    mkSecShellFromPackages = { name, packages, banner ? "custom kit" }:
      pkgs-sec.mkShell {
        name = "scrt-${name}";
        inherit packages;
        shellHook = ''
          export WINPEAS=${pkgs-sec.winpeas}/bin/winPEASx64.exe
          export RUBEUS=${pkgs-sec.sharpcollection}/bin/Rubeus.exe
          export CERTIFY=${pkgs-sec.sharpcollection}/bin/Certify.exe
          export NISHANG_DIR=${pkgs-sec.nishang}/share/nishang

          # Engagement context, if this shell was entered from a scaffolded
          # engagement directory. Sets RHOST/LHOST/ENGAGEMENT.
          if [ -f .scrt/env ]; then
            set -a; . .scrt/env; set +a
            echo "── scrt:${name} ── ''${ENGAGEMENT:-engagement}  RHOST=''${RHOST:-unset}  LHOST=''${LHOST:-unset}"
          else
            echo "── scrt:${name} ── ${banner}"
          fi
        '';
      };

    # base + named add-on bundles.
    mkSecShell = { name, addOns, banner }:
      mkSecShellFromPackages {
        inherit name banner;
        packages = secBundles.base
          ++ builtins.concatLists (map (a: secBundles.${a}) addOns);
      };

    # Per-engagement shell driven by a `.scrt/tools.toml`. `categories` selects
    # add-on bundles (base is always included); `extra` adds individual pkgs-sec
    # attrs; `exclude` trims by derivation name. Consumed by the engagement
    # template via the exposed `lib.mkEngagement` output.
    mkEngagement = { categories ? [], extra ? [], exclude ? [] }:
      let
        known = builtins.attrNames secBundles;
        bad = builtins.filter (c: !builtins.elem c known) categories;
        checked =
          if categories == []
          then throw "scrt: .scrt/tools.toml lists no categories — set e.g. categories = [ \"web\" ]"
          else if bad != []
          then throw "scrt: unknown categories in .scrt/tools.toml: ${builtins.concatStringsSep ", " bad} (known: ${builtins.concatStringsSep ", " known})"
          else categories;
        cats = [ "base" ] ++ checked;
        catPkgs = builtins.concatLists (map (c: secBundles.${c}) cats);
        extraPkgs = map (n: pkgs-sec.${n}) extra;
        keep = p: !builtins.elem (pkgs-sec.lib.getName p) exclude;
      in mkSecShellFromPackages {
        name = "engagement";
        banner = "engagement kit (${builtins.concatStringsSep "+" checked})";
        packages = builtins.filter keep (catPkgs ++ extraPkgs);
      };
  in
  {
    formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;

    # -------------------------------------------------------------------------
    # Project templates — bootstrap a new project with:
    #   nix flake init -t /path/to/nix-config#python
    # -------------------------------------------------------------------------
    templates = {
      python = {
        path        = ./templates/python;
        description = "Python devenv: security research, APIs, scraping, data analysis + Docker";
      };
      mkdocs = {
        path        = ./templates/mkdocs;
        description = "MkDocs documentation site for Cloudflare Pages";
      };
      engagement = {
        path        = ./templates/engagement;
        description = "HTB/CTF engagement dir: pinned security toolset + direnv + scans/loot/exploits layout";
      };
    };

    overlays = import ./overlays { inherit inputs; };

    # Builder consumed by scaffolded engagements (templates/engagement/flake.nix)
    # to compose a single devShell from a per-directory .scrt/tools.toml. It
    # closes over pkgs-sec for x86_64-linux, so this lib is system-specific
    # rather than a portable, cross-system flake lib.
    lib.mkEngagement = mkEngagement;

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
    # Tool bundles as buildable outputs — CI/canary surface for the devShells.
    #   nix build .#sec-web    — does every leaf in the web bundle still build?
    # `nix build .#sec-all` before a `nix flake update` lands tells you which
    # bundle broke, instead of finding out when a shell fails to enter mid-box.
    # -------------------------------------------------------------------------
    packages.${system} =
      (nixpkgs.lib.mapAttrs' (name: paths:
        nixpkgs.lib.nameValuePair "sec-${name}" (pkgs-sec.buildEnv {
          name = "sec-${name}";
          inherit paths;
          # Security tooling collides freely on share/man and bin/ helper names;
          # this env exists to prove the leaves build, not to be installed.
          ignoreCollisions = true;
        })) secBundles)
      // {
        sec-all = pkgs-sec.buildEnv {
          name = "sec-all";
          paths = builtins.concatLists (builtins.attrValues secBundles);
          ignoreCollisions = true;
        };

        # `scrt new <name>` — scaffold an engagement directory. Thin sugar over
        # `nix flake init -t`: it also fills in RHOST/LHOST and runs
        # `direnv allow` so the shell is live on `cd`.
        scrt = pkgs-sec.writeShellApplication {
          name = "scrt";
          runtimeInputs = with pkgs-sec; [ nix direnv git iproute2 gawk coreutils ];
          text = builtins.readFile ./pkgs/scrt.sh;
        };

        default = self.packages.${system}.scrt;
      };

    # -------------------------------------------------------------------------
    # Security devShells — one base kit plus opt-in add-on bundles, modeled on
    # the SCRT variants (https://github.com/alexrf45/SCRT).
    #
    #   nix develop            — everything (the default; no mid-box switching)
    #   nix develop .#web      — base + web only, for a lighter closure
    #   nix develop .#ad       — base + Active Directory / Windows
    #   nix develop .#forensics
    #   nix develop .#pwn      — pwn / RE / crypto  (`ctf` kept as an alias)
    #
    # Entered from a scaffolded engagement dir, every shell sources `.scrt/env`
    # and exports $RHOST/$LHOST. Pwn basics (pwntools/gdb/gef) also live in the
    # always-on dev-tools.nix.
    # -------------------------------------------------------------------------
    devShells.${system} =
      # base + exactly one add-on, for when the full closure isn't wanted.
      (nixpkgs.lib.mapAttrs (name: _: mkSecShell {
        inherit name;
        addOns = [ name ];
        banner = "base + ${name}";
      }) secAddOns)
      // {
        default = mkSecShell {
          name = "full";
          addOns = builtins.attrNames secAddOns;
          # \\$ so the banner advertises the variable names rather than having
          # bash expand them into store paths in the echo.
          banner = "full kit (\\$RUBEUS \\$CERTIFY \\$WINPEAS \\$NISHANG_DIR)";
        };

        # Kept so `nix develop .#ctf` and the `ctf` tmuxp session keep working.
        ctf = self.devShells.${system}.pwn;
      };
  };
}
