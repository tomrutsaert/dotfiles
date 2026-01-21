#!/bin/bash
swayidle -w \
    timeout 300 "~/.config/sway/scripts/manage_vcp.sh save && ~/.config/sway/scripts/manage_vcp.sh dim" \
        resume "~/.config/sway/scripts/manage_vcp.sh restore" \
    timeout 450 'niri msg output DP-1 off && niri msg output DP-2 off' \
        resume 'niri msg output DP-1 on && niri msg output DP-2 on' \
    timeout 3600 'systemctl suspend'