{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.local.vaultTaskSync;

  # The tool is a small bun/TypeScript program living in a working checkout
  # rather than the Nix store. Its one runtime dependency (googleapis) resolves
  # through bun's own node_modules, which keeps this out of the non-deterministic
  # bun-FOD territory documented in pkgs/proton-drive-cli.nix. The trade is that
  # the checkout is a prerequisite — see the guard below.
  vault-task-sync = pkgs.writeShellApplication {
    name = "vault-task-sync";
    runtimeInputs = [pkgs.bun];
    text = ''
      checkout=${lib.escapeShellArg cfg.checkout}

      if [ ! -d "$checkout/src" ]; then
        echo "vault-task-sync: no checkout at $checkout" >&2
        echo "  git clone git@github.com:alexrf45/vault-task-sync.git $checkout" >&2
        echo "  cd $checkout && bun install" >&2
        exit 1
      fi

      if [ ! -d "$checkout/node_modules" ]; then
        echo "vault-task-sync: dependencies missing — run 'bun install' in $checkout" >&2
        exit 1
      fi

      export VAULT_ROOT=${lib.escapeShellArg cfg.vaultRoot}
      export VAULT_TASK_TZ=${lib.escapeShellArg cfg.timeZone}
      export VAULT_TASK_DURATION=${toString cfg.durationMinutes}
      export GOOGLE_CREDENTIALS=${lib.escapeShellArg cfg.credentialsPath}
      export GOOGLE_TOKEN=${lib.escapeShellArg cfg.tokenPath}

      cd "$checkout"
      exec bun run src/sync.ts "$@"
    '';
  };
in {
  # ---------------------------------------------------------------------------
  # vault-task-sync — push 📅-dated Obsidian tasks to Google Calendar.
  #
  # Provides the `vault-task-sync` command plus a systemd user timer. The OAuth
  # material comes from sops via modules/nixos/vault-task-sync.nix, which MUST
  # be imported on the same host — read its header for the one-time secret setup.
  #
  # IMPORT SCOPE: thoth only. The sops secrets live in secrets/thoth.yaml, and
  # the vault is only synced to this machine.
  #
  # The sync is push-only and idempotent (events upsert on a stable hashed id),
  # so running it on a timer is safe and a missed run costs nothing.
  # ---------------------------------------------------------------------------
  options.local.vaultTaskSync = {
    enable = lib.mkEnableOption "vault-task-sync timer";

    checkout = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/code/vault-task-sync";
      description = "Working checkout of github.com:alexrf45/vault-task-sync.";
    };

    vaultRoot = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/notes";
      description = "Vault scanned for 📅-dated tasks.";
    };

    timeZone = lib.mkOption {
      type = lib.types.str;
      default = "America/New_York";
      description = "Wall-clock zone for tasks carrying an ⏰ time.";
    };

    durationMinutes = lib.mkOption {
      type = lib.types.ints.positive;
      default = 60;
      description = "Length of a timed (⏰) event. Tasks carry a start, not a duration.";
    };

    credentialsPath = lib.mkOption {
      type = lib.types.str;
      default = "/run/secrets/vault-task-sync-credentials";
      description = "OAuth client JSON. Declared in modules/nixos/vault-task-sync.nix.";
    };

    tokenPath = lib.mkOption {
      type = lib.types.str;
      default = "/run/secrets/vault-task-sync-token";
      description = "Cached OAuth token JSON. Declared in modules/nixos/vault-task-sync.nix.";
    };

    onCalendar = lib.mkOption {
      type = lib.types.str;
      default = "*:0/30";
      description = "systemd OnCalendar expression for the sync timer.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [vault-task-sync];

    systemd.user.services.vault-task-sync = {
      Unit.Description = "Push dated Obsidian tasks to Google Calendar";
      Service = {
        Type = "oneshot";
        ExecStart = lib.getExe vault-task-sync;
      };
    };

    systemd.user.timers.vault-task-sync = {
      Unit.Description = "Periodic vault → Google Calendar sync";
      Timer = {
        OnCalendar = cfg.onCalendar;
        # The laptop is not always on; catch up on the next boot instead of
        # silently skipping every run that fell in a suspend window.
        Persistent = true;
        RandomizedDelaySec = "2m";
      };
      Install.WantedBy = ["timers.target"];
    };
  };
}
