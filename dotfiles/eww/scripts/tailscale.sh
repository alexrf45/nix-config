#!/usr/bin/env bash
ip -4 -o addr show tailscale0 2>/dev/null | awk '{print $4}' | cut -d/ -f1
