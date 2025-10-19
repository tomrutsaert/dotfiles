#!/bin/bash

# Directory containing wallpapers
WALLPAPER_DIR="$HOME/Nextcloud/wallpapers"

function main() {
  while true; do
    # Pick a random image
    wallpaper=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | shuf -n1)

    # Set the wallpaper using feh
    feh --bg-fill "$wallpaper"

    # Wait 50 minutes
    sleep 50m
  done
}

main
