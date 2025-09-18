#!/usr/bin/env bash
# youtube-inhibit-safe.sh
# Requires: jq, xprintidle, systemd (user session)
LOCK_FILE="/tmp/youtube_inhibit.lock"
MAX_IDLE_MS=$((30*60*1000))   # 0.5 hour in milliseconds

while true; do
    # Check if YouTube Firefox window is focused
    NODE=$(i3-msg -t get_tree | jq -r '
        recurse(.nodes[], .floating_nodes[])
        | select(.focused == true)
        | select(.window_properties.class? == "firefox-esr")
        | select(.window_properties.title? | contains("- YouTube — Mozilla Firefox"))
    ')

    # Check user idle time (Xorg)
    idle_ms=$(xprintidle)

    # Determine if inhibit should be active
    if [[ -n "$NODE" && "$idle_ms" -lt "$MAX_IDLE_MS" ]]; then
        if [[ ! -f "$LOCK_FILE" ]]; then
            echo "YouTube active + user recently active → inhibiting sleep/DPMS"
            # Start systemd-inhibit for 0.5h max
            systemd-inhibit --what=idle:sleep --why="Watching YouTube" sleep 1800 &
            pid=$!
            echo "$pid" > "$LOCK_FILE"

            # Disable Xorg screen blanking / DPMS
            xset s off -dpms

            # Background restore after 0.5h in case script misses it
            # (
            #     sleep 1800
            #     if [[ -f "$LOCK_FILE" ]]; then
            #         echo "Background restore DPMS after 0.5h in case script misses it"
            #         xset s on +dpms
            #     fi
            # ) &
        fi
    else
        # Either YouTube not focused or user idle too long → remove inhibit
        if [[ -f "$LOCK_FILE" ]]; then
            pid=$(cat "$LOCK_FILE")
            echo "Either YouTube not focused or user idle too long → remove inhibit"
            if kill -0 "$pid" 2>/dev/null; then
                kill "$pid"
            fi
            rm -f "$LOCK_FILE"
            # Restore Xorg screen blanking
            xset s on +dpms
        fi
    fi

    # Check if lock exists but PID died (inhibit expired naturally)
    if [[ -f "$LOCK_FILE" ]]; then
        pid=$(cat "$LOCK_FILE")
        if ! kill -0 "$pid" 2>/dev/null; then
            echo "Inhibit process ended → cleaning lock and restoring DPMS"
            rm -f "$LOCK_FILE"
            xset s on +dpms
        fi
    fi

    sleep 30
done
