#!/usr/bin/env bash
# shellcheck disable=SC2139

# only run in an interactive shell
[[ $- == *i* ]] || return


#------------------------------------------------------------------------------#
# Early setup, mostly sourcing files
global_bashrc='/etc/bashrc'
if [[ -f "${global_bashrc}" ]]; then
    # shellcheck disable=SC1090
    source "${global_bashrc}"
    unalias -a
fi

darwin_nix_bash_completion="${HOME}/.local/share/nix-bash/bash_completion.sh"
if [[ -f "${darwin_nix_bash_completion}" ]]; then
    # shellcheck disable=SC1090
    source "${darwin_nix_bash_completion}"
fi

# this, among other things, handles the following:
# 1. Sets LOCALE_ARCHIVE* for nixpkgs binaries, absense of which, when running
#    binaries from nixpkgs on non-NixOS operating systems
# 2. Set NIX_SSL_CERT_FILE which prevents an SSL certificate error when
#    downloading files over internet with binaries from nixpkgs on non-NixOS
#    operating systems
home_manager_session_vars="${HOME}/.nix-profile/etc/profile.d/hm-session-vars.sh"
if [[ -f "${home_manager_session_vars}" ]]; then
    # shellcheck disable=SC1090
    source "${home_manager_session_vars}"
    # unset __HM_SESS_VARS_SOURCED so that `update` (re-sourcing ~/.bashrc) works when hm-session-vars.sh is updated
    # this happens when the nixpkgs expression changes and as a result PATHs change as well
    unset __HM_SESS_VARS_SOURCED
fi

# secrets, mostly work-related
secrets_file="${HOME}/.local/secrets/0-all-secrets.sh"
if [[ -f "${secrets_file}" ]]; then
    # shellcheck disable=SC1090
    source "${secrets_file}"
fi

# the only, actual "setup"
init_setup_script="${HOME}/.local/scripts/other-common-scripts/0-init.sh"
[[ -x "${init_setup_script}" ]] && "${init_setup_script}"


#------------------------------------------------------------------------------#
# Bash setup
shopt -s checkjobs
shopt -s checkwinsize
shopt -s extglob
shopt -s globstar
shopt -s histappend
HISTCONTROL='ignorespace:ignoredups:erasedups'
HISTFILESIZE=100000
HISTIGNORE="clear:history*:exit:date:whoami:l:lo:ll:la:ldt:llh:alh:lah:lha:lsh"
HISTSIZE=10000


#------------------------------------------------------------------------------#
# Global vars/flags/switches
PS0_HORIZONTAL_RULE='++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'
if ! command -v nix >/dev/null; then
    HAS_NIX=0
else
    HAS_NIX=1
fi
if [[ "$(uname -s)" == 'Linux' ]]; then
    PLATFORM_IS_LINUX=1
    if grep -q 'ID=nixos' /etc/os-release; then
        OS_TYPE=0
    else
        OS_TYPE=1
    fi
elif [[ "$(uname -s)" == 'Darwin' ]]; then
    PLATFORM_IS_LINUX=0
    OS_TYPE=2
fi


#------------------------------------------------------------------------------#
# Function declarations go here
function path_append() {
    if [[ -d "$1" ]] && [[ ":$PATH:" != *:$1:* ]]; then
        PATH="$PATH:$1"
    fi
}

function path_prepend() {
    if [[ -d "$1" ]] && [[ ":$PATH:" != *:$1:* ]]; then
        PATH="$1:$PATH"
    fi
}

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

function neovim_clean_slate() {
    rm -rf "${HOME}"/.local/{state,share}/nvim
}


#------------------------------------------------------------------------------#
# Platform-specific, conditional logic
# **ONLY DEFINE STUFF, AVOID ACTING ON STUFF
if [[ "${PLATFORM_IS_LINUX}" -eq 1 ]]; then
    GNU_LS='ls'
elif [[ "${PLATFORM_IS_LINUX}" -eq 0 ]]; then
    GNU_LS='gls'
fi


