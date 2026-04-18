#!/bin/bash
swayidle -w \
    timeout 450 'niri msg output eDP-1 off' \
        resume 'niri msg output eDP-1 on' \
    timeout 3600 'systemctl suspend'
