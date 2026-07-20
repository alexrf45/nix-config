# Development workflow

1. **Research first.** Is the tool/option already in nixpkgs? `nix search` / `nix eval` before
   writing or vendoring anything. For structure, reach for the `nixos-patterns` /
   `nixos-best-practices` skills; for library/API detail, `docs-lookup`.
2. **Branch** off `main` (see the git-workflow rule).
3. **Implement** in small, host-split modules; format with `alejandra`.
4. **Verify by building** (see the testing rule): `nix flake check`, `nixos-rebuild build --flake
   .#<host>`, and `nix build .#sec-all` for any security-tooling change.
5. **Review** (code-review rule), then open a PR into `main`.

Prefer adopting a proven nixpkgs option/module over hand-rolling. Leave `switch` to the user —
it needs interactive sudo.
