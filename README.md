# nix-config

My NixOS flake for two personal laptops (`horus`, `thoth`) — stable `nixos-26.05` with a select
`nixos-unstable` overlay, Home Manager integrated as a NixOS module, secrets via SOPS + age.

## Where to look

- **[`CLAUDE.md`](./CLAUDE.md)** — architecture, hosts, structure, and key design decisions
- **[`docs/bootstrap.md`](./docs/bootstrap.md)** — first-time install / setup
- **[`docs/hardware.md`](./docs/hardware.md)** — hardware, storage, and boot detail
- **Living review & recovery guide** — snapshot, roadmap, and break/revert reference in the private
  `lifeos-work` repo (`nix-config/living-review.md`)

## Build / switch

```sh
sudo nixos-rebuild switch --flake .#<host>   # host = horus | thoth
```

Verify before landing changes: `nix flake check` and `nixos-rebuild build --flake .#<host>` (both
hosts for shared-module edits). Format with `nix fmt` (alejandra). Work on a branch, PR into `main`.