#------------------------------------------------------------------------------#
# PATH modification
mkdir -p "${HOME}/.cargo/bin"
mkdir -p "${HOME}/.local/bin"
path_append "${HOME}/.cargo/bin"
path_append "${HOME}/.local/bin"
path_append '/usr/local/bin'
path_append '/sbin'
path_append '/opt/homebrew/bin'
path_append '/opt/homebrew/sbin'
if command -v rustup >/dev/null; then
    path_prepend "${HOME}/.rustup/toolchains/$(rustup toolchain list | grep default | awk '{ print $1 }')/bin"
fi
export PATH


#------------------------------------------------------------------------------#
# Exports go here

# Unexport first, though
export -n NIX_PAGER

if command -v nvim >/dev/null; then
    EDITOR='nvim'
elif command -v vim >/dev/null; then
    EDITOR='vim'
else
    EDITOR='vi'
fi
export EDITOR

if [[ "${TERM:-}" != 'xterm-256color' ]] && [[ "${TERM:-}" != 'tmux-256color' ]]; then
    if [[ "${TERM_PROGRAM:-}" == 'tmux' ]]; then
        TERM='tmux-256color'
    else
        TERM='xterm-256color'
    fi
fi
export TERM

if command -v delta >/dev/null; then
    GIT_PAGER='delta --diff-highlight --diff-so-fancy'
    export GIT_PAGER
fi

if [[ "${PLATFORM_IS_LINUX}" -eq 1 ]]; then
    if [[ -z "${XDG_RUNTIME_DIR:-}" ]]; then
        RUNTIME_MOUNT_UNIT="run-user-$(id -u).mount"
        if systemctl --user is-active --quiet "${RUNTIME_MOUNT_UNIT}"; then
            XDG_RUNTIME_DIR="$(systemctl --user show "${RUNTIME_MOUNT_UNIT}" | grep 'Where=' | awk -F '=' '{ print $2 }')"
            # export only if this directory exists (i.e. no problems were encountered during parsing and that the value is valid)
            [[ -d "${XDG_RUNTIME_DIR:-}" ]] && export XDG_RUNTIME_DIR
        fi
    fi

    if [[ "${OS_TYPE}" -eq 1 ]]; then
        if grep -q 'debian' /etc/os-release; then
            if grep -q 'ID=debian' /etc/os-release; then
                LANG="$(grep -v '^# ' /etc/locale.gen | grep -v '^$' | head -n 1 | sed -e 's/ /./')"
                export LANG
            fi
            export NEEDRESTART_MODE='a'
            export DEBIAN_FRONTEND='noninteractive'
            export APT_LISTCHANGES_FRONTEND='none'
        fi
    fi
fi

if command -v rustup >/dev/null; then
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


#------------------------------------------------------------------------------#
# Aliases go here
# alias wrappers to call scripts
COMMON_SCRIPTS_DIR="${HOME}/.local/scripts"
SCRIPTS_DIR="${COMMON_SCRIPTS_DIR}/other-common-scripts"
EL_SCRIPTS_DIR="${COMMON_SCRIPTS_DIR}/el"
alias ampv='mpv --hwdec=vaapi --no-video'
alias createvm="env $* ${SCRIPTS_DIR}/create-libvirt-vm.sh"
alias debextract="${SCRIPTS_DIR}/extract-deb-pkg.sh"
alias gitsigncommits='git rebase --exec '\''git commit --amend --no-edit -n -S'\'' -i'
alias installrpmdeps="${EL_SCRIPTS_DIR}/install-rpm-package-build-deps.sh"
alias mockbuild="${EL_SCRIPTS_DIR}/mock-build.sh"
alias pysort="${SCRIPTS_DIR}/sort.py"
alias reviewnixpkgspr='nixpkgs-review pr --print-result'
alias rpmextract="${SCRIPTS_DIR}/extract-rpm-pkg.sh"
alias showdiskusage="${SCRIPTS_DIR}/show-disk-usage.sh"
alias startvm="env $* ${SCRIPTS_DIR}/start-qemu-vm.sh"
alias sudosync="${SCRIPTS_DIR}/paranoid-flush.sh"
alias suslock="${HOME}/.local/scripts/window-manager/lock-and-suspend.sh"
alias syncsync="${SCRIPTS_DIR}/paranoid-flush.sh"

