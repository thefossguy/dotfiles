#!/usr/bin/env bash

if command -v flatpak > /dev/null; then
    flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak repair --user
    flatpak update --user --assumeyes --noninteractive
    flatpak install --user --or-update --assumeyes --noninteractive \
        com.bitwarden.desktop                \
        com.brave.Browser                    \
        com.discordapp.Discord               \
        com.github.tchx84.Flatseal           \
        fr.handbrake.ghb                     \
        io.gitlab.librewolf-community        \
        io.mpv.Mpv                           \
        org.gnome.gitlab.YaLTeR.Identity     \
        org.gnome.gitlab.YaLTeR.VideoTrimmer \
        org.gnome.Logs                       \
        org.gnome.meld                       \
        org.mozilla.firefox                  \
        org.raspberrypi.rpi-imager
    flatpak uninstall --user --unused --assumeyes --noninteractive --delete-data
fi
