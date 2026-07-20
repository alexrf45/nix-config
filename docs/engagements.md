# Engagements — quick reference

Disposable, per-box security toolchains. Each **engagement directory** owns a
`.scrt/tools.toml` that declares exactly which tool categories build into its
shell. `cd` in → direnv activates it; `rm -rf` → it's gone.

> Requires `dev` to be pushed (`git push origin dev`) so the engagement flake can
> resolve `github:alexrf45/nix-config/dev`. To test against uncommitted local
> changes, see [Local testing](#local-testing).

## TL;DR

```bash
scrt new acme-dc 10.10.11.5        # scaffold $SCRT_ROOT/acme-dc (default /home/data/engagements)
cd /home/data/engagements/acme-dc
$EDITOR .scrt/tools.toml           # set categories = ["ad", "web"]
cd .                               # (or `direnv reload`) → shell builds with your kit
```

`scrt ls` lists engagements. `scrt fix <name>` repairs a dir scaffolded before the
git-tracking fix (git-adds its flake so `use flake` stops erroring).

## The config: `.scrt/tools.toml`

`base` (nmap, masscan, socat, netcat, proxychains, chisel, openvpn, dns/http utils,
jq/rg/fd/bat…) is **always** included. You add categories on top.

```toml
# Add-on categories. base is implicit. Empty/missing = eval error, on purpose.
categories = ["web", "osint"]

# Individual nixpkgs attrs not worth a whole category (optional).
extra = ["gowitness", "kiterunner"]

# Trim tools from the assembled set, matched by runtime/derivation name (optional).
exclude = ["wpscan"]
```

| category | tools |
|---|---|
| `web` | subfinder, httpx, katana, nuclei, dnsx, naabu, amass, ffuf, gobuster, feroxbuster, sqlmap, whatweb, wpscan, mitmproxy, … |
| `ad` | impacket, netexec, bloodhound, evil-winrm, kerbrute, responder, enum4linux-ng, certipy + vendored SharpCollection/nishang/winPEAS/linPEAS/pspy |
| `forensics` | steghide, binwalk, volatility3, sleuthkit, zsteg, stegseek, john, hashcat, seclists, wordlists, … |
| `pwn` | radare2, ropgadget, one_gadget, gdb+gef, pwntools, z3, … |
| `osint` | theHarvester, recon-ng, dnsrecon, fierce, sherlock, maigret, holehe |
| `cloud` | awscli2, azure-cli, gcloud, kubectl, trivy, prowler, scoutsuite, pacu, kubescape |
| `wireless` | aircrack-ng, wifite2, reaverwps, bully, hcxtools, hcxdumptool, bettercap, kismet, cowpatty |
| `mobile` | apktool, jadx, dex2jar, frida-tools, objection, scrcpy, apksigner, apkeep |
| `c2` | metasploit, havoc, starkiller, sliver *(heavy — server ~267MB)* |

**Git rule:** the flake reads `tools.toml` from the git-tracked source. `scrt new`
stages it for you; later edits to that already-tracked file are picked up live on
the next `direnv reload`. A brand-new untracked file is invisible until `git add`.

## Examples

Web app box:

```toml
categories = ["web"]
```

AD/Windows box, drop the noisy wpscan, add a screenshotter:

```toml
categories = ["ad", "web"]
extra      = ["gowitness"]
exclude    = ["wpscan"]
```

CTF pwn/crypto:

```toml
categories = ["pwn"]
```

Cloud pentest:

```toml
categories = ["cloud", "osint"]
```

Red-team C2 (heavy closure — pulls Sliver):

```toml
categories = ["c2", "ad"]
```

## Ad-hoc shells (no engagement)

The parent flake still exposes each category directly, plus the full kit:

```bash
nix develop ~/nix-config           # full kit (every category)
nix develop ~/nix-config#web       # base + one category
nix develop ~/nix-config#ctf       # alias for #pwn
```

## Canary — catch a broken tool before a box

`mkShell` is all-or-nothing: one dead leaf kills the whole shell. Each category is
also a buildable output — run this before landing a `nix flake update`:

```bash
nix build .#sec-all                # or .#sec-web, .#sec-c2, …
```

## Local testing

Engagements pin the `dev` branch on GitHub. To exercise **uncommitted** working-tree
changes to the toolset:

```bash
# scaffold from the local template
SCRT_FLAKE="path:$HOME/nix-config" scrt new testbox
# resolve the builder from the local tree instead of github:.../dev
nix develop /home/data/engagements/testbox --override-input scrt path:$HOME/nix-config
```

## Adding a tool

- **In nixpkgs-unstable:** add its attr to the relevant list in `secBundles`
  (`flake.nix`), or drop it into a `tools.toml` `extra = [...]` for one-offs.
- **Not in nixpkgs:** vendor it under `pkgs/<tool>.nix` (see `pkgs/sliver.nix` or
  `pkgs/linpeas.nix` for the pattern — pin the release asset with an SRI hash) and
  register it in `overlays/additions.nix`.
- Always verify with `nix build .#sec-<category>` — a tool that imports
  `pkg_resources` (dead on modern Python, e.g. old `wfuzz`/`kube-hunter`) will take
  the whole category down.
