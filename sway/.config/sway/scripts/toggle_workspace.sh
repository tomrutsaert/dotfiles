#!/bin/bash

STATE_DIR="$HOME/.sway_workspace_states"
mkdir -p "$STATE_DIR" # Ensure the directory exists

# Check if a target workspace is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <workspace>"
    exit 1
fi

TARGET_WS="$1"

# Helper function to switch and apply extras
switch_workspace_with_extras() {
    swaymsg workspace "$1"

    case "$1" in
        slack)
            sleep 0.1
            swaymsg '[class="Slack"] focus'
            swaymsg '[class="Slack"] resize set 2000 2000'
            swaymsg '[class="Slack"] move position 1800 15'
            swaymsg '[class="Slack" title="Huddle.*"] resize set default'
            swaymsg '[app_id="com.slack.Slack"] focus'
            swaymsg '[app_id="com.slack.Slack"] resize set 2000 2000'
            swaymsg '[app_id="com.slack.Slack"] move position 1800 15'
            swaymsg '[app_id="com.slack.Slack" title="Huddle.*"] resize set default'
            ;;
        telegram)
            sleep 0.1
            swaymsg '[class="Telegram"] focus'
            swaymsg '[class="Telegram"] resize set 2000 2000'
            swaymsg '[class="Telegram"] move position center'
            ;;
        spotify)
            sleep 0.1
            swaymsg '[class="Spotify"] focus'
            swaymsg '[class="Spotify"] resize set 2000 2000'
            swaymsg '[class="Spotify"] move position center'
            ;;
    esac
}

# Get the currently visible workspaces and the focused workspace **before switching**
declare -A VISIBLE_WORKSPACES
FOCUSED_WS=""
FOCUSED_OUTPUT=""

while read -r output ws visible focused; do
    if [[ "$visible" == "true" ]]; then
        VISIBLE_WORKSPACES["$output"]="$ws"
    fi
    if [[ "$focused" == "true" ]]; then
        FOCUSED_WS="$ws"
        FOCUSED_OUTPUT="$output"
    fi
done < <(swaymsg -t get_workspaces | jq -r '.[] | "\(.output) \(.name) \(.visible) \(.focused)"')

# Determine where the target workspace is currently visible
TARGET_OUTPUT=""
for output in "${!VISIBLE_WORKSPACES[@]}"; do
    if [[ "${VISIBLE_WORKSPACES[$output]}" == "$TARGET_WS" ]]; then
        TARGET_OUTPUT="$output"
        break
    fi
done

# 1. If the target workspace is both visible AND focused → Toggle to the last workspace
if [[ "$FOCUSED_WS" == "$TARGET_WS" ]]; then
    if [[ -f "$STATE_DIR/$FOCUSED_OUTPUT" ]]; then
        LAST_WS=$(cat "$STATE_DIR/$FOCUSED_OUTPUT")
        swaymsg workspace "$LAST_WS"
    fi
    echo "$TARGET_WS" > "$STATE_DIR/$FOCUSED_OUTPUT" # Update state
    exit 0
fi

# 2. If the target workspace is visible but NOT focused → Just switch to it (no state update)
if [[ -n "$TARGET_OUTPUT" ]]; then
    switch_workspace_with_extras "$TARGET_WS"
    exit 0
fi

# 3. If the target workspace is NOT visible → Find where it will appear and save the current workspace for that output
EXPECTED_OUTPUT=$(swaymsg -t get_workspaces | jq -r --arg ws "$TARGET_WS" '.[] | select(.name == $ws) | .output')

if [[ -n "$EXPECTED_OUTPUT" && -n "${VISIBLE_WORKSPACES[$EXPECTED_OUTPUT]}" ]]; then
    echo "${VISIBLE_WORKSPACES[$EXPECTED_OUTPUT]}" > "$STATE_DIR/$EXPECTED_OUTPUT"
fi

# Now switch to the target workspace
switch_workspace_with_extras "$TARGET_WS"
