# Security

This is a configuration repo, not an application — the real risks are **secrets** and
**supply chain**, not SQLi/XSS.

## Secrets

- NEVER commit plaintext secrets. Use **SOPS + age**; encrypted `.yaml` lives in `secrets/`.
- The age private key (`~/.config/sops/age/keys.txt`) is never in the repo.
- sops-nix decrypts via **activation scripts**, not a systemd service → secrets appear at
  `/run/secrets/<name>` after activation. Never reference `sops-install-secrets.service` in units.
- Don't hardcode hosts/creds in Nix.

## Supply chain

- Prefer nixpkgs over vendoring. Vendored derivations (`pkgs/*.nix`) pin release assets with
  SRI hashes and carry an update header — follow it to bump.
- `allowUnfree` is enabled only where unfree packages are actually needed (NVIDIA, 1Password,
  the `pkgs-unstable` overlay).

If something looks like a leaked secret or key, **stop** and use the **security-reviewer** agent.
