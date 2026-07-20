# Git Workflow

Work on a **feature branch off `main`** (`git switch -c <topic>`); open a PR into `main`.
**Never commit directly to `main`.** (The old "everything to `dev` first" flow is retired.)

## Commits

Conventional format — `<type>: <description>` — types: `feat fix refactor docs test chore perf ci`.

- Attribution is disabled globally (`~/.claude/settings.json`) — no Co-Authored-By trailer.
- Commits are **SSH-signed via 1Password** (`op-ssh-sign`); the 1Password app must be unlocked
  or the commit fails with `1Password: failed to fill whole buffer`. Ask the user to unlock, then retry.
- Avoid backticks in `-m` messages passed through the shell; use a single-quoted heredoc
  (`git commit -m "$(cat <<'EOF' … EOF)"`) so backticked words aren't run as commands.

## Pull requests

1. `git diff main...HEAD` for the full change set (not just the last commit).
2. Comprehensive summary; **state the verification** run (which `nix build` / `nixos-rebuild build`).
3. Push a new branch with `-u`. No `gh` CLI on thoth — use WebFetch for GitHub reads.
