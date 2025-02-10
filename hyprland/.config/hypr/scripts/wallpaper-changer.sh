#!/bin/bash

function main() {
  hyprctl hyprpaper unload all
  killall hyprpaper

  echo "splash = false" >~/.config/hypr/hyprpaper.conf
  echo "ipc = true" >>~/.config/hypr/hyprpaper.conf
  # monitors=$(hyprctl monitors -j | jq -r ".[] | .name")

  # for monitor in $monitors; do
  #   wallpaper=$(fd ".png|.jpg|.jpeg|.webp" ~/Pictures/wallpapers/ | shuf -n1)
  #   echo "preload = $wallpaper" >>~/.config/hypr/hyprpaper.conf
  #   echo "wallpaper = $monitor,$wallpaper" >>~/.config/hypr/hyprpaper.conf
  # done

  wallpaper=$( find ~/Nextcloud/wallpapers/ -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \)| shuf -n1)
  echo "preload = $wallpaper" >>~/.config/hypr/hyprpaper.conf
  echo "wallpaper = ,$wallpaper" >>~/.config/hypr/hyprpaper.conf

  hyprpaper &
  sleep 50m
  main
}

main
