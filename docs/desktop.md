# Desktop sessions

thoth runs two sessions off one display manager. **Sway (Wayland) + Dux Shell is the default and
the daily driver**; **i3 (X11) is the fallback**, kept working but no longer the target.

| | Sway session (default) | i3 session (fallback) |
| --- | --- | --- |
| System module | `modules/nixos/desktop.nix` + `dux.nix` | `modules/nixos/desktop-x11.nix` |
| User module | `modules/home-manager/desktop.nix` | `modules/home-manager/desktop-i3.nix` |
| Bar / launcher / notifications / lock | Dux Shell | i3bar + i3status, rofi, dunst, i3lock |
| Session target | `sway-session.target` | `graphical-session.target` |

`desktop-x11.nix` is misnamed by history — besides Xorg + i3 it carries the pieces **both**
sessions need: GDM, fonts/fontconfig, xkb, UPower and the GTK portal. Don't drop it when
trimming X11.

## Display manager — GDM, pinned to Sway

GDM since 2026-11-09; LightDM could not start Wayland sessions (`VirtualTerminalAlreadyTaken`).

`desktop-x11.nix` sets `services.displayManager.defaultSession = "sway"`. That is load-bearing, not
cosmetic: NixOS's gdm module runs `set-session sway` in the display-manager preStart, which pins
AccountsService to `Session=sway` / `SessionType=wayland` on **every** GDM start.

Without the pin, GDM 50 re-applies the user's *saved* `SessionType` whenever the auth conversation
restarts — e.g. after a mistyped password. A stale `x11` type plus Sway picked at the gear icon
gives `gdm-x-session sway`: Sway runs nested inside Xorg and the screen looks black or frozen. That
is what the 2026-11-18 "Dux is broken" scare actually was; Dux Shell was running fine inside the
nested Xorg.

**Tradeoff, deliberate:** the pin cuts against i3. Picking i3 at the gear icon works for that login,
but an auth retry there launches i3 as a Wayland session, and the next DM start resets the saved
session back to Sway.

Checks after logging in:

```sh
echo $XDG_SESSION_TYPE               # want: wayland
ps -eo args | grep gdm-.*-session    # want: gdm-wayland-session, not gdm-x-session
busctl --system get-property org.freedesktop.Accounts \
  /org/freedesktop/Accounts/User1000 org.freedesktop.Accounts.User SessionType
```

Verify a session change with a **full reboot**, not `switch` + re-login — a switch does not restart
the display manager, so the old DM keeps serving logins.

## Dux Shell

Dux Shell (duxlabs.dev) draws the bar, launcher, notifications, lock screen, wallpaper and theme for
the Sway session. Sway's own `bars` list is therefore empty.

- Enabled via `programs.dms-shell` with `pkgs-unstable.dux-shell` — stable 26.05 still ships the
  pre-rebrand `dms-shell` 1.4. Retire the override once stable carries `programs.dux-shell`.
- `systemd.target = "sway-session.target"` — `graphical-session.target` is active under i3 too, so
  the default would start `dms.service` in the i3 session as well.
- `services.power-profiles-daemon.enable = false` — TLP owns power on thoth
  (`hardware-intel.nix`).
- IPC drives the keybindings: `dms ipc call spotlight toggle` (launcher, `Mod+d`),
  `dms ipc call lock lock` (lock, system mode `Mod+0` → `l`).

Benign warnings in the journal under Sway: `power-profiles-daemon` not activatable (deliberate,
above) and `ext-background-effect-v1 not supported` (Sway lacks the protocol).

## X11-only autostarts

Package-provided XDG autostart entries bind to `graphical-session.target`, so they also fired under
Sway and duplicated Dux's widgets (two tray applets, a second notification daemon). `desktop-i3.nix`
scopes them:

- picom, nm-applet, blueman — the `x11OnlyAutostart` helper copies the upstream `.desktop` and
  appends `sway;wlroots;` to `NotShowIn`, writing it to `~/.config/autostart/`. User-level entries
  win over `$XDG_CONFIG_DIRS` by basename (verified against `systemd-xdg-autostart-generator`).
- dunst — `systemd.user.services.dunst.Unit.ConditionEnvironment = "XDG_SESSION_TYPE=x11"`; under
  Sway, Dux owns `org.freedesktop.Notifications`.

Any new tray/compositor helper that Dux already provides needs the same treatment.

## SSH agent under GDM

The gnome-keyring PAM rules in `security.nix` start gcr's ssh agent and set
`SSH_AUTH_SOCK=/run/user/1000/gcr/ssh`. That agent holds no identities, so `op-ssh-sign` fails every
signed commit with `1Password: failed to fill whole buffer` — which reads exactly like a locked or
expired 1Password. HM `ssh.nix` pins `SSH_AUTH_SOCK=$HOME/.1password/agent.sock`. Plain `ssh` was
never affected (`IdentityAgent` in `ssh_config` overrides the env var).

## X11 → Wayland equivalents

| X11 (i3) | Wayland (Sway) |
| --- | --- |
| rofi | Dux spotlight (`dms ipc call spotlight toggle`) |
| flameshot | `grim` + `slurp`, annotate in `satty` |
| i3lock | Dux lock (`dms ipc call lock lock`) |
| dunst | Dux notifications |
| feh wallpaper | Dux |
| picom | built into the compositor |
| xrandr / arandr | `wlr-randr`, `swaymsg -t get_outputs` |
| xclip / xsel | `wl-clipboard` (`wl-copy` / `wl-paste`) |

Output names differ between the two: `HDMI-1` under X11 vs `HDMI-A-1` under Sway. The external
display `output` lines are commented in HM `desktop.nix`'s `extraConfig` — check
`swaymsg -t get_outputs` before uncommenting.

## Known gaps

- Theming is split: the i3 session reads the `palette` attrset in `desktop-i3.nix`, while Sway's
  window borders are hardcoded base16-bright hex in `desktop.nix`'s `extraConfig` and Dux generates
  its own theme. `/colorscheme` edits both sets of hex by hand; Sway has no shared palette yet.
- No Wayland equivalent wired up yet for arandr (GUI output arrangement) or lxappearance.
