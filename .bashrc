# shellcheck disable=SC2139
# The above directive disables https://www.shellcheck.net/wiki/SC2139
dash "${HOME}/.local/scripts/other-common-scripts/alacritty-import.sh"

unalias -a
if [[ "$(uname)" == 'Linux' ]]; then
    GNU_LS="$(command -v ls)"
    GNU_GREP="$(command -v grep)"
    export GNU_LS
    export GNU_GREP

    alias custcp="rsync --fsync --verbose --recursive --size-only --human-readable --progress --stats --itemize-changes"
    alias ping="ping -W 0.1 -O"

    if [[ "${XDG_SESSION_TYPE}" == 'x11' ]]; then
        alias clearclipboard="xsel -bc"
        alias pbcopy="xsel --clipboard --input"
    elif [[ "${XDG_SESSION_TYPE}" == 'wayland' ]]; then
        alias clearclipboard="wl-copy --clear"
        alias pbcopy="wl-copy"
    fi
fi

if [[ "$(uname)" == 'Darwin' ]]; then
    GNU_LS="$(command -v gls)"
    GNU_GREP="$(command -v ggrep)"
    export GNU_LS
    export GNU_GREP

    case ":$PATH:" in
        *":/usr/local/bin:"*) :;; # already there
        *) PATH="/usr/local/bin:$PATH";; # absent, so add
    esac

    alias ktb="sudo pkill TouchBarServer; sudo killall ControlStrip"
    alias mpv="mpv --vo=libmpv"
fi

alias showdiskusage="bash ${HOME}/.local/scripts/other-common-scripts/show-disk-usage.sh"
alias dotfiles="git --git-dir=${HOME}/.dotfiles --work-tree=${HOME}"
alias prettynixbuild="nix build --log-format internal-json -v . 2>&1 | nom --json"
alias nixrebuild="nixos-rebuild boot"
alias nixupgrade="nixos-rebuild boot --upgrade"
alias nixgarbageclean="nix-collect-garbage --delete-old"
alias specmacroexpand="rpmspec --parse"
alias getspecsources="spectool --get-files --sourcedir"
alias rpmextract="dash ${HOME}/.local/scripts/other-common-scripts/extract-rpm-files.sh"
alias rpmxf="dash ${HOME}/.local/scripts/other-common-scripts/extract-rpm-files.sh"
alias mtr="mtr --show-ips --displaymode 0 -o \"LDR AGJMXI\""
alias update="source ${HOME}/.bashrc"
alias writeimage="sudo dd bs=1M oflag=direct,sync status=progress"
alias writeimg="sudo dd bs=1M oflag=direct,sync status=progress"
alias custcp="rsync --verbose --recursive --size-only --human-readable --progress --stats --itemize-changes"
alias pysort="python3 ${HOME}/.local/scripts/other-common-scripts/sort.py"
alias download="aria2c --max-connection-per-server=16 --min-split-size=1M --file-allocation=none --continue=false --seed-time=0"
alias ytdown="yt-dlp --config-location ${HOME}/.config/yt-dlp/norm_config --external-downloader aria2c"
alias playdl="yt-dlp --config-location ${HOME}/.config/yt-dlp/plst_config --external-downloader aria2c"
alias ytslow="yt-dlp --config-location ${HOME}/.config/yt-dlp/norm_config --no-part --concurrent-fragments 1 --limit-rate 4M"
alias rgi="rg --hidden --ignore-case"
alias rgv="rg --hidden --invert-match"
alias rgvi="rg --hidden --invert-match --ignore-case"
alias rgiv="rg --hidden --invert-match --ignore-case"
alias unxz="unxz --keep"
alias l="${GNU_LS} --group-directories-first --color=auto -v"
alias ll="${GNU_LS} --group-directories-first --color=auto -1lv --time-style=long-iso"
alias la="${GNU_LS} --group-directories-first --color=auto -1v --time-style=long-iso --almost-all"
alias lo="${GNU_LS} --group-directories-first --color=auto -1v"
alias llh="${GNU_LS} --group-directories-first --color=auto -1lv --time-style=long-iso --human-readable"
alias lah="${GNU_LS} --group-directories-first --color=auto -1lv --time-style=long-iso --human-readable --almost-all"
alias lsh="${GNU_LS} --group-directories-first --color=auto -1lv --time-style=long-iso --human-readable --almost-all"
alias ldt="${GNU_LS} --group-directories-first --color=auto -1ltv --time-style=long-iso --almost-all"
alias grep="${GNU_GREP} --color=auto"
alias grepv="${GNU_GREP} --color=auto --invert-match"
alias grepi="${GNU_GREP} --color=auto --ignore-case"
alias grepvi="${GNU_GREP} --color=auto --invert-match --ignore-case"
alias grepiv="${GNU_GREP} --color=auto --invert-match --ignore-case"
alias flameboi="ssh flameboi"
alias mahadev="ssh mahadev"
alias reddish="ssh reddish"
alias sentinel="ssh sentinel"
alias vasudev="ssh vasudev"
alias pingflameboi="ping 10.0.0.13"
alias pingsentinel="ping 10.0.0.14"
alias pingreddish="ping 10.0.0.19"
alias mpv="mpv --geometry=60% --vo=gpu --hwdec=vaapi"
alias serialterm="clear && picocom --quiet --baud 115200 /dev/ttyUSB0"
alias suslock="bash ${HOME}/.local/scripts/window-manager/lock-and-suspend.sh"
alias drivetemp="hdparm -CH /dev/sda /dev/sdb /dev/sdc /dev/sdd"
alias paru="LESS=SRX paru"
alias clear="clear && printf '\e[3J'"
alias lomount="sudo losetup --partscan --find --show"
alias bottom="btm"

if command -v batcat > /dev/null; then
    alias bat="$(command -v batcat)"
fi

if command -v nvim > /dev/null; then
    alias vvim="$(command -v vim)"
    alias vim="$(command -v nvim)"
fi

PS1='[\u@\h \W]\$ '

# for direnv (should always be at the end)
if command -v direnv > /dev/null; then
    eval "$(direnv hook bash)"
fi
