# Code review

**Review before opening a PR**, and always when touching boot/hardware, secrets, or the
security devShells.

## Checklist

- Evaluates & builds — `nix flake check`, plus the relevant `nixos-rebuild build` / `nix build`.
- No plaintext secrets or committed keys (see the security rule).
- Modules stay small and host-split; formatted with `alejandra`.
- Security-bundle changes: `nix build .#sec-<cat>` green — no dead leaves (e.g. Python tools
  importing `pkg_resources`).
- Boot-critical changes flagged: thoth `vmd` initrd module, horus PRIME bus IDs.
- Vendored pkg bumps keep their SRI hash + update header accurate.

## Severity

| Level | Meaning | Action |
|-------|---------|--------|
| CRITICAL | secret leak, or an unbootable/unbuildable host | **block** |
| HIGH | build break, or a broken security bundle | **block** |
| MEDIUM | maintainability / style | advisory |
| LOW | minor suggestion | optional |

Use the **security-reviewer** agent for secrets, boot/GPU, and security-tooling changes.