# actual aliases (generic ones)
alias bottom='btm'
alias clear="clear && printf '\e[3J'"
alias dotfiles="git --git-dir=${HOME}/.dotfiles --work-tree=${HOME}"
alias download='aria2c --max-connection-per-server=16 --min-split-size=1M --file-allocation=none --continue=false --seed-time=0'
alias drivetemp='hdparm -CH'
alias mksshkey='ssh-keygen -t ed25519 -f'
alias mtr='mtr --show-ips --displaymode 0 -o "LDR AGJMXI"'
alias performneovimcleanup="neovim_clean_slate"
alias prettynixbuild='nix build --log-format internal-json -v . 2>&1 | nom --json'
alias serialterm="tty_serial"
alias sudo='sudo '
alias tmux="tmux -f ${HOME}/.config/tmux/tmux.conf" # tmux 3.2 and later source $XDG_CONFIG_DIR/tmux/tmux.conf, so a workaround for that
alias unxz='unxz --keep' # override 'unxz' with this to always keep the archive
alias update="source ${HOME}/.bashrc"

# rsync aliases
rsync_common_cmd='rsync --verbose --recursive --size-only --human-readable --progress --stats --itemize-changes'
alias custcp="${rsync_common_cmd}"
alias fcustcp="${rsync_common_cmd} --fsync"
alias nixcheckconf="${rsync_common_cmd} --fsync --checksum --exclude='.git' ${HOME}/my-git-repos/pratham/prathams-nixos/nixos-configuration/ /etc/nixos/ --dry-run"

if [[ "${OS_TYPE}" -eq 2 ]]; then
    alias darwindotsync="git -C ${HOME}/.dotfiles pull; ${rsync_common_cmd} --exclude='.git' --checksum ${HOME}/.dotfiles/ ${HOME}/"
fi

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

# wget/wget2 command override
if command -v wget2 >/dev/null; then
    alias wget='wget2'
else
    alias wget='wget'
fi

# yt-dlp aliases
ytdlp_common_cmd="yt-dlp --config-location ${HOME}/.config/yt-dlp/"
alias playdl="${ytdlp_common_cmd}plst_config --external-downloader aria2c"
alias ytdown="${ytdlp_common_cmd}norm_config --external-downloader aria2c"
alias ytslow="${ytdlp_common_cmd}norm_config --no-part --concurrent-fragments 1 --limit-rate 4M"

# bat
alias  bat='bat --paging=never'
alias pbat='bat --paging=always'

# nvim/vim/vi
if command -v vim >/dev/null; then
    vi_vim_cmd='vim'
else
    vi_vim_cmd='vi'
fi
alias    e="${EDITOR}" # depending on what's installed, nvim or vim or vi (in that order)
alias vvim="${vi_vim_cmd}"
alias  vim="${vi_vim_cmd}"

# fd-find
alias  fd='fd --hidden --no-ignore --follow'
alias fdi='fd --hidden --no-ignore --follow --ignore-case'

# ripgrep
ripgrep_common='rg --hidden --follow '
alias   rg="${ripgrep_common}"
alias  rgi="${ripgrep_common} --ignore-case"
alias  rgv="${ripgrep_common} --invert-match"
alias rgiv="${ripgrep_common} --invert-match --ignore-case"
alias rgvi="${ripgrep_common} --invert-match --ignore-case"

# these only exist because I need to use 'g{ls,grep}' on macOS
common_ggrep_cmd="$(command -v grep) --color=auto"
alias   grep="${common_ggrep_cmd}"
alias  grepi="${common_ggrep_cmd} --ignore-case"
alias  grepv="${common_ggrep_cmd} --invert-match"
alias grepiv="${common_ggrep_cmd} --invert-match --ignore-case"
alias grepvi="${common_ggrep_cmd} --invert-match --ignore-case"
common_gls_cmd="$(command -v "${GNU_LS}") --group-directories-first --color=auto --time-style=long-iso -v"
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

# Platform specific overrides go here
if [[ "${OS_TYPE}" -ne 0 ]]; then
    if [[ "${HAS_NIX}" -eq 1 ]]; then
        # This alias exists to enable me to execute binaries provided by home-manager with `sudo`.
        # Only needed on Darwin/non-NixOS Linux distros when Nix is installed.
        alias envsudo='sudo --preserve-env=PATH env'
    fi
