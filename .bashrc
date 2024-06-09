#!/usr/bin/env bash
# shellcheck disable=SC2139

# only run in an interactive shell
[[ $- == *i* ]] || return

# shellcheck disable=SC1091
[[ -f /etc/bashrc ]] && source /etc/bashrc
unalias -a

shopt -s checkjobs
shopt -s checkwinsize
shopt -s extglob
shopt -s globstar
shopt -s histappend
HISTCONTROL='ignorespace:ignoredups:erasedups'
HISTFILESIZE=100000
HISTIGNORE="clear:history*:exit:date:whoami:l:lo:ll:la:ldt:llh:alh:lah:lha:lsh"
HISTSIZE=10000
PS0_HORIZONTAL_RULE='++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'
FILES_TO_SOURCE=()

function path_add() {
    if [[ -d "$1" ]] && [[ ":$PATH:" != *:$1:* ]]; then
        PATH="$PATH:$1"
    fi
}

if [[ "$(uname -s)" == 'Linux' ]]; then
    GNU_LS="$(command -v ls)"
    GNU_GREP="$(command -v grep)"

    alias ping='ping -W 0.1 -O'
    alias mpv='mpv --geometry=60% --vo=gpu --hwdec=vaapi'
    alias mpvrpi='mpv --geometry=60% --vo=x11'

    if [[ "${XDG_SESSION_TYPE}" == 'x11' ]]; then
        alias clearclipboard='xsel -bc'
        alias pbcopy='xsel --clipboard --input'
    elif [[ "${XDG_SESSION_TYPE}" == 'wayland' ]]; then
        alias clearclipboard='wl-copy --clear'
        alias pbcopy='wl-copy'
    fi


    # source the vars only if we are not on NixOS
    if grep 'nixos' /etc/os-release > /dev/null; then
        EDITOR=nvim

    else
        EDITOR=vim

        if command -v nix > /dev/null; then
            FILES_TO_SOURCE+=("${HOME}/.nix-profile/etc/profile.d/hm-session-vars.sh")
            alias sudo='sudo --preserve-env=PATH env'
        fi

        if grep 'debian' /etc/os-release > /dev/null; then
            export NEEDRESTART_MODE='a'
            export DEBIAN_FRONTEND='noninteractive'
            export APT_LISTCHANGES_FRONTEND='none'

            if grep 'ID=debian' /etc/os-release > /dev/null; then
                LANG="$(grep -v '^# ' /etc/locale.gen | grep -v '^$' | head -n 1 | sed -e 's/ /./')"
                export LANG
            fi
        fi
    fi

elif [[ "$(uname -s)" == 'Darwin' ]]; then
    GNU_LS="$(command -v gls)"
    GNU_GREP="$(command -v ggrep)"

    if command -v nix > /dev/null; then
        FILES_TO_SOURCE+=("${HOME}/.nix-profile/etc/profile.d/hm-session-vars.sh")
        FILES_TO_SOURCE+=("${HOME}/.local/share/nix-bash/bash_completion.sh")
    fi

    EDITOR=vim
    alias ktb='sudo pkill TouchBarServer; sudo killall ControlStrip'
    alias mpv='mpv --vo=libmpv'
    alias ownefivars="chmod +uw ${HOME}/Library/Containers/com.utmapp.UTM/Data/Documents/*.utm/Data/efi_vars.fd"
    alias sudo='sudo --preserve-env=PATH env'

    path_add '/usr/local/bin'
fi
export EDITOR

HM_CONFIG_PATH="${HOME}/my-git-repos/$(whoami)/prathams-nixos"
export HM_CONFIG_PATH

mkdir -p "${HOME}/.cargo/bin" && path_add "${HOME}/.cargo/bin"
mkdir -p "${HOME}/.local/bin" && path_add "${HOME}/.local/bin"
path_add '/sbin'
export PATH

if command -v rustc > /dev/null; then
    # this actually needs to be a split for loop's iteration
    # shellcheck disable=SC2207
    rust_toolchains=($(rustup toolchain list | awk '{ print $1 }'))
    PYTHONPATH=''

    for toolchain in "${rust_toolchains[@]}"; do
        toolchain_path="${HOME}/.rustup/toolchains/${toolchain}/lib/rustlib/etc"
        if [[ -d "${toolchain_path}" ]] && [[ ":$PYTHONPATH:" != *:${toolchain_path}:* ]]; then
            if [[ -z "${PYTHONPATH}" ]]; then
                PYTHONPATH="${toolchain_path}"
            else
                PYTHONPATH="$PYTHONPATH:${toolchain_path}"
            fi
        fi
    done

    export PYTHONPATH
