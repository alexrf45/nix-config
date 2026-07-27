# Security-research tooling — archived

**Retired:** 2026-07 (branch `chore/retire-security-tooling`).
**Why:** narrowing to security research on a case-by-case basis. Day-to-day is now writing,
research, and development, so the offensive/pentest toolchain no longer belongs in the always-on
config. Nothing is lost — the tooling lives in git history and is documented here for revival.

**Pre-removal state:** everything below existed at commit **`de2ed70`** (the tip of `main`
immediately before the removal). That commit is the definitive reference point for restoring.

---

## What was removed

### Flake (`flake.nix`)
- `pkgs-sec` — the unstable pkgs set (with `android_sdk.accept_license`) that backed the shells.
- `secBundles` — the master tool lists, split into categories:
  `base` (recon/pivoting, always on) + `web`, `ad`, `forensics`, `pwn`, `osint`, `cloud`,
  `wireless`, `mobile`, `c2`.
- `secAddOns`, `mkSecShellFromPackages`, `mkSecShell`, `mkEngagement`, `lib.mkEngagement`.
- `packages.<system>.{sec-<cat>, sec-all, scrt, default}` — the build canaries + the `scrt`
  scaffolder package.
- `devShells.<system>.*` — `default` (full kit), the per-category shells, and the `ctf` alias.
- The `engagement` flake template entry.

### Vendored derivations (`pkgs/`)
Deleted: `linpeas.nix`, `winpeas.nix`, `pspy.nix`, `sharpcollection.nix`, `nishang.nix`,
`sliver.nix`, and the `scrt.sh` scaffolder script. Their registration lines were removed from
`overlays/additions.nix` (which now only carries `_1password-cli-beta`).

### On-host Home-Manager tooling
- `modules/home-manager/dev-tools/security.nix` — deleted (nmap, gobuster, ffuf, sqlmap, hydra,
  john, hashcat, burpsuite, metasploit, gef, pwntools, gdb, binutils, netcat, tcpdump).
- `modules/home-manager/security.nix` — deleted (proxychains-ng + config, the `scrt` install,
  pentest aliases `nmapq`/`nmapfull`/`smbserve`/`tunip`).
- `tmuxp/ctf.yaml`, `tmuxp/htb.yaml` — deleted; the `htb` OpenVPN alias and stale `kali` tmuxp
  alias were dropped from `shell.nix`.

### Scaffolding, docs, and agent metadata
- `templates/engagement/` — the whole HTB/CTF engagement scaffold tree.
- `docs/engagements.md`, `.claude/commands/new-engagement.md`,
  `.claude/skills/security-engagements/`.
- Security-bundle references were edited out of `CLAUDE.md`, `.claude/commands/flake-update.md`,
  and `.claude/rules/common/*.md`.

### What was **kept** (deliberately)
- System hardening + secrets: `modules/nixos/security.nix` (SSH/sudo/polkit/keyring/1Password/
  **wireshark**/user account), `modules/nixos/smartcard.nix`, `dev-tools/secrets.nix` (sops/age).
- A minimal general net/debug subset moved into `modules/home-manager/packages.nix`:
  `nmap`, `netcat-gnu`, `tcpdump`, `gdb`, `binutils`.
- General shell helpers relocated to `shell.nix`: `serve`, `servep`, `ports`, `myip`, `b64d`,
  `b64e`, `urldecode`, `urlencode`.
- The general `devenv` tool and the `python` / `mkdocs` flake templates.

---

## How to restore

The removal is a self-contained change on the `chore/retire-security-tooling` branch (later
merged to `main`). Pick whichever fits:

**Full revert** — undo the removal commit(s):
```bash
git log --oneline --grep 'retire.*security' main   # find the removal commit <sha>
git revert <sha>
```

**Selective restore** — pull individual pieces back from the pre-removal state (`de2ed70`):
```bash
git checkout de2ed70 -- flake.nix
git checkout de2ed70 -- overlays/additions.nix
git checkout de2ed70 -- pkgs/                       # vendored tools + scrt.sh
git checkout de2ed70 -- modules/home-manager/security.nix
git checkout de2ed70 -- modules/home-manager/dev-tools/security.nix
git checkout de2ed70 -- templates/engagement docs/engagements.md
git checkout de2ed70 -- .claude/skills/security-engagements .claude/commands/new-engagement.md
```
After restoring files, re-add the module imports that were dropped:
`modules/home-manager/dev-tools/default.nix` (`./security.nix`) and both
`home-manager/{thoth,horus}/fr3d/default.nix` (`../../../modules/home-manager/security.nix`),
then re-wire the `tmuxp/*.yaml` sources in `modules/home-manager/packages.nix`.

Verify with `nix flake check`, `nix build .#sec-all`, and `nixos-rebuild build --flake .#<host>`.

---

## Rebuild-from-scratch sources

If the git history is ever unavailable, the tooling was modeled on these upstreams:
- SCRT shell variants — <https://github.com/alexrf45/SCRT>
- <https://github.com/alexrf45/h0me>, <https://github.com/alexrf45/dotfiles> (mirrored in `dotfiles/`)

The vendored `pkgs/*.nix` derivations each carried an update header pinning a GitHub release
asset by SRI hash (linPEAS/winPEAS/pspy/SharpCollection/Nishang/Sliver).
