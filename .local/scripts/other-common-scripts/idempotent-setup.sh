#!/usr/bin/env bash

# copy dotfiles
if [[ ! -d ${HOME}/.dotfiles ]]; then
    git clone --depth 1 --bare https://git.thefossguy.com/thefossguy/dotfiles.git ${HOME}/.dotfiles
    git --git-dir=${HOME}/.dotfiles --work-tree=${HOME} checkout -f
    rm -rf ${HOME}/.dotfiles
fi

# create ssh keys
function generate_keys() {
    SSH_KEY=$1
    if [[ ! -f ${SSH_KEY} && ! -f "${SSH_KEY}.pub" ]]; then
        ssh-keygen -t ed25519 -f ${SSH_KEY}
    fi
}
if [[ ! -d $HOME/.ssh ]]; then
    mkdir $HOME/.ssh
    chmod 700 $HOME/.ssh
fi
pushd $HOME/.ssh
for KEY in {git,ssh,virt,zfs}; do
    generate_keys ${KEY}
done
popd

# rustup get toolchain
rustup default stable
rustup update stable
rustup component add rust-src rust-analysis # 'rust-analyzer' is provided by pkgs.rustup

# tldr
tldr --update

if [[ ${HOSTNAME} == "flameboi" ]]; then
    flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
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

    # virsh 
    #virsh net-autostart default
    #virsh pools: default, ISOs
fi

tput -x clear
git --git-dir=${HOME}/.dotfiles --work-tree=${HOME} pull
git --git-dir=${HOME}/.dotfiles --work-tree=${HOME} status -v
