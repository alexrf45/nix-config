# imessage-exporter — export iMessage/SMS from an iOS backup or macOS chat.db
# to TXT/HTML, including attachments. Not in nixpkgs, so built from crates.io.
#
# Update procedure on a new release:
#   1. Bump version below.
#   2. nix store prefetch-file --json \
#        https://crates.io/api/v1/crates/imessage-exporter/<VERSION>/download
#      → copy the "hash" into src.hash.
#   3. Set cargoHash = lib.fakeHash, build once, copy the "got:" hash in.
#
# Upstream: https://github.com/ReagentX/imessage-exporter

{ lib, rustPlatform, fetchCrate }:

rustPlatform.buildRustPackage rec {
  pname = "imessage-exporter";
  version = "4.2.0";

  src = fetchCrate {
    inherit pname version;
    hash = "sha256-OoAFIm6pxoAXjcl4sVchB5UeDHIQnRtK16NsAsHj790=";
  };

  cargoHash = "sha256-rpOFigqPmgBbXdsZotE6whS3YBGWToh71zgBs1povuk=";

  # Upstream's test suite depends on locale/timezone/fixture state absent in the
  # Nix build sandbox (mass formatting-test failures); the binary compiles clean.
  doCheck = false;

  meta = {
    description = "Export iMessage data (from an iOS backup or chat.db) to TXT/HTML with attachments";
    homepage = "https://github.com/ReagentX/imessage-exporter";
    license = lib.licenses.gpl3Only;
    mainProgram = "imessage-exporter";
  };
}
