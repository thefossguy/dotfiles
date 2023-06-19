#!/usr/bin/env bash

# tldr
tldr --update

# virsh
#virsh net-autostart default
#virsh pools: default, ISOs

# update dotfiles
git --git-dir=$HOME/.dotfiles --work-tree=$HOME pull
git --git-dir=$HOME/.dotfiles --work-tree=$HOME status -v
