#!/bin/bash

function main() {
  # Select a random wallpaper
  wallpaper=$(find ~/Nextcloud/wallpapers/ -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | shuf -n1)

  # Set the wallpaper using swaybg
  swaybg -i "$wallpaper" -m fill &

  # Wait for 50 minutes before changing again
  sleep 50m
  main
}

main