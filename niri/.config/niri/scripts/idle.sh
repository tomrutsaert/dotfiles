#!/bin/bash
swayidle -w \
    timeout 300 "~/.config/sway/scripts/manage_vcp.sh save && ~/.config/sway/scripts/manage_vcp.sh dim" \
        resume "~/.config/sway/scripts/manage_vcp.sh restore" \
    timeout 450 'swaymsg "output * dpms off"' \
        resume 'swaymsg "output * dpms on"' \
    timeout 600 'swaymsg "output * power off"' \
        resume 'swaymsg "output * power on"' \
    timeout 3600 'systemctl suspend'