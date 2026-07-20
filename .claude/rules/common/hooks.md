# Hooks & settings

Claude Code settings live in `~/.claude/settings.json` (global) and `.claude/settings.local.json`
(repo). Notable for this repo:

- Commit attribution is **disabled** globally (no Co-Authored-By trailer).
- Automated behaviors ("whenever X, do Y") require **hooks** in settings.json — the harness runs
  them, not the model, so they can't live in memory/preferences. Use the `update-config` skill to
  edit settings.
- Hook types: `PreToolUse` (validate/modify before a tool runs), `PostToolUse` (e.g. auto-format),
  `Stop` (final checks).

Keep an eye on permission prompts; add trusted read-only commands to the repo settings allowlist
rather than disabling permission checks wholesale.
