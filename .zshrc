
# if not running interactively, do not do anything
case $- in
    *i*) ;;
    *) return;;
esac

# load ~/.zsh_aliases if it exists
if [[ -f "$HOME/.zsh_aliases" ]]; then
    source $HOME/.zsh_aliases
fi

# load keybinds if they exist
if [[ -f "$HOME/.zkbd/$TERM" ]]; then
    source $HOME/.zkbd/$TERM
    [[ -n ${key[Home]} ]] && bindkey "${key[Home]}" beginning-of-line
    [[ -n ${key[End]} ]] && bindkey "${key[End]}" end-of-line
    [[ -n ${key[Delete]} ]] && bindkey "${key[Delete]}" delete-char
fi

export TERM="xterm-256color"
#bindkey "^[[H" beginning-of-line
#bindkey "^[[F" end-of-line
#bindkey "^[[3~" delete-char

# enable ZSH history
export HISTFILE=$HOME/.sh_history
export HISTFILESIZE=1000000000
export HISTSIZE=1000000000
export SAVEHIST=1000000000
# refer to https://linux.die.net/man/1/zshoptions
setopt APPEND_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_BY_COPY
setopt INC_APPEND_HISTORY

# keep the space after tab auto-completion
ZLE_REMOVE_SUFFIX_CHARS=""

# use Ctrl+left and Ctrl+right to jump a word back and forth respectively
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
bindkey '^i' expand-or-complete-prefix

# for using comments in interactive shell
setopt INTERACTIVECOMMENTS

PROMPT=$'\n%F{11}─┬─[%f %F{5}%y %f%F{white}%? %D %*%f %F{11}]%f
%F{11} ├─[%f %F{red}%m:%f %F{white}%n%f %F{8}▶%f %F{cyan}%/%f %F{11}]%f
%F{11} ╰─>%F{11}%f '


# common stuff for Linux
if [[ "$OSTYPE" == "linux-gnu"* ]]
then
    
    # syntax highlighting
    ZSH_SYNTAX_HIGH="/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    if [[ -f "$ZSH_SYNTAX_HIGH" ]]; then
        source $ZSH_SYNTAX_HIGH
    fi

    export LANG=en_IN.UTF-8

    source /etc/os-release
    MACHINE_HOSTNAME=$(cat /etc/hostname)

    if [[ "$NAME" = "Pop!_OS" && "$MACHINE_HOSTNAME" == "flameboi" ]]; then
        # The following lines were added by compinstall
        zstyle ':completion:*' completer _expand _complete _ignored
        zstyle ':completion:*' group-name ''
        zstyle :compinstall filename "$HOME/.zshrc"

        autoload -Uz compinit
        compinit
        # End of lines added by compinstall
    fi


    if [[ "$NAME" = "Fedora Linux" && "$MACHINE_HOSTNAME" == "bluefeds" ]]; then
        # use bigger fonts in tty
        case $(tty) in
            (/dev/tty[0-9]) setfont /usr/share/consolefonts/Lat2-Terminus28x14.psf.gz;;
            (/dev/pts/[0-9]) ;;
        esac

    fi


    if [[ "$NAME" = "Ubuntu" && "$MACHINE_HOSTNAME" == "sentinel" ]]; then
        # use bigger fonts in tty
        case $(tty) in
            (/dev/tty[0-9]) setfont /usr/share/consolefonts/Lat2-Terminus28x14.psf.gz;;
            (/dev/pts/[0-9]) ;;
        esac

    fi

# stuff for macOS
elif [[ "$OSTYPE" == "darwin"* ]]
then

    # syntax highlighting
    ZSH_SYNTAX_HIGH="/usr/local/opt/zsh-fast-syntax-highlighting/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
    if [[ -f "$ZSH_SYNTAX_HIGH" ]]; then
        source $ZSH_SYNTAX_HIGH
    fi
fi