fi

function list_open_ports() {
    if [[ -n "$1" ]]; then
        nc -z -v "$1" 1-65535 2>&1 | grep -v 'Connection refused'
    else
        echo 'Please provide an [IP] address.'
    fi
}

function tty_serial() {
    if [[ -n "$1" ]]; then
        if [[ -n "$2" ]]; then
            picocom --quiet --baud "$2" "/dev/ttyUSB$1"
        else
            picocom --quiet --baud 115200 "/dev/ttyUSB$1"
        fi
    else
        picocom --quiet --baud 115200 /dev/ttyUSB0
    fi
}

for fts in "${FILES_TO_SOURCE[@]}"; do
    if [[ -f "${fts}" ]]; then
        # shellcheck disable=SC1090
        source "${fts}"
    else
        echo "WARNING: '${fts}' does not exist."
    fi
done

# alias wrappers to call scripts
COMMON_SCRIPTS_DIR="${HOME}/.local/scripts"
SCRIPTS_DIR="${COMMON_SCRIPTS_DIR}/other-common-scripts"
EL_SCRIPTS_DIR="${COMMON_SCRIPTS_DIR}/el"
alias debextract="${SCRIPTS_DIR}/extract-deb-pkg.sh"
alias installrpmdeps="${EL_SCRIPTS_DIR}/install-rpm-package-build-deps.sh"
alias mockbuild="${EL_SCRIPTS_DIR}/mock-build.sh"
alias pysort="${SCRIPTS_DIR}/sort.py"
alias rpmextract="${SCRIPTS_DIR}/extract-rpm-pkg.sh"
alias showdiskusage="${SCRIPTS_DIR}/show-disk-usage.sh"
alias startvm="${SCRIPTS_DIR}/start-qemu-vm.sh"
alias sudosync="${SCRIPTS_DIR}/paranoid-flush.sh"
alias suslock="${HOME}/.local/scripts/window-manager/lock-and-suspend.sh"
alias syncsync="${SCRIPTS_DIR}/paranoid-flush.sh"

# actual aliases (generic ones)
if command -v wget2 > /dev/null; then
    wget_cmd='wget2'
else
    wget_cmd='wget'
fi
RSYNC_OPTIONS='--verbose --recursive --size-only --human-readable --progress --stats --itemize-changes'
alias bottom='btm'
alias clear="clear && printf '\e[3J'"
alias dotfiles="git --git-dir=${HOME}/.dotfiles --work-tree=${HOME}"
alias download='aria2c --max-connection-per-server=16 --min-split-size=1M --file-allocation=none --continue=false --seed-time=0'
alias drivetemp='hdparm -CH'
alias mksshkey='ssh-keygen -t ed25519 -f'
alias mtr='mtr --show-ips --displaymode 0 -o "LDR AGJMXI"'
alias nixcheckconf="rsync --fsync ${RSYNC_OPTIONS} --dry-run --checksum ${HOME}/my-git-repos/pratham/prathams-nixos/nixos-configuration/ /etc/nixos/"
alias prettynixbuild='nix build --log-format internal-json -v . 2>&1 | nom --json'
alias serialterm="tty_serial"
alias sudo='sudo '
alias unxz='unxz --keep' # override 'unxz' with this to always keep the archive
alias update="source ${HOME}/.bashrc"
alias wget="${wget_cmd}"


# yes, the order is | e -> vvim -> vim |
path_nvim="$(command -v nvim)"
path_vim="$(command -v vim)"
path_vi="$(command -v vi)"
alias e="${path_nvim}"
alias vvim="${path_vim}"
alias vim="${path_vi}"

