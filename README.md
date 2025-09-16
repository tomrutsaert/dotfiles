# dotfiles
My personal dotfiles

prereq: stow

example to set base config (and replace exsting base)
```
stow --adopt -t $HOME base
git reset --hard
``

example to set hyperland config
```
stow -t $HOME hyperland
``|