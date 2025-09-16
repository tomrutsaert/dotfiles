#!/usr/bin/env bash

LOCK_FILE="/tmp/youtube_inhibit.lock"

while true; do
    NODE=$(i3-msg -t get_tree | jq '
        recurse(.nodes[], .floating_nodes[])
        | select(.focused == true)
        | select(.window_properties.class? == "firefox")
        | select(.window_properties.title? | contains("- YouTube — Mozilla Firefox"))
    ')

    if [[ -n "$NODE" ]]; then
        if [[ ! -f "$LOCK_FILE" ]]; then
            echo "YouTube detected → inhibiting sleep..."
            # This process will hold the inhibit
            systemd-inhibit --what=idle:sleep --why="Watching YouTube" sleep infinity &
            echo $! > "$LOCK_FILE"
        fi
    else
        if [[ -f "$LOCK_FILE" ]]; then
            echo "YouTube not detected → releasing inhibit..."
            kill "$(cat "$LOCK_FILE")" 2>/dev/null
            rm -f "$LOCK_FILE"
        fi
    fi

    sleep 30
done
