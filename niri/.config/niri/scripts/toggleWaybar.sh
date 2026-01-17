#!/bin/bash
pgrep waybar && pkill waybar || waybar & disown