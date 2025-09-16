#!/usr/bin/env bash

# Path to systemd user service
SERVICE="manual-inhibit.service"

# Toggle inhibit on left-click
if [[ "$BLOCK_BUTTON" == "1" ]]; then
    if systemctl --user is-active --quiet "$SERVICE"; then
        # Stop inhibit
        systemctl --user stop "$SERVICE"
        xset s on +dpms
    else
        # Start inhibit
        systemctl --user start "$SERVICE"
        xset s off -dpms
    fi
fi

# Output icon for i3blocks
if systemctl --user is-active --quiet "$SERVICE"; then
    ICON=""  # inhibit active
else
    ICON=""  # inhibit inactive
fi

echo "$ICON"