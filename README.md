<div align="center">

# ❄️ nix-config

**A reproducible NixOS flake for two personal laptops — `horus` & `thoth`.**

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
| Living review & recovery guide | Snapshot, roadmap, and break/revert reference — private `lifeos-work` repo (`nix-config/living-review.md`) |

## Build / switch

```sh
sudo nixos-rebuild switch --flake .#<host>   # host = horus | thoth
```

**Before landing changes**

- Run `nix flake check` and `nixos-rebuild build --flake .#<host>` — both hosts for shared-module edits
- Format with `nix fmt` (alejandra)
- Work on a branch, then PR into `main`
