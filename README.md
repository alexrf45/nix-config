# nix-config

My NixOS configs and modules — built for **security research, offensive and
defensive**.

This flake ports the toolkit from my [SCRT](https://github.com/alexrf45/scrt)
Docker environment into reusable Nix modules: the same offensive tool
categories (network, web/bug-bounty, Active Directory, OSINT, passwords,
pivoting, privesc, CTF, wireless) plus a defensive/blue-team layer (IDS,
forensics/DFIR, malware analysis, monitoring, hardening), and a faithful port
of the zsh + starship + tmux + neovim shell environment.

## Layout

```
flake.nix                     # inputs, modules, example host + HM profile
modules/
  security/
    options.nix               # securityLab.* toggles (shared by NixOS + HM)
    catalog.nix               # category -> nixpkgs package lists
    select.nix                # resolves toggles into a flat package list
    nixos.nix                 # NixOS module (environment.systemPackages)
    home.nix                  # Home Manager module (home.packages)
  home/                       # shell environment (ported from SCRT resources/)
    shell.nix                 # zsh: aliases, functions, fzf, proxychains
    starship.nix              # prompt (UTC clock, VPN IP, $TARGET segments)
    tmux.nix                  # tmux config + engagement status bar
    neovim.nix                # default editor, light baseline
    tools.nix                 # operator CLI quality-of-life tools
hosts/lab/                    # example NixOS host (replace hardware-config)
home/fr3d.nix                 # example standalone Home Manager profile
```

## Usage

### As a NixOS host

1. Generate real hardware config on the target:
   ```sh
   sudo nixos-generate-config --show-hardware-config > hosts/lab/hardware-configuration.nix
   ```
2. Pick your categories in `hosts/lab/default.nix` (`securityLab.*`).
3. Build:
   ```sh
   sudo nixos-rebuild switch --flake .#lab
   ```

### As a standalone Home Manager profile (non-NixOS: Kali, Ubuntu, cloud box)

Installs everything into your user profile without touching the system:
```sh
nix run home-manager/master -- switch --flake .#fr3d
```

### Pulling the modules into your own config

```nix
# flake.nix inputs
inputs.nix-config.url = "github:alexrf45/nix-config";

# NixOS
modules = [ inputs.nix-config.nixosModules.securityLab ];

# Home Manager
imports = [
  inputs.nix-config.homeManagerModules.securityLab  # the toolkit
  inputs.nix-config.homeManagerModules.shell         # the zsh/tmux/starship env
];
```

## Toggles

Every category defaults to **off**. Turn on what you need:

```nix
securityLab = {
  enable = true;
  offensive = {
    all = false;            # or flip individual categories below
    network = true;         # nmap, masscan, netdiscover, snmp, proxychains, ...
    web = true;             # ffuf, sqlmap, nuclei, subfinder, katana, dnsx, ...
    activeDirectory = true; # netexec (nxc), impacket, bloodhound, kerbrute, ...
    osint = true;           # theHarvester, recon-ng, cewl, exiftool
    passwords = true;       # hashcat, john, hydra, crunch, ...
    pivoting = true;        # chisel, ligolo-ng, sshuttle
    privesc = true;         # pspy, metasploit
    exploitation = false;   # metasploit, searchsploit
    ctf = true;             # gdb+pwndbg, radare2, pwntools, volatility3, ...
    wireless = false;       # aircrack-ng, bettercap, kismet
  };
  defensive = {
    ids = true;             # suricata, zeek
    forensics = true;       # sleuthkit, volatility3, testdisk, ddrescue
    malwareAnalysis = true; # yara, clamav, radare2
    monitoring = true;      # wireshark/tshark, termshark, ngrep, lnav, goaccess
    hardening = true;       # lynis, rkhunter, trivy, grype, osv-scanner
  };
  secrets = true;           # age, sops, gnupg, step-cli, openssl
  extras = false;           # opt-in extras — see note below
};
```

## A note on `extras` and package names

The default (non-`extras`) catalog uses **high-confidence nixpkgs attribute
names** so the config always evaluates cleanly. Some SCRT tools have attribute
names that drift between nixpkgs revisions or aren't packaged at all
(ProjectDiscovery `httpx`/`notify`, `certipy`, `sn0int`, `peass-ng`,
`one_gadget`, SageMath, `snort`, ...). Those live commented-out in the `extras`
block of `modules/security/catalog.nix`.

Before enabling `securityLab.extras = true`, verify each one and uncomment it:
```sh
nix search nixpkgs <tool>
```

> This config was authored without a local Nix to evaluate against. Run
> `nix flake check` and `nixos-rebuild build --flake .#lab` before merging; if
> any attribute name fails to resolve, `nix search nixpkgs <tool>` gives you the
> current name.

## SCRT → Nix mapping notes

- **Container scenarios → toggles.** `Dockerfile.web` ≈ `offensive.web`,
  `Dockerfile.ad` ≈ `offensive.activeDirectory` + `pivoting` + `privesc`,
  `Dockerfile.ctf` ≈ `offensive.ctf`.
- **apt/pip/git tools → nixpkgs.** Everything fetched via apt, pip, or raw
  GitHub releases in `sources/*.sh` is replaced by a pinned, reproducible
  nixpkgs derivation.
- **Shell env ported 1:1.** Aliases, functions (`extract`, `webserver`,
  `cert-gen`, `mkcd`, ...), the starship prompt, tmux bindings, and the
  proxychains config all come straight from SCRT `resources/`. The old
  apt-based daily aliases (`i`, `update`, `upgrade`) are remapped to their Nix
  equivalents on the same keys.
- **`cme` → `nxc`.** crackmapexec is `netexec` in nixpkgs (provides `nxc`).
- **`batcat` → `bat`.** nixpkgs ships it as `bat`.