# git
alias gadd='git add'
alias gdiff='git --no-pager diff'
alias gsdiff='git --no-pager diff --staged'
alias g0diff='git --no-pager diff --unified=0'
alias gclean='git clean -x -d'
alias gstat='git status'
alias gwt='git worktree'
alias gblame='git blame -w -C -C -C'
# git, but dotfiles
alias dotfiles="git --git-dir=${HOME}/.dotfiles --work-tree=${HOME}"
alias dotadd="git --git-dir=${HOME}/.dotfiles --work-tree=${HOME} add -f"
alias dotdiff="git --git-dir=${HOME}/.dotfiles --work-tree=${HOME} --no-pager diff"
alias dotsdiff="git --git-dir=${HOME}/.dotfiles --work-tree=${HOME} --no-pager diff --staged"
alias dot0diff="git --git-dir=${HOME}/.dotfiles --work-tree=${HOME} --no-pager diff --unified=0"
alias dotstat="git --git-dir=${HOME}/.dotfiles --work-tree=${HOME} status"

# rsync
alias custcp="rsync ${RSYNC_OPTIONS}"
alias fcustcp="rsync --fsync ${RSYNC_OPTIONS}"

# yt-dlp related aliases
alias playdl="yt-dlp --config-location ${HOME}/.config/yt-dlp/plst_config --external-downloader aria2c"
alias ytdown="yt-dlp --config-location ${HOME}/.config/yt-dlp/norm_config --external-downloader aria2c"
alias ytslow="yt-dlp --config-location ${HOME}/.config/yt-dlp/norm_config --no-part --concurrent-fragments 1 --limit-rate 4M"

# ripgrep
alias rgi='rg --hidden --ignore-case'
alias rgv='rg --hidden --invert-match'
alias rgiv='rg --hidden --invert-match --ignore-case'
alias rgvi='rg --hidden --invert-match --ignore-case'

# these only exist because I need to use 'g{ls,grep}' on macOS
common_ggrep_cmd="${GNU_GREP} --color=auto"
alias   grep="${common_ggrep_cmd}"
alias  grepi="${common_ggrep_cmd} --ignore-case"
alias  grepv="${common_ggrep_cmd} --invert-match"
alias grepiv="${common_ggrep_cmd} --invert-match --ignore-case"
alias grepvi="${common_ggrep_cmd} --invert-match --ignore-case"
common_gls_cmd="${GNU_LS} --group-directories-first --color=auto --time-style=long-iso -v"
long_gls_cmd="${common_gls_cmd} -1l --human-readable"
long_long_gls_cmd="${long_gls_cmd} --almost-all"
alias   l="${common_gls_cmd}"
alias  lo="${common_gls_cmd} -1"
alias  ll="${common_gls_cmd} -1l"
alias  la="${common_gls_cmd} -1 --almost-all"
alias ldt="${common_gls_cmd} -1lt --almost-all"
alias llh="${long_gls_cmd}"
alias alh="${long_long_gls_cmd}"
alias lah="${long_long_gls_cmd}"
alias lha="${long_long_gls_cmd}"
alias lsh="${long_long_gls_cmd}"

if command -v batcat > /dev/null; then
    alias bat="$(command -v batcat)"
fi

if command -v fdfind > /dev/null; then
    alias fd="$(command -v fdfind)"
fi

function nixos_needsreboot() {
    local NIXOS_NEEDSREBOOT_FILE='/var/run/reboot-required'
    if [[ -f "${NIXOS_NEEDSREBOOT_FILE}" ]]; then
        echo -e "\n$(tput bold)${PS0_HORIZONTAL_RULE}\nNewer version of $(cat "${NIXOS_NEEDSREBOOT_FILE}") is available!\n${PS0_HORIZONTAL_RULE}$(tput sgr0)"
    fi
}

# PS1 setup
PS0="\t|\n--------+" # display time in HH:MM:SS format
# the function needs to be called **everytime** and is in single quotes
# shellcheck disable=SC2016
PS0+='$(nixos_needsreboot)'"\n"
PS1="\n[\u@\h:\$PWD \$?]\$ "
export PS0 PS1

# zoxide setup
if command -v zoxide > /dev/null; then
    export _ZO_ECHO=1 # always print matched dir before navigating to it
    export _ZO_RESOLVE_SYMLINKS=1
    eval "$(zoxide init bash)"
fi

# for direnv (should always be at the end)
if command -v direnv > /dev/null; then
    eval "$(direnv hook bash)"
fi
