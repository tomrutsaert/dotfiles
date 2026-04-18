# dotfiles
My personal dotfiles

prereq: stow

Example to set base config (and replace existing base):
```
stow --adopt -t $HOME base
git reset --hard
```

Example to set hyprland config:
```
stow -t $HOME hyprland
```

## Host-specific packages

Several tools (`niri`, `sway`) share a common config and pull host-specific
bits (monitor names, brightness, swayidle, etc.) from an included file that
lives in a `<tool>-desktop` or `<tool>-laptop` stow package.

On the desktop:
```
stow -t $HOME niri niri-desktop
stow -t $HOME sway sway-desktop
```

On the laptop:
```
stow -t $HOME niri niri-laptop
stow -t $HOME sway sway-laptop
```

Stow exactly one of `niri-desktop` / `niri-laptop` per machine (same for sway).
Waybar and foot are unified — no host package needed.
