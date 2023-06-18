if status is-interactive
    set fish_greeting # disable the "new user" prompt

    set -g FUNCTIONS_DIR "$HOME/.local/scripts/common-shell-scripts"

    # common aliases
    alias showdiskusage="bash $HOME/.local/scripts/other-common-scripts/showdiskusage.sh"
    alias dotfiles="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
    alias nixrebuild="nixos-rebuild boot"
    alias nixupgrade="nixos-rebuild boot --upgrade"
    alias nixgarbageclean="nix-collect-garbage -d"
    alias mtr="mtr --show-ips --displaymode 0 -o \"LDR AGJMXI\""
    alias update="source $HOME/.config/fish/config.fish"
    alias custcp="rsync --fsync --verbose --recursive --size-only --human-readable --progress --stats --itemize-changes"
    alias pysort="python3 $HOME/.local/scripts/other-common-scripts/sort.py"
    alias download="aria2c -x 16 -k 1M --file-allocation=none --continue=false --seed-time=0"
    alias ytdown="yt-dlp --config-location $HOME/.config/yt-dlp/norm_config --external-downloader aria2c"
    alias playdl="yt-dlp --config-location $HOME/.config/yt-dlp/plst_config --external-downloader aria2c"
    alias ytslow="yt-dlp --config-location $HOME/.config/yt-dlp/norm_config --no-part --concurrent-fragments 1 --limit-rate 4M"
    alias rgi="rg --hidden -i"
    alias rgv="rg --hidden -v"
    alias rgvi="rg --hidden -vi"
    alias rgiv="rg --hidden -vi"
    alias unxz="unxz -k"
    alias dig="$(command -v dog)"
    alias l="ls --group-directories-first --color=auto -v"
    alias ll="ls --group-directories-first --color=auto -1lv --time-style=long-iso"
    alias la="ls --group-directories-first --color=auto -1Av --time-style=long-iso"
    alias lo="ls --group-directories-first --color=auto -1v"
    alias llh="ls --group-directories-first --color=auto -1hlv --time-style=long-iso"
    alias lah="ls --group-directories-first --color=auto -1Ahlv --time-style=long-iso"
    alias ldt="ls --group-directories-first --color=auto -1Altv --time-style=long-iso"
    alias grep="grep --color=auto"
    alias greplv="grep --color=auto -lv"
    alias grepli="grep --color=auto -li"
    alias grepv="grep --color=auto -v"
    alias grepi="grep --color=auto -i"
    alias flameboi="ssh flameboi.lan"
    alias sentinel="ssh sentinel.lan"
    alias reddish="ssh reddish.lan"
    alias vasudev="ssh vasu.dev"
    alias pingflameboi="ping 10.0.0.13"
    alias pingsentinel="ping 10.0.0.14"
    alias pingreddish="ping 10.0.0.19"
    alias flatpakupdates="flatpak remote-ls --updates flathub"
    alias flatpakautoremove="flatpak remove --unused --delete-data"
    alias mpv="mpv --geometry=60% --vo=gpu --hwdec=vaapi"
    alias serialterm="clear && sudo picocom --quiet -b 115200 /dev/ttyUSB0"
    alias suslock="$HOME/.local/scripts/window-manager/lock-and-suspend.sh"
    alias drivetemp="hdparm -CH /dev/sda /dev/sdb /dev/sdc /dev/sdd"
    alias paru="LESS=SRX paru"
    alias undeb="dpkg-deb -xv"
    alias clear="clear && printf '\e[3J'"

    if test $(command -v batcat > /dev/null)
        alias bat="$(command -v batcat)"
    end

    if test $(command -v dig > /dev/null)
        alias olddig="$(command -v dig)"
        alias digdig="$(command -v dig)"
    end

    if test $XDG_SESSION_TYPE = "x11"
        alias clearclipboard="xsel -bc"
        alias pbcopy="xsel --clipboard --input"
    else if test $XDG_SESSION_TYPE = "wayland"
        alias clearclipboard="wl-copy --clear"
        alias pbcopy="wl-copy"
    end

    # TODO: functions in $HOME/.local/scripts/common-shell-scripts
    #owndisk
    #containerdisableall
    #containerenableall
    #containerstopall
    #containerstartall
    #containerstats
    #towebp
    #togif

    if test $(uname) = "Darwin"
        alias l="$(command -v gls) --group-directories-first --color=auto -v"
        alias ll="$(command -v gls) --group-directories-first --color=auto -1lv --time-style=long-iso"
        alias la="$(command -v gls) --group-directories-first --color=auto -1Av --time-style=long-iso"
        alias lo="$(command -v gls) --group-directories-first --color=auto -1v"
        alias llh="$(command -v gls) --group-directories-first --color=auto -1hlv --time-style=long-iso"
        alias lah="$(command -v gls) --group-directories-first --color=auto -1Ahlv --time-style=long-iso"
        alias ldt="$(command -v gls) --group-directories-first --color=auto -1Altv --time-style=long-iso"
        alias grep="$(command -v ggrep) --color=auto"
        alias greplv="$(command -v ggrep) --color=auto -lv"
        alias grepli="$(command -v ggrep) --color=auto -li"
        alias grepv="$(command -v ggrep) --color=auto -v"
        alias grepi="$(command -v ggrep) --color=auto -i"
        alias ktb="sudo pkill TouchBarServer; sudo killall ControlStrip"
        alias mpv="mpv --vo=libmpv"
    end
end

function fish_prompt
    #[pratham@nixvm:~]$
    #echo "[$(whoami)@$(prompt_hostname):$(set_color blue)$(prompt_pwd)$(set_color red)$(fish_git_prompt) $(set_color yellow)$prompt_symbol ]$(set_color normal) "
    set -l prompt_symbol '$'
    fish_is_root_user; and set prompt_symbol '#'

    if test -d ".git"
        echo -sne [(whoami)@(prompt_hostname):(set_color blue)(pwd)(set_color brwhite)\ $status(set_color brred)(fish_git_prompt)(set_color normal)]\n$prompt_symbol\ 
    else
        echo -sne [(whoami)@(prompt_hostname):(set_color blue)(pwd)(set_color brwhite)\ $status(set_color normal)]\n$prompt_symbol\ 
    end
end
