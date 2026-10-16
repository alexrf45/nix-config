---
description: Switch the neovim + kitty colorscheme to a new theme
argument-hint: "<github-url-or-colorscheme-name>"
---

Switch the shared neovim + kitty colorscheme. `$ARGUMENTS` is either a GitHub URL to a
neovim colorscheme plugin (e.g. `https://github.com/vossenwout/guts.nvim`) or a scheme
name to resolve (e.g. `kanagawa`, `rose-pine`) — if a name, find its canonical neovim
plugin repo first. `gh` is installed and authenticated on thoth — `gh api repos/<owner>/<repo>/git/trees/HEAD?recursive=1`
lists the files, and `gh api repos/<owner>/<repo>/contents/<path> -H 'Accept: application/vnd.github.raw'`
reads one (WebFetch works too).

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
- `modules/home-manager/desktop-i3.nix` — the `palette` attrset near the top is the single
  source for i3 window borders (`client.*`), the i3bar `colors {}` block, i3status
  good/bad/degraded and rofi; only change its values. Map by role: `base`/`mantle` = the
  theme's bg/alt-bg, `text`/`subtext`/`muted` = fg and two dimmer grays, `surface` = the
  selection bg, `overlay` = the inactive border, `accent` = the same blue-ish accent as kitty's
  active tab/border, `red`/`green`/`yellow` = error/ok/warning (pick readable ones, not
  near-background diff tints). Update the palette header comment with the theme name.
- `modules/home-manager/spotify-player.nix` — `theme = "<name>"` in `app.toml` plus the
  `theme.toml` block, whose palette mirrors kitty's (component styles map onto the theme's
  own palette roles).
- Grep the repo for the *old* theme name to catch stragglers (lualine, docs, i3status).

## 3. Verify & land

1. `alejandra` on the changed files only (`nix run nixpkgs#alejandra -- <files>`) — the repo
   isn't fully formatted, so `nix fmt .` reformats ~55 unrelated files.
2. `nixos-rebuild build --flake .#thoth` (or the active host) — no sudo.
3. Commit (`feat: switch colorscheme to <name>`), push, PR into `main`. Remind the user
   the nvim plugin itself is fetched by lazy.nvim at runtime, so first launch after
   `switch` needs network; kitty picks the palette up on `switch` + restart; i3 borders/bar need `$mod+Shift+r`
   (or a re-login), and rofi picks it up on next launch.
