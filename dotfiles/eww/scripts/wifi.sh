#!/usr/bin/env bash
line=$(nmcli -t -f active,ssid,signal dev wifi 2>/dev/null | awk -F: '$1=="yes"{print $2" "$3"%"; exit}')
[ -z "$line" ] && echo "down" || echo "$line"
