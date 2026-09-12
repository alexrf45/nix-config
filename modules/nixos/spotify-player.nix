{ ... }:
{
  # ---------------------------------------------------------------------------
  # spotify_player custom Spotify client ID (thoth-only — sopsFile is thoth.yaml).
  #
  # spotify_player ships a bundled client ID that is the shared `ncspot` one, so
  # every install on earth competes for a single Spotify API quota. Spotify now
  # throttles it hard (upstream issue #1073). Registering a personal app at
  # https://developer.spotify.com/dashboard moves most requests onto your own
  # quota; endpoints a new app isn't cleared for fall back to ncspot automatically
  # as of v0.25.0.
  #
  # The ID is a PKCE public client identifier, not a cryptographic secret — there
  # is no client secret in this flow. It lives in sops anyway because this repo is
  # public, and publishing it would invite exactly the quota-sharing problem the
  # custom ID exists to solve.
  #
  # ONE-TIME SETUP on thoth BEFORE the first rebuild that includes this module:
  #   sops-thoth secrets/thoth.yaml
  #   # add a top-level key holding the raw 32-char hex ID, nothing else:
  #   spotify-client-id: "<client ID from the Spotify developer dashboard>"
  # Activation fails if this key is missing.
  #
  # Then point the app at it — in ~/.config/spotify-player/app.toml, replace the
  # `client_id = "..."` line with:
  #   client_id_command = "cat /run/secrets/spotify-client-id"
  # and re-run `spotify_player authenticate` (v0.25.0 changed the token cache
  # format, so a re-auth is required regardless).
  #
  # The app's registered redirect URI must match app.toml's login_redirect_uri,
  # which defaults to http://127.0.0.1:8989/login — add that exact string to the
  # Spotify dashboard app's allowed redirect URIs.
  # ---------------------------------------------------------------------------
  sops.secrets."spotify-client-id" = {
    sopsFile = ../../secrets/thoth.yaml;
    mode = "0400";
    owner = "fr3d"; # readable by the user running spotify_player, not just root
  };
}
