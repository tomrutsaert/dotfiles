#!/bin/bash

STATE_DIR="$HOME/.i3_workspace_states"
mkdir -p "$STATE_DIR" # Ensure the directory exists

# Check if a target workspace is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <workspace>"
    exit 1
fi

TARGET_WS="$1"

# Helper function to switch and apply extras
switch_workspace_with_extras() {
    i3-msg workspace "$1"

    case "$1" in
        slack)
            sleep 0.1
            i3-msg '[class="Slack"] focus'
            i3-msg '[class="Slack"] resize set 2240 px 2000 px'
            i3-msg '[class="Slack"] move position 1500 px 100px'
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
done < <(i3-msg -t get_workspaces | jq -r '.[] | "\(.output) \(.name) \(.visible) \(.focused)"')

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
        i3-msg workspace "$LAST_WS"
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
EXPECTED_OUTPUT=$(i3-msg -t get_workspaces | jq -r --arg ws "$TARGET_WS" '.[] | select(.name == $ws) | .output')

if [[ -n "$EXPECTED_OUTPUT" && -n "${VISIBLE_WORKSPACES[$EXPECTED_OUTPUT]}" ]]; then
    echo "${VISIBLE_WORKSPACES[$EXPECTED_OUTPUT]}" > "$STATE_DIR/$EXPECTED_OUTPUT"
fi

# Now switch to the target workspace
switch_workspace_with_extras "$TARGET_WS"
