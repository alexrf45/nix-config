---
description: Scaffold a disposable security engagement directory
argument-hint: "<name> [rhost] [lhost]"
---

Scaffold an engagement with `scrt new $ARGUMENTS` (fall back to
`nix run ~/nix-config#scrt -- new $ARGUMENTS` if `scrt` isn't on PATH yet).

Then remind the user to declare tool categories in `<dir>/.scrt/tools.toml` before `cd`-ing in
(an empty config is a hard error, by design). Categories: `web ad forensics pwn osint cloud
wireless mobile c2`. See the `security-engagements` skill and `docs/engagements.md`.
