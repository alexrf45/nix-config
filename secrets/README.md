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

Replace the `age1...` placeholder in `.sops.yaml` with your actual public key.

### 3. Create or edit a secrets file

```bash
sops secrets/thoth.yaml
```

SOPS opens `$EDITOR`. Add secrets in YAML format.

## Usage in NixOS

Secrets are declared via `sops.secrets.*` in the module that uses them.
After `nixos-rebuild switch`, decrypted secrets are available at `/run/secrets/<name>`.

## Secret files

| File | Host | Description |
|------|------|-------------|
| `thoth.yaml` | thoth | All thoth secrets (LUKS key, SMB credentials) |

## Secret inventory

| Secret name                   | File           | Module that uses it                  | Notes |
|-------------------------------|----------------|--------------------------------------|-------|
| `luks-sda-key`                | `thoth.yaml`   | `hosts/thoth/luks-data-drive.nix`   | Base64-encoded LUKS keyfile for /dev/sda |
| `smb-home-drive-credentials`  | `thoth.yaml`   | `hosts/thoth/storage.nix`           | NAS credentials file (username/password/domain) |

## Rotation

To rotate the age key or add a new key:

```bash
# Add the new public key to .sops.yaml, then:
sops updatekeys secrets/thoth.yaml
```

---

## Setting up secrets/thoth.yaml

Run `sops secrets/thoth.yaml` from the repo root and populate both secrets:

```yaml
luks-sda-key: "<base64-encoded keyfile — see LUKS setup below>"
smb-home-drive-credentials: |
  username=myuser
  password=mypass
  domain=WORKGROUP
```

---

## Setting up the /dev/sda LUKS drive (thoth)

Run these steps once on the physical machine **before** `nixos-rebuild switch`:

```bash
# 1. Format /dev/sda with LUKS (DESTRUCTIVE — all data on /dev/sda will be lost)
cryptsetup luksFormat /dev/sda

# 2. Generate a 2 KiB random keyfile and register it as a LUKS key slot
dd if=/dev/urandom bs=512 count=4 > /tmp/luks-sda.key
cryptsetup luksAddKey /dev/sda /tmp/luks-sda.key

# 3. Encode the keyfile for YAML storage and copy the output
base64 -w0 /tmp/luks-sda.key

# 4. Add to secrets/thoth.yaml (from the repo root):
sops secrets/thoth.yaml
# Set luks-sda-key to the base64 output from step 3.

# 5. Record the drive UUID and update hosts/thoth/luks-data-drive.nix
blkid /dev/sda
# Replace driveUuid = "CHANGEME" with the UUID shown.

# 6. Format the filesystem inside the LUKS container
cryptsetup luksOpen --key-file /tmp/luks-sda.key /dev/sda sda-data
mkfs.ext4 -L data /dev/mapper/sda-data
cryptsetup luksClose sda-data

# 7. Shred the plaintext keyfile — it now lives only in SOPS
shred -u /tmp/luks-sda.key

# 8. Apply the configuration
sudo nixos-rebuild switch --flake .#thoth
```

After activation the drive will be opened automatically at boot via
`cryptsetup-sda-data.service` and mounted at `/mnt/data`.

To open/close manually:

```bash
sudo systemctl start  cryptsetup-sda-data.service   # open + mount
sudo systemctl stop   cryptsetup-sda-data.service   # unmount + close
```
