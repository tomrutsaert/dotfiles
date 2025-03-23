#!/bin/bash

STATE_DIR="$HOME/.sway_workspace_states"
mkdir -p "$STATE_DIR" # Ensure the directory exists

# Check if a target workspace is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <workspace>"
    exit 1
fi

TARGET_WS="$1"

# Switch to the target workspace
swaymsg workspace "$TARGET_WS"

# Get the newly focused workspace and output **after switching**
FOCUSED_WS=""
FOCUSED_OUTPUT=""

while read -r output ws focused; do
    if [[ "$focused" == "true" ]]; then
        FOCUSED_WS="$ws"
        FOCUSED_OUTPUT="$output"
        break
    fi
done < <(swaymsg -t get_workspaces | jq -r '.[] | "\(.output) \(.name) \(.focused)"')

# Update the state file for the focused output with the new focused workspace
if [[ -n "$FOCUSED_OUTPUT" && -n "$FOCUSED_WS" ]]; then
    echo "$FOCUSED_WS" > "$STATE_DIR/$FOCUSED_OUTPUT"
fi
