{config, ...}: {
  # ---------------------------------------------------------------------------
  # SearXNG — private, loopback-only metasearch instance.
  #
  # Backs the Kindly web-search MCP server (SEARXNG_BASE_URL=http://127.0.0.1:8888).
  # Bound to 127.0.0.1 only, so search queries never leave this machine for a
  # third-party search API. The JSON format is enabled because Kindly's SearXNG
  # provider needs it (it is off by default).
  #
  # secret_key is SearXNG's Flask signing key (session/preferences cookies and
  # signed image-proxy URLs). It is provided via an env file rendered from SOPS
  # and substituted into settings.yml at service start ($SEARX_SECRET_KEY) — it
  # is never written to the Nix store.
  #
  # ONE-TIME SETUP on thoth BEFORE the first rebuild that includes this module:
  #   sops-thoth secrets/thoth.yaml
  #   # add a top-level key holding the env line:
  #   searxng-environment: "SEARX_SECRET_KEY=<paste `openssl rand -hex 32`>"
  # Activation fails if this key is missing.
  # ---------------------------------------------------------------------------
  sops.secrets."searxng-environment" = {
    sopsFile = ../../secrets/thoth.yaml;
    mode = "0400";
  };

  services.searx = {
    enable = true;
    redisCreateLocally = true; # local valkey/redis backend for the limiter/cache
    environmentFile = config.sops.secrets."searxng-environment".path;

    settings = {
      server = {
        bind_address = "127.0.0.1"; # loopback only — never exposed
        port = 8888;
        secret_key = "$SEARX_SECRET_KEY"; # substituted from environmentFile
      };
      # Kindly queries the JSON API; HTML kept for manual browser use.
      search.formats = ["html" "json"];
    };
  };
}
