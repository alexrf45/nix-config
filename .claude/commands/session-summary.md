---
description: Write a dated summary of this session's work to docs/sessions/
argument-hint: "[topic-slug]"
---

Capture what happened in the current session as a durable markdown record. Run this before
wrapping up a complete session.

## Steps

1. **Determine the date** — use today's date (`date +%F`) for the filename and heading.
2. **Pick a slug** — use `$1` if given, else derive a short kebab-case slug from the session's
   main topic (e.g. `retire-security-tooling`).
3. **Write** to `docs/sessions/<YYYY-MM-DD>-<slug>.md`. If that path already exists (a second
   session on the same topic/day), append `-2`, `-3`, … so nothing is overwritten.
4. Base the content **only on what actually happened this session** — do not invent work.
   Pull the real branch names, PR numbers, commit SHAs, and file paths from the conversation
   and from `git log --oneline` / `git branch --show-current`.
5. Keep it scannable: short sections, concrete file paths, and the exact verification commands
   that were run (with their outcome). Prefer the template below.
6. After writing, tell the user the file path. Do **not** commit unless the user asks — if they
   do, use a feature branch off `main` (never commit to `main` directly) and a
   `docs: session summary …` message.

## Template

```markdown
# Session summary — <YYYY-MM-DD>

**Topic:** <one line>
**Branches/PRs:** <branch> → PR #<n> → merged to `main` as <sha> (as applicable)
**Outcome:** <what state things ended in>

## What prompted this
<the problem / request and intended outcome>

## What changed
<grouped, concrete edits — file paths, what was removed/added/kept>

## Verification
<the exact commands run and their result: nix flake check, nixos-rebuild build, etc.>

## Gotchas noted
<non-obvious things worth remembering>

## Follow-ups / open items
<anything deferred>
```

Omit any template section that doesn't apply. If the session touched no code (research/planning
only), still record the findings and decisions — that is the deliverable.
