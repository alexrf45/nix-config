# Secrets

Secrets are encrypted with [SOPS](https://github.com/getsops/sops) + [age](https://age-encryption.org/).

## Setup

### 1. Generate your age key (run once on the machine)

```bash
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
```

The output will print your **public key** (starts with `age1...`).
Copy it and update the `age:` block in `../.sops.yaml`.

**NEVER commit `~/.config/sops/age/keys.txt` to this repo.**

### 2. Update `.sops.yaml`

Replace the `age1REPLACE...` placeholder in `.sops.yaml` with your actual public key.

### 3. Create or edit a secrets file

```bash
sops secrets/horus.yaml
```

SOPS opens `$EDITOR`. Add secrets in YAML format:

```yaml
# Example structure
github_token: "ghp_..."
aws_access_key_id: "AKIA..."
wifi_password: "hunter2"
```

## Usage in NixOS

Secrets declared in `modules/nixos/security.nix` via the `sops.secrets.*` block.
After `nixos-rebuild switch`, decrypted secrets are available at `/run/secrets/<name>`.

## Rotation

To rotate the age key or add a new key:

```bash
# Add the new public key to .sops.yaml, then:
sops updatekeys secrets/horus.yaml
```

## Secret inventory

| Secret name    | Module that uses it | Notes |
|----------------|---------------------|-------|
| (none yet)     | —                   | Add rows as secrets are added |
