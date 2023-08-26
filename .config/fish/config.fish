function fish_load_sudo_alias
    function sudo
        if functions -q -- "$argv[1]"
            # Create a string which quotes each of the original arguments
            # so that they can be safely passed into the new fish
            # instance that is called by sudo.
            set cmdline (
                for arg in $argv
                    printf "\"%s\" " $arg
                end
            )

            # We need to pass the function source to another fish instance.
            # Since it is multi-line, any attempt to store the function in a
            # variable results in an array, which also can't be passed to
            # another fish instance.
            #
            # So first we escape the existing function (mostly in case it
            # has '\n' literals in it, then we join it on "\n".
            #
            # After passing it into fish, the new shell splits it,
            # unescapes it, and passes the function declaration to
            # `source`, which loads it into memory in the new shell.
            set -x function_src (string join "\n" (string escape --style=var (functions "$argv[1]")))
            set argv fish -c 'string unescape --style=var (string split "\n" $function_src) | source; '$cmdline
            command sudo -E $argv
        else
            command sudo $argv
        end
    end
end

function fish_mode_prompt
end

function setup_alacritty_for_os
    dash "$HOME/.local/scripts/other-common-scripts/alacritty-import.sh" &
end

function initial_fish_setup
    setup_alacritty_for_os
    fish_load_sudo_alias
    fish_vi_key_bindings
end

if status is-interactive
    set fish_greeting # disable the "new user" prompt
    initial_fish_setup # call all "setup functions" here

    # git prompt options
    # these are not in '/etc/nixos/configuration.nix' for following reasons
    # - I use fish on macOS
    # - these are not needed system wide, only for the fish shell itself
    set -gx __fish_git_prompt_show_informative_status true
    set -gx __fish_git_prompt_showdirtystate true
    set -gx __fish_git_prompt_showuntrackedfiles true
    set -gx __fish_git_prompt_showupstream verbose
    set -gx __fish_git_prompt_showstashstate true
    set -gx __fish_git_prompt_describe_style branch
    set -gx __fish_git_prompt_showcolorhints true

    # common aliases
    alias showdiskusage="bash $HOME/.local/scripts/other-common-scripts/show-disk-usage.sh"
    alias dotfiles="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
    alias nixrebuild="nixos-rebuild boot"
    alias nixupgrade="nixos-rebuild boot --upgrade"
    alias nixgarbageclean="nix-collect-garbage --delete-old"
    alias specmacroexpand="rpmspec --parse"
    alias getspecsources="spectool --get-files --sourcedir"
    alias rpmextract="dash $HOME/.local/scripts/other-common-scripts/extract-rpm-files.sh"
    alias rpmxf="dash $HOME/.local/scripts/other-common-scripts/extract-rpm-files.sh"
    alias mtr="mtr --show-ips --displaymode 0 -o \"LDR AGJMXI\""
    alias update="source $HOME/.config/fish/config.fish"
    alias writeimage="sudo dd bs=1M oflag=direct,sync status=progress"
    alias writeimg="sudo dd bs=1M oflag=direct,sync status=progress"
    alias custcp="rsync --verbose --recursive --size-only --human-readable --progress --stats --itemize-changes"
    alias pysort="python3 $HOME/.local/scripts/other-common-scripts/sort.py"
    alias download="aria2c --max-connection-per-server=16 --min-split-size=1M --file-allocation=none --continue=false --seed-time=0"
    alias ytdown="yt-dlp --config-location $HOME/.config/yt-dlp/norm_config --external-downloader aria2c"
    alias playdl="yt-dlp --config-location $HOME/.config/yt-dlp/plst_config --external-downloader aria2c"
    alias ytslow="yt-dlp --config-location $HOME/.config/yt-dlp/norm_config --no-part --concurrent-fragments 1 --limit-rate 4M"
    alias rgi="rg --hidden --ignore-case"
    alias rgv="rg --hidden --invert-match"
    alias rgvi="rg --hidden --invert-match --ignore-case"
    alias rgiv="rg --hidden --invert-match --ignore-case"
    alias unxz="unxz --keep"
    alias l="ls --group-directories-first --color=auto -v"
    alias ll="ls --group-directories-first --color=auto -1lv --time-style=long-iso"
    alias la="ls --group-directories-first --color=auto -1v --time-style=long-iso --almost-all"
    alias lo="ls --group-directories-first --color=auto -1v"
    alias llh="ls --group-directories-first --color=auto -1lv --time-style=long-iso --human-readable"
    alias lah="ls --group-directories-first --color=auto -1lv --time-style=long-iso --human-readable --almost-all"
    alias lsh="ls --group-directories-first --color=auto -1lv --time-style=long-iso --human-readable --almost-all"
    alias ldt="ls --group-directories-first --color=auto -1ltv --time-style=long-iso --almost-all"
    alias grep="grep --color=auto"
    alias grepv="grep --color=auto --invert-match"
    alias grepi="grep --color=auto --ignore-case"
    alias grepvi="grep --color=auto --invert-match --ignore-case"
    alias grepiv="grep --color=auto --invert-match --ignore-case"
    alias flameboi="ssh flameboi.lan"
    alias sentinel="ssh sentinel.lan"
    alias reddish="ssh reddish.lan"
    alias vasudev="ssh vasu.dev"
    alias bodhi="ssh bodhi.comp"
    alias pingflameboi="ping 10.0.0.13"
    alias pingsentinel="ping 10.0.0.14"
    alias pingreddish="ping 10.0.0.19"
    alias mpv="mpv --geometry=60% --vo=gpu --hwdec=vaapi"
    alias serialterm="clear && picocom --quiet --baud 115200 /dev/ttyUSB0"
    alias suslock="bash $HOME/.local/scripts/window-manager/lock-and-suspend.sh"
    alias drivetemp="hdparm -CH /dev/sda /dev/sdb /dev/sdc /dev/sdd"
    alias paru="LESS=SRX paru"
    alias clear="clear && printf '\e[3J'"
    alias lomount="sudo losetup --partscan --find --show"
    alias bottom="btm"

    if command -v batcat > /dev/null
        alias bat="$(command -v batcat)"
    end

    if command -v dig > /dev/null
        alias olddig="$(command -v dig)"
        alias digdig="$(command -v dig)"
        alias dig="$(command -v dog)"
    end

    if command -v nvim > /dev/null
        alias vvim="$(command -v vim)"
        alias vim="$(command -v nvim)"
    end

    if test $(uname) = "Linux"
        alias custcp="rsync --fsync --verbose --recursive --size-only --human-readable --progress --stats --itemize-changes"
        alias ping="ping -W 0.1 -O"
        if test $XDG_SESSION_TYPE = "x11"
            alias clearclipboard="xsel -bc"
            alias pbcopy="xsel --clipboard --input"
        else if test $XDG_SESSION_TYPE = "wayland"
            alias clearclipboard="wl-copy --clear"
            alias pbcopy="wl-copy"
        end
    end

    if test $(uname) = "Darwin"
        fish_add_path -p -g /usr/local/bin

        alias l="$(command -v gls) --group-directories-first --color=auto -v"
        alias ll="$(command -v gls) --group-directories-first --color=auto -1lv --time-style=long-iso"
        alias la="$(command -v gls) --group-directories-first --color=auto -1v --time-style=long-iso --almost-all"
        alias lo="$(command -v gls) --group-directories-first --color=auto -1v"
        alias llh="$(command -v gls) --group-directories-first --color=auto -1lv --time-style=long-iso --human-readable"
        alias lah="$(command -v gls) --group-directories-first --color=auto -1lv --time-style=long-iso --human-readable --almost-all"
        alias lsh="$(command -v gls) --group-directories-first --color=auto -1lv --time-style=long-iso --human-readable --almost-all"
        alias ldt="$(command -v gls) --group-directories-first --color=auto -1ltv --time-style=long-iso --almost-all"
        alias grep="$(command -v ggrep) --color=auto"
        alias grepv="$(command -v ggrep) --color=auto --invert-match"
        alias grepi="$(command -v ggrep) --color=auto --ignore-case"
        alias grepvi="$(command -v ggrep) --color=auto --invert-match --ignore-case"
        alias grepiv="$(command -v ggrep) --color=auto --invert-match --ignore-case"
        alias ktb="sudo pkill TouchBarServer; sudo killall ControlStrip"
        alias mpv="mpv --vo=libmpv"
    end
