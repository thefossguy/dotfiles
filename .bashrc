#!/usr/bin/env bash
# shellcheck disable=SC2139

# only run in an interactive shell
[[ $- == *i* ]] || return

unalias -a

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

elif [[ "$(uname -s)" == 'Darwin' ]]; then
    GNU_LS="$(command -v gls)"
    GNU_GREP="$(command -v ggrep)"

    alias ktb='sudo pkill TouchBarServer; sudo killall ControlStrip'
    alias mpv='mpv --vo=libmpv'

    path_add '/usr/local/bin'
fi

path_add "${HOME}/.cargo/bin"
path_add "${HOME}/.local/bin"
export PATH

# alias wrappers to call scripts
SCRIPTS_DIR="${HOME}/.local/scripts/other-common-scripts"
alias debextract="${SCRIPTS_DIR}/extract-deb-pkg.sh"
alias pysort="${SCRIPTS_DIR}/sort.py"
alias rpmextract="${SCRIPTS_DIR}/extract-rpm-pkg.sh"
alias showdiskusage="${SCRIPTS_DIR}/show-disk-usage.sh"
alias suslock="${HOME}/.local/scripts/window-manager/lock-and-suspend.sh"
alias syncsync="${SCRIPTS_DIR}/paranoid-flush.sh"
alias startvm="${SCRIPTS_DIR}/start-qemu-vm.sh"

# actual aliases (generic ones)
RSYNC_OPTIONS='--verbose --recursive --size-only --human-readable --progress --stats --itemize-changes'
alias bottom='btm'
alias clear="clear && printf '\e[3J'"
alias dotfiles="git --git-dir=${HOME}/.dotfiles --work-tree=${HOME}"
alias download='aria2c --max-connection-per-server=16 --min-split-size=1M --file-allocation=none --continue=false --seed-time=0'
alias drivetemp='hdparm -CH'
alias mtr='mtr --show-ips --displaymode 0 -o "LDR AGJMXI"'
alias nixcheckconf="rsync --fsync ${RSYNC_OPTIONS} --dry-run --checksum ${HOME}/my-git-repos/pratham/prathams-nixos/nixos-configuration/ /etc/nixos/"
alias prettynixbuild='nix build --log-format internal-json -v . 2>&1 | nom --json'
alias serialterm='clear && picocom --quiet --baud 115200 /dev/ttyUSB0'
alias unxz='unxz --keep' # override 'unxz' with this to always keep the archive
alias update="source ${HOME}/.bashrc"
alias rgvi='rg --hidden --invert-match --ignore-case'

# rsync
alias custcp="rsync ${RSYNC_OPTIONS}"
alias fcustcp="rsync --fsync ${RSYNC_OPTIONS}"

# yt-dlp related aliases
alias playdl="yt-dlp --config-location ${HOME}/.config/yt-dlp/plst_config --external-downloader aria2c"
alias ytdown="yt-dlp --config-location ${HOME}/.config/yt-dlp/norm_config --external-downloader aria2c"
alias ytslow="yt-dlp --config-location ${HOME}/.config/yt-dlp/norm_config --no-part --concurrent-fragments 1 --limit-rate 4M"

# ripgrep
alias rgi='rg --hidden --ignore-case'
alias rgiv='rg --hidden --invert-match --ignore-case'
alias rgv='rg --hidden --invert-match'

# these only exist because I need to use 'g{ls,grep}' on macOS
alias grep="${GNU_GREP} --color=auto"
alias grepi="${GNU_GREP} --color=auto --ignore-case"
alias grepv="${GNU_GREP} --color=auto --invert-match"
alias grepiv="${GNU_GREP} --color=auto --invert-match --ignore-case"
alias grepvi="${GNU_GREP} --color=auto --invert-match --ignore-case"
alias l="${GNU_LS} --group-directories-first --color=auto -v"
alias lo="${GNU_LS} --group-directories-first --color=auto -1v"
alias ll="${GNU_LS} --group-directories-first --color=auto -1lv --time-style=long-iso"
alias la="${GNU_LS} --group-directories-first --color=auto -1v --time-style=long-iso --almost-all"
alias ldt="${GNU_LS} --group-directories-first --color=auto -1ltv --time-style=long-iso --almost-all"
alias llh="${GNU_LS} --group-directories-first --color=auto -1lv --time-style=long-iso --human-readable"
alias lah="${GNU_LS} --group-directories-first --color=auto -1lv --time-style=long-iso --human-readable --almost-all"
alias lsh="${GNU_LS} --group-directories-first --color=auto -1lv --time-style=long-iso --human-readable --almost-all"

if command -v batcat > /dev/null; then
    alias bat="$(command -v batcat)"
fi

if command -v nvim > /dev/null; then
    alias vvim="$(command -v vim)"
    alias vim="$(command -v nvim)"
fi

# the 'git-prompt.sh' file exists at different locations in different distributions
# so tell shellcheck to ignore checking that file
# shellcheck source=/dev/null
[[ -f "${SCRIPTS_DIR}/git-prompt.sh" ]] && source "${SCRIPTS_DIR}/git-prompt.sh"
_RED="$(tput setaf 1)"
_BR_RED="$(tput bold)${_RED}"
_GREEN="$(tput setaf 2)"
_BR_GREEN="$(tput bold)${_GREEN}"
_YELLOW="$(tput setaf 3)"
_BR_YELLOW="$(tput bold)${_YELLOW}"
_MAGENTA="$(tput setaf 5)"
_BR_MAGENTA="$(tput bold)${_MAGENTA}"
_CYAN="$(tput setaf 6)"
_BR_CYAN="$(tput bold)${_CYAN}"
_WHITE="$(tput setaf 7)"
_BR_WHITE="$(tput bold)${_WHITE}"
_GRAY="$(tput setaf 244)"
_BR_GRAY="$(tput bold)${_GRAY}"
_RESET="$(tput sgr0)"
function __prompt_begin() {
    echo -ne "\n\[${_YELLOW}\]─┬─[\[${_RESET}\]"
}
function __prompt_hostname() {
    echo -n "\[${_RED}\]\h\[${_RESET}\]\[${_CYAN}\]:\[${_RESET}\]"
}
function __prompt_username() {
    echo -n "\[${_CYAN}\]\u\[${_RESET}\]"
}
function __prompt_git() {
    __git_ps1 " (%s)"
}
function __prompt_status() {
    if [[ "$1" -ne 0 ]]; then
        echo -n "${_BR_RED}$1${_RESET}"
    else
        echo -n "${_BR_GREEN}$1${_RESET}"
    fi
}
function __prompt_end() {
    echo -ne "\[${_YELLOW}\]]\n ╰─>\[${_RESET}\] "
}
export GIT_PS1_SETCONFLICTSPACE=1
export GIT_PS1_SHOWCOLORHINTS=1
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM="verbose"
PS1="$(__prompt_begin) $(__prompt_hostname) $(__prompt_username) \[${_GRAY}\]▶\[${_RESET}\] \[${_CYAN}\]\$PWD\[${_RESET}\]\$(__git_ps1) \$(__prompt_status \$?) $(__prompt_end)"
export PS1

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
