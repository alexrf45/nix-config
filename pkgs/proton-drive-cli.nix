# proton-drive-cli — Proton's official Drive command-line client.
#
# Not in nixpkgs yet: PR #557198 (source build via bun) is open, and its
# predecessor #530138 was closed unmerged in Sept 2026 after three months of
# upstream retagging and non-deterministic bun FOD hashes. Once a package lands
# in nixos-unstable and holds still for a release or two, drop this file and
# switch to `pkgs-unstable.proton-drive-cli` — see overlays/additions.nix.
#
# We pin Proton's own prebuilt binary rather than rebuilding from source:
# upstream publishes per-version-immutable URLs plus a machine-readable manifest
# with SHA-512 checksums, which makes updates a two-line bump. (It also isn't
# reproducible from git: the released 0.8.0 binary reports commit 06e8c605 while
# the cli/v0.8.0 tag is 5491f2ee.)
#
# x64 (not x64-baseline) is correct for thoth — Tiger Lake has AVX2.
#
# Update procedure on a new release:
#   1. Read the current stable version and its linux/x64 checksum:
#        curl -s https://proton.me/download/drive/cli/version.json | jq -r \
#          '.Releases[] | select(.CategoryName=="Stable")
#           | .Version, (.Files[] | select(.Platform=="linux/x64") | .Sha512CheckSum)'
#   2. Bump version below, then fetch and hash the new binary:
#        nix store prefetch-file --json \
#          https://proton.me/download/drive/cli/<VERSION>/linux-x64/proton-drive
#      → copy "hash" into src.hash, and sha512sum the "storePath" it reports to
#        confirm it matches the checksum from step 1 before committing.
#
# Login is browser-based and the session lands in the OS secret store (libsecret
# — gnome-keyring is enabled in modules/nixos/security.nix). Set
# PROTON_DRIVE_CREDENTIALS_STORE=pass to use password-store instead.
#
# Changelog: https://github.com/ProtonDriveApps/sdk/blob/main/cli/CHANGELOG.md

{ lib, stdenv, fetchurl, autoPatchelfHook, makeWrapper, libsecret, glib }:

stdenv.mkDerivation (finalAttrs: {
  pname = "proton-drive-cli";
  version = "0.8.0";

  src = fetchurl {
    url = "https://proton.me/download/drive/cli/${finalAttrs.version}/linux-x64/proton-drive";
    hash = "sha256-lEPXcXGciSeQ2xfm8C7Nma18U1kzKfOmfHdnfc5XdzU=";
  };

  dontUnpack = true;

  # `bun build --compile` appends the JS bundle to the ELF; stripping drops it
  # and leaves a binary that just starts a bare bun REPL.
  dontStrip = true;

  nativeBuildInputs = [ autoPatchelfHook makeWrapper ];

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/proton-drive
    runHook postInstall
  '';

  # libsecret is dlopen'd at runtime, so it never appears in DT_NEEDED and
  # autoPatchelf can't see it — hand it over explicitly.
  postFixup = ''
    wrapProgram $out/bin/proton-drive \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libsecret glib ]}
  '';

  meta = {
    description = "Official Proton Drive command-line client";
    homepage = "https://github.com/ProtonDriveApps/sdk/tree/main/cli";
    changelog = "https://github.com/ProtonDriveApps/sdk/blob/main/cli/CHANGELOG.md";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "proton-drive";
  };
})