fi
if [[ "${OS_TYPE}" -eq 0 ]]; then
    alias nixosgencompare='readlink /nix/var/nix/profiles/$(readlink /nix/var/nix/profiles/system) /run/booted-system'
fi

if [[ "${PLATFORM_IS_LINUX}" -eq 1 ]]; then
    alias ping='ping -W 0.1 -O'
    alias mpv='mpv --geometry=60% --vo=gpu --hwdec=vaapi'
    alias mpvrpi='mpv --geometry=60% --vo=x11'

    if [[ "${XDG_SESSION_TYPE:-}" == 'x11' ]]; then
        alias clearclipboard='xsel -bc'
        alias pbcopy='xsel --clipboard --input'
    elif [[ "${XDG_SESSION_TYPE:-}" == 'wayland' ]]; then
        if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
            alias clearclipboard='cliphist wipe && wl-copy --clear'
        else
            alias clearclipboard='wl-copy --clear'
        fi
        alias pbcopy='wl-copy'
    fi

elif [[ "${OS_TYPE}" -eq 2 ]]; then
    alias ktb='sudo pkill TouchBarServer; sudo killall ControlStrip'
    alias mpv='mpv --vo=libmpv'
    alias ownefivars="chmod +uw ${HOME}/Library/Containers/com.utmapp.UTM/Data/Documents/*.utm/Data/efi_vars.fd"
fi

# RPM land thingies
export PERIDOT_CLIENT_ID="${PERIDOT_CLIENT_ID:-}"
export PERIDOT_CLIENT_SECRET="${PERIDOT_CLIENT_SECRET:-}"
export PERIDOT_ENDPOINT="${PERIDOT_ENDPOINT:-}"
export PERIDOT_HDR_ENDPOINT="${PERIDOT_HDR_ENDPOINT:-}"
export RAAS_ENDPOINT="${PERIDOT_ENDPOINT:-}"
export RAAS_CLIENT_ID="${PERIDOT_CLIENT_ID:-}"
export RAAS_CLIENT_SECRET="${PERIDOT_CLIENT_SECRET:-}"
export RAAS_HDR_ENDPOINT="${PERIDOT_HDR_ENDPOINT:-}"

# this function is intentionally kept here to make the future cleanup easier
function create_hashed_repo() {
    if [[ -z "${2:-}" ]]; then
        # shellcheck disable=SC2016
        echo 'Need project ID ($1) and hashed-repo name ($2).'
    else
        peridot --project-id "$1" project create-hashed-repos "$2"
    fi
}
alias peridotupload='peridot lookaside upload'

#------------------------------------------------------------------------------#
# PS1 setup
function nixos_needsreboot() {
    local NIXOS_NEEDSREBOOT_FILE='/var/run/reboot-required'
    if [[ -f "${NIXOS_NEEDSREBOOT_FILE}" ]]; then
        echo -e "\n$(tput bold)${PS0_HORIZONTAL_RULE}\nNewer version of $(cat "${NIXOS_NEEDSREBOOT_FILE}") is available!\n${PS0_HORIZONTAL_RULE}$(tput sgr0)"
    fi
}

PS0="\t|\n--------+" # display time in HH:MM:SS format
# the function needs to be called **everytime** and is in single quotes
# shellcheck disable=SC2016
PS0+='$(nixos_needsreboot)'"\n"
PS1="\n[\u@\h:\$PWD \$?]\$ "
export PS0 PS1


#------------------------------------------------------------------------------#
# Things that need to be called at the very end
if command -v zoxide >/dev/null; then
    export _ZO_ECHO=1 # always print matched dir before navigating to it
    export _ZO_RESOLVE_SYMLINKS=1
    eval "$(zoxide init bash)"
fi

# for direnv (should always be at the end)
if command -v direnv >/dev/null; then
    eval "$(direnv hook bash)"
fi


#------------------------------------------------------------------------------#
# Hyprland launch shenanigans
if [[ "$(tty)" == '/dev/tty1' ]] && command -v Hyprland >/dev/null && ! pgrep --uid "$(id -u)" Hyprland >/dev/null; then
    exec Hyprland
fi
