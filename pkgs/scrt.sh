# scrt — scaffold a disposable engagement directory.
#
# The engagement directory, not the shell, is the unit of disposability:
# `cd` in and direnv activates the pinned toolset; `rm -rf` and it's gone.
# The per-directory flake.lock records the exact toolset a box was solved with.
#
# Usage:
#   scrt new <name> [rhost] [lhost]
#   scrt ls
#
# Override the root with SCRT_ROOT (default /home/data/engagements).

set -euo pipefail

SCRT_ROOT="${SCRT_ROOT:-/home/data/engagements}"
# `dev` while the engagement workflow is under user testing; drop the branch
# suffix once it lands on main. Keep in sync with templates/engagement/flake.nix.
SCRT_FLAKE="${SCRT_FLAKE:-github:alexrf45/nix-config/dev}"

usage() {
  cat <<'EOF'
scrt — disposable engagement directories

  scrt new <name> [rhost] [lhost]   scaffold and activate a new engagement
  scrt fix <name>                   stage an existing engagement's flake into git
  scrt ls                           list existing engagements

Env:
  SCRT_ROOT    engagement root       (default /home/data/engagements)
  SCRT_FLAKE   toolset flake to pin  (default github:alexrf45/nix-config)
EOF
}

# Best-effort default: the tun0 address if a VPN is up. HTB/CTF work is almost
# always over a VPN, and typing the wrong LHOST into a payload is a silent
# failure that costs a lot more than this three-line guess.
#
# Must not fail: no VPN up is the normal case when scaffolding ahead of time,
# and under `set -euo pipefail` a failing pipeline here would abort the whole
# command before it creates anything. Always exits 0, possibly empty.
default_lhost() {
  ip -4 -o addr show tun0 2>/dev/null | awk '{print $4}' | cut -d/ -f1 | head -1 || true
}

cmd_new() {
  local name="${1:-}" rhost="${2:-}" lhost="${3:-}"
  if [ -z "$name" ]; then
    echo "scrt: new requires a name" >&2
    usage >&2
    exit 2
  fi

  local dir="$SCRT_ROOT/$name"
  if [ -e "$dir" ]; then
    echo "scrt: $dir already exists — refusing to overwrite" >&2
    exit 1
  fi

  [ -n "$lhost" ] || lhost="$(default_lhost)"

  mkdir -p "$dir"
  cd "$dir"
  nix flake init -t "$SCRT_FLAKE#engagement"

  # The template ships placeholders; fill in what we know.
  cat > .scrt/env <<EOF
ENGAGEMENT=$name
RHOST=$rhost
LHOST=$lhost
EOF

  sed -i "s|@ENGAGEMENT@|$name|g" README.md

  # A git repo per engagement makes the notes/loot diffable and the whole thing
  # trivially archivable once the box is retired.
  git init -q
  git add -A          # flakes only see git-tracked files; stage them or `use flake` errors
  direnv allow

  echo
  echo "scrt: engagement '$name' ready at $dir"
  [ -n "$rhost" ] || echo "scrt: RHOST unset — set it in $dir/.scrt/env"
  [ -n "$lhost" ] || echo "scrt: LHOST unset (no tun0?) — set it in $dir/.scrt/env"
  echo "scrt: cd $dir  (direnv will activate the toolset)"
}

# Repair an engagement scaffolded before `scrt new` learned to stage the tree:
# an untracked flake.nix in a git work tree is invisible to the flake evaluator,
# so `use flake` errors until the files are added.
cmd_fix() {
  local name="${1:-}"
  if [ -z "$name" ]; then
    echo "scrt: fix requires a name" >&2
    usage >&2
    exit 2
  fi

  local dir="$SCRT_ROOT/$name"
  [ -d "$dir" ]           || { echo "scrt: $dir does not exist" >&2; exit 1; }
  [ -f "$dir/flake.nix" ] || { echo "scrt: $dir has no flake.nix — not an engagement dir" >&2; exit 1; }

  cd "$dir"
  [ -d .git ] || git init -q
  git add -A
  echo "scrt: '$name' flake tracked — 'cd $dir' now activates the toolset"
}

cmd_ls() {
  if [ ! -d "$SCRT_ROOT" ]; then
    echo "scrt: no engagements yet ($SCRT_ROOT does not exist)"
    return 0
  fi
  find "$SCRT_ROOT" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort
}

case "${1:-}" in
  new)          shift; cmd_new "$@" ;;
  fix)          shift; cmd_fix "$@" ;;
  ls|list)      cmd_ls ;;
  -h|--help|"") usage ;;
  *)            echo "scrt: unknown command '$1'" >&2; usage >&2; exit 2 ;;
esac
