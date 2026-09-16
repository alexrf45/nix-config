<div align="center">

# ❄️ nix-config

**A reproducible NixOS flake for my personal laptop — `thoth`** (`horus` retired, config kept for revival).

Stable `nixos-26.05` · select `nixos-unstable` overlay · Home Manager · secrets via SOPS + age

![NixOS](https://img.shields.io/badge/NixOS-26.05-5277C3?style=flat-square&logo=nixos&logoColor=white)
![Nix Flakes](https://img.shields.io/badge/Nix-Flakes-7EBAE4?style=flat-square&logo=nixos&logoColor=white)
![Home Manager](https://img.shields.io/badge/Home_Manager-integrated-41439A?style=flat-square)
![License](https://img.shields.io/badge/License-GPLv3-3DA639?style=flat-square)

</div>

---

## Where to look

| Document | What's inside |
| --- | --- |
| [`CLAUDE.md`](./CLAUDE.md) | Architecture, hosts, structure, and key design decisions |
| [`docs/bootstrap.md`](./docs/bootstrap.md) | First-time install / setup |
| [`docs/hardware.md`](./docs/hardware.md) | Hardware, storage, and boot detail |

## Build / switch

```sh
sudo nixos-rebuild switch --flake .#<host>   # host = thoth  (horus is retired)
```

**Before landing changes**

- Run `nix flake check` and `nixos-rebuild build --flake .#<host>` for `thoth` (horus is retired and not required to build)
- Format with `nix fmt` (alejandra)
- Work on a branch, then PR into `main`
