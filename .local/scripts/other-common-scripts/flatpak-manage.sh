#!/usr/bin/env bash

if command -q flatpak; then
    flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak repair --user
    flatpak update --user --assumeyes --noninteractive
    flatpak install --user --or-update --assumeyes --noninteractive \
        com.bitwarden.desktop                $(: # Bitwarden) \
        com.brave.Browser                    $(: # Brave) \
        com.discordapp.Discord               $(: # Discord) \
        com.github.tchx84.Flatseal           $(: # Flatseal; OFFICIAL) \
        fr.handbrake.ghb                     $(: # Handbrake; OFFICIAL) \
        io.gitlab.librewolf-community        $(: # LibreWolf) \
        io.mpv.Mpv                           $(: # MPV) \
        org.gnome.gitlab.YaLTeR.Identity     $(: # Identity \(compare images\); OFFICIAL) \
        org.gnome.gitlab.YaLTeR.VideoTrimmer $(: # Video Trimmer; OFFICIAL) \
        org.gnome.Logs                       $(: # Logs; OFFICIAL) \
        org.gnome.meld                       $(: # Meld (shows diff)) \
        org.mozilla.firefox                  $(: # Firefox; OFFICIAL) \
        org.raspberrypi.rpi-imager           $(: # Raspberry Pi Imager)
    flatpak uninstall --user --unused --assumeyes --noninteractive --delete-data
fi
