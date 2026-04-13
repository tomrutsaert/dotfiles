#!/bin/bash

WALLPAPER_DIR="$HOME/documents/wallpapers"

while true; do
  # Kill any existing swaybg instance
  pkill swaybg

  # Select a random wallpaper
  wallpaper=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f \
    \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | shuf -n1)

  # Start swaybg
  swaybg -i "$wallpaper" -m fill &

  # Wait 50 minutes
  sleep 50m
done