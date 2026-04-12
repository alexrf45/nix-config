#!/bin/sh

# check latest version against what's installed
VER=$(curl -sL https://api.github.com/repos/tailscale/tailscale/releases/latest | jq -r ".tag_name" | cut -c 2-)

if [ "$VER" != "$(tailscale version | head -n1)" ]; then
  # download latest version & unpack binaries
  curl "https://pkgs.tailscale.com/stable/tailscale_${VER}_mips.tgz" | tar xvz -C /tmp
  cp /tmp/tailscale_*/* /tmp/tailscale_*/systemd/* /config/
fi

ln -s /config/tailscale /usr/bin/tailscale

ln -s /config/tailscaled /usr/sbin/tailscaled

mkdir -p /var/lib/tailscale/

touch /config/auth/tailscaled.state

chmod 0400 /config/auth/tailscaled.state

ln -s /config/auth/tailscaled.state /var/lib/tailscale/tailscaled.state

sudo tailscaled >/dev/null 2>&1 &

disown

sudo tailscale up
