{ inputs }:
# Attribute overrides for existing nixpkgs derivations.
# Usage: override version pins, apply patches, etc.
final: prev: {
  # Example:
  # somePackage = prev.somePackage.override { enableFeature = true; };

  # spotify-player pinned to upstream v0.25.1 (nixpkgs stable ships 0.23.0,
  # unstable 0.24.1 — no nixpkgs PR for 0.25.x exists yet).
  #
  # Why: Spotify started hard-throttling the bundled, shared `ncspot` client ID
  # that every spotify_player install uses (upstream issue #1073). On 0.23.0 a
  # single 429 permanently wedges the playback pane, because initialize_playback
  # abandons its retry loop on the first error (upstream issue #1074) — the
  # observed symptom was "get token: no access token" then "Token is not valid"
  # repeating every 5s until restart.
  #
  # v0.25.0 (PR #1077) reworked the Web API layer: custom client IDs with
  # automatic ncspot fallback, hardened token refresh, and rate-limit retry.
  # Note it changed the token cache format, so the first run re-authenticates.
  #
  # Remove this override once nixpkgs ships >= 0.25.1.
  spotify-player = inputs.spotify-player.defaultPackage.${prev.stdenv.hostPlatform.system};
}
