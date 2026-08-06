#!/usr/bin/env bash
emit() { i3-msg -t get_workspaces | jq -c 'map({num: .num, focused: .focused})'; }
emit
i3-msg -t subscribe -m '[ "workspace" ]' | while read -r _; do emit; done
