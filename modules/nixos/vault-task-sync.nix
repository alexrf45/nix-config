{...}: {
  # ---------------------------------------------------------------------------
  # vault-task-sync OAuth material (thoth-only — sopsFile is thoth.yaml).
  #
  # The tool pushes 📅-dated vault tasks to Google Calendar. It needs two JSON
  # blobs that are real secrets and must never enter this repo, which is public:
  #
  #   credentials.json — the Google Cloud OAuth "Desktop app" client, including
  #                      its client_secret.
  #   token.json       — the cached refresh token. Anyone holding it can read
  #                      and write the calendar until it is revoked.
  #
  # src/config.ts already reads GOOGLE_CREDENTIALS / GOOGLE_TOKEN from the
  # environment, so pointing them at /run/secrets/... needs no code change.
  # The home-manager module does that wiring.
  #
  # Only `bun run src/auth.ts` ever WRITES token.json; sync.ts opens it
  # read-only and refreshes the access token in memory. 0400 is therefore
  # sufficient for the timer — re-consent is done by hand against the real
  # ~/.config/vault-task-sync/ path, then copied back into sops.
  #
  # ONE-TIME SETUP on thoth BEFORE the first rebuild that includes this module.
  # Activation FAILS if either key is missing:
  #
  #   sops-thoth secrets/thoth.yaml
  #   # add two top-level keys holding the raw file contents, as literal blocks:
  #   vault-task-sync-credentials: |
  #     {"installed":{"client_id":"...","client_secret":"...", ...}}
  #   vault-task-sync-token: |
  #     {"access_token":"...","refresh_token":"...", ...}
  #
  # Source them from the files the interactive auth flow already produced:
  #   cat ~/.config/vault-task-sync/credentials.json
  #   cat ~/.config/vault-task-sync/token.json
  #
  # If the refresh token is ever revoked, re-run the auth flow and update the
  # vault-task-sync-token key — nothing else changes.
  # ---------------------------------------------------------------------------
  sops.secrets."vault-task-sync-credentials" = {
    sopsFile = ../../secrets/thoth.yaml;
    mode = "0400";
    owner = "fr3d"; # read by the user timer, not root
  };

  sops.secrets."vault-task-sync-token" = {
    sopsFile = ../../secrets/thoth.yaml;
    mode = "0400";
    owner = "fr3d";
  };
}
