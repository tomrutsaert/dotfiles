#!/bin/bash

# Temporary file to store VCP values
VCP_STATE_FILE="/tmp/vcp_state.txt"

# Save current VCP values
save_vcp_values() {
    current_vcp_1=$(ddcutil getvcp 10 --display 1 | sed -n 's/.*current value[[:space:]]*=[[:space:]]*\([0-9]*\).*/\1/p')
    current_vcp_2=$(ddcutil getvcp 10 --display 2 | sed -n 's/.*current value[[:space:]]*=[[:space:]]*\([0-9]*\).*/\1/p')
    
    # Save the VCP values to the state file
    echo "$current_vcp_1 $current_vcp_2" > "$VCP_STATE_FILE"
}

# Restore VCP values
restore_vcp_values() {
    # Read the saved VCP values from the state file
    if [ -f "$VCP_STATE_FILE" ]; then
        read current_vcp_1 current_vcp_2 < "$VCP_STATE_FILE"
        ddcutil setvcp 10 $current_vcp_1 --verify --display 1
        # sleep 2
        ddcutil setvcp 10 $current_vcp_2 --verify --display 2
    else
        echo "No saved VCP values found, skipping restore."
    fi
}

# Dimming function to lower brightness
dim_displays() {
    ddcutil setvcp 10 20 --noverify --display 1
    ddcutil setvcp 10 20 --noverify --display 2
}

# Process arguments
case "$1" in
    save)
        save_vcp_values
        ;;
    restore)
        restore_vcp_values
        ;;
    dim)
        dim_displays
        ;;
    *)
        echo "Usage: $0 {save|restore|dim}"
        exit 1
        ;;
esac
