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

function initial_fish_setup
    fish_load_sudo_alias
    fish_vi_key_bindings
end

if status is-interactive
    set fish_greeting # disable the "new user" prompt
    initial_fish_setup # call all "setup functions" here

    # git prompt options
    set -gx __fish_git_prompt_show_informative_status true
    set -gx __fish_git_prompt_showdirtystate true
    set -gx __fish_git_prompt_showuntrackedfiles true
    set -gx __fish_git_prompt_showupstream verbose
    set -gx __fish_git_prompt_showstashstate true
    set -gx __fish_git_prompt_describe_style branch
    set -gx __fish_git_prompt_showcolorhints true

    # set locale manually because even though NixOS handles the 'en_IN' locale
    # it doesn't append the string '.UTF-8' to LC_*
    # but, UTF-8 **is supported**, so just go ahead and set it manually
    set -gx LANG "en_IN.UTF-8"
    set -gx LC_ADDRESS "en_IN.UTF-8"
    set -gx LC_COLLATE "en_IN.UTF-8"
    set -gx LC_CTYPE "en_IN.UTF-8"
    set -gx LC_IDENTIFICATION "en_IN.UTF-8"
    set -gx LC_MEASUREMENT "en_IN.UTF-8"
    set -gx LC_MESSAGES "en_IN.UTF-8"
    set -gx LC_MONETARY "en_IN.UTF-8"
    set -gx LC_NAME "en_IN.UTF-8"
    set -gx LC_NUMERIC "en_IN.UTF-8"
    set -gx LC_PAPER "en_IN.UTF-8"
    set -gx LC_TELEPHONE "en_IN.UTF-8"
    set -gx LC_TIME "en_IN.UTF-8"
    set -gx LC_ALL ""

    set -gx FUNCTIONS_DIR "$HOME/.local/scripts/common-shell-scripts"

    # common aliases
    alias showdiskusage="bash $HOME/.local/scripts/other-common-scripts/show-disk-usage.sh"
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
    alias ping="ping -W 0.1 -O"
    alias mpv="mpv --geometry=60% --vo=gpu --hwdec=vaapi"
    alias serialterm="clear && sudo picocom --quiet -b 115200 /dev/ttyUSB0"
    alias suslock="bash $HOME/.local/scripts/window-manager/lock-and-suspend.sh"
    alias drivetemp="hdparm -CH /dev/sda /dev/sdb /dev/sdc /dev/sdd"
    alias paru="LESS=SRX paru"
    alias clear="clear && printf '\e[3J'"

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
        if test $XDG_SESSION_TYPE = "x11"
            alias clearclipboard="xsel -bc"
            alias pbcopy="xsel --clipboard --input"
        else if test $XDG_SESSION_TYPE = "wayland"
            alias clearclipboard="wl-copy --clear"
            alias pbcopy="wl-copy"
        end
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
