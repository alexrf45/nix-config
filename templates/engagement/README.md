# @ENGAGEMENT@

| | |
|---|---|
| Target | |
| OS | |
| Difficulty | |
| Started | |

## Toolset

`nix develop` (or `cd` with direnv) builds **one** shell from `.scrt/tools.toml`.
`base` (recon/pivoting/file utils) is always included; add categories on top:

| category | what |
|---|---|
| `web` | subfinder, httpx, katana, nuclei, ffuf, gobuster, feroxbuster, sqlmap, wpscan, … |
| `ad` | impacket, netexec, bloodhound, evil-winrm, kerbrute, responder, certipy + vendored SharpCollection/nishang/winPEAS/linPEAS/pspy |
| `forensics` | steghide, binwalk, volatility3, sleuthkit, stegseek, john, hashcat, seclists, … |
| `pwn` | radare2, ropgadget, one_gadget, gdb+gef, pwntools, z3, … |
| `osint` | theHarvester, recon-ng, dnsrecon, fierce, sherlock, maigret, holehe |
| `cloud` | awscli2, azure-cli, gcloud, kubectl, trivy, prowler, scoutsuite, pacu, kube-hunter, kubescape |
| `wireless` | aircrack-ng, wifite2, reaverwps, bully, hcxtools, hcxdumptool, bettercap, kismet, cowpatty |
| `mobile` | apktool, jadx, dex2jar, frida-tools, objection, scrcpy, apksigner, apkeep |
| `c2` | metasploit, havoc, starkiller, sliver (heavy — ~267MB server) |

```toml
# .scrt/tools.toml
categories = ["web", "osint"]
extra      = ["gowitness"]   # individual nixpkgs attrs, optional
exclude    = ["wpscan"]      # drop by tool name, optional
```

An empty/missing `categories` is a hard error — each box declares its own kit.
`.scrt/tools.toml` is git-tracked (flakes only see tracked files); `scrt new`
stages it, and later edits are picked up on the next `direnv reload`.

## Credentials

<!-- user:pass / hash / key — as found, with where it came from -->

## Foothold

## Privesc

## Notes
