---
description: Switch the neovim + kitty colorscheme to a new theme
argument-hint: "<github-url-or-colorscheme-name>"
---

Switch the shared neovim + kitty colorscheme. `$ARGUMENTS` is either a GitHub URL to a
neovim colorscheme plugin (e.g. `https://github.com/vossenwout/guts.nvim`) or a scheme
name to resolve (e.g. `kanagawa`, `rose-pine`) — if a name, find its canonical neovim
plugin repo first (WebFetch; no `gh` on thoth).

## 1. Gather the theme

From the plugin repo, determine:

- the `:colorscheme` name (README install snippet is authoritative — it may differ from
  the repo name, e.g. `vim-moonfly-colors` → `moonfly`);
- the lazy.nvim spec (`owner/repo`);
- a **terminal palette** — 16 ANSI colors + background/foreground/cursor/selection.
  Check in order:
  1. an `extras/` dir in the repo (kitty > ghostty > alacritty/wezterm — all map
     straightforwardly onto kitty's `color0..15` + bg/fg/cursor/selection keys);
  2. hex values in the README;
  3. the theme's palette source file (`lua/**/palette.lua` or similar).

## 2. Apply

Work on a feature branch off `main` (never commit to `main`).

- `modules/home-manager/editor.nix` — three spots:
  - the header comment `# Theme: <name> (dark)`;
  - `install.colorscheme = { "<name>", "habamax" }` in the lazy.nvim setup;
  - the `nvim/lua/plugins/color.lua` spec: repo, `name`, and `vim.cmd.colorscheme("<name>")`.
- `modules/home-manager/terminal.nix` — the kitty `settings` block: header comment,
  `background`/`foreground`/`cursor`/`url_color`/`selection_*`, `color0..15` (keep the
  `# black` … `# bright white` comments), and the tab/border colors (active tab/border
  use the theme's blue-ish accent; inactive use a near-background dark). Lowercase all hex.
- Note the source of the palette (e.g. `— from extras/ghostty/<name> upstream`) in the
  kitty block comment.
- Grep the repo for the *old* theme name to catch stragglers (lualine, docs, i3status).

## 3. Verify & land

1. `nix fmt` (alejandra).
2. `nixos-rebuild build --flake .#thoth` (or the active host) — no sudo.
3. Commit (`feat: switch colorscheme to <name>`), push, PR into `main`. Remind the user
   the nvim plugin itself is fetched by lazy.nvim at runtime, so first launch after
   `switch` needs network; kitty picks the palette up on `switch` + restart.