end


function __fish_print_pipestatus --description "Print pipestatus for prompt"
    set -l last_status
    if set -q __fish_last_status
        set last_status $__fish_last_status
    else
        set last_status $argv[-1] # default to $pipestatus[-1]
    end
    set -l left_brace $argv[1]
    set -l right_brace $argv[2]
    set -l separator $argv[3]
    set -l brace_sep_color $argv[4]
    set -l status_color $argv[5]

    set -e argv[1 2 3 4 5]

    if not set -q argv[1]
        echo error: missing argument >&2
        status print-stack-trace >&2
        return 1
    end

    set -l sep $brace_sep_color$separator$status_color
    set -l last_pipestatus_string (fish_status_to_signal $argv | string join "$sep")
    set -l last_status_string ""
    if test "$last_status" -ne "$argv[-1]"
        set last_status_string " "$status_color$last_status
    end
    set -l normal (set_color normal)
    # The "normal"s are to reset modifiers like bold - see #7771.
    printf "%s" $normal $brace_sep_color $left_brace \
        $status_color $last_pipestatus_string \
        $normal $brace_sep_color $right_brace $normal $last_status_string $normal
end

function fish_prompt
    set -l last_pipestatus $pipestatus
    set -lx __fish_last_status $status # Export for __fish_print_pipestatus.
    set -q fish_color_status
    or set -g fish_color_status red

    # Color the prompt differently when we're root
    set -l fish_color_cwd cyan
    set -l color_cwd $fish_color_cwd
    set -l suffix '>'
    if functions -q fish_is_root_user; and fish_is_root_user
        if set -q fish_color_cwd_root
            set color_cwd $fish_color_cwd_root
        end
        set suffix '#'
    end

    # Write pipestatus
    # If the status was carried over (if no command is issued or if `set` leaves the status untouched), don't bold it.
    set -l bold_flag --bold
    set -q __fish_prompt_status_generation; or set -g __fish_prompt_status_generation $status_generation
    if test $__fish_prompt_status_generation = $status_generation
        set bold_flag
    end
    set __fish_prompt_status_generation $status_generation
    set -l status_color (set_color $fish_color_status)
    set -l statusb_color (set_color $bold_flag $fish_color_status)
    set -l prompt_status (__fish_print_pipestatus "" "" "|" "$status_color" "$statusb_color" $last_pipestatus)

    echo -n -s -e "\n$(set_color yellow)─┬─[ $(set_color brred)$hostname: $(set_color white)$USER $(set_color brblack)▶ $(set_color $color_cwd)$PWD$(set_color brwhite)$(fish_vcs_prompt)$(set_color normal) $prompt_status $(set_color yellow)]\n ╰─$suffix "
end
