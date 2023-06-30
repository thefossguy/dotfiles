#!/usr/bin/env bash

if command -v flatpak > /dev/null; then
    flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak install --user --or-update --assumeyes --noninteractive \
        com.brave.Browser                    \
        com.discordapp.Discord               \
        com.github.tchx84.Flatseal           \
        fr.handbrake.ghb                     \
        io.gitlab.librewolf-community        \
        org.gnome.gitlab.YaLTeR.Identity     \
        org.gnome.gitlab.YaLTeR.VideoTrimmer \
        org.gnome.Logs                       \
        org.gnome.meld                       \
        org.raspberrypi.rpi-imager
    flatpak update --user --assumeyes --noninteractive
    flatpak uninstall --user --unused --assumeyes --noninteractive --delete-data
    flatpak repair --user
fi
