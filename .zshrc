# ~/.zshrc: executed by zsh(1) for non-login shells

# if not running interactively, don't do anything
case $- in
    *i*) ;;
    *) return;;
esac

# directory where most of my zsh files are stored
ZSH_CONFS_DIRECTORY=$HOME/.config/zsh_confs
HISTORY_CONF=$ZSH_CONFS_DIRECTORY/10_history
ALIASES_CONF=$ZSH_CONFS_DIRECTORY/20_aliases
SYNTAX_HIGHLIGHT_CONF=$ZSH_CONFS_DIRECTORY/90_syntax_highlight

# for using comments in interactive shell
setopt INTERACTIVECOMMENTS

# load options related to history
[ -f $HISTORY_CONF ] && source $HISTORY_CONF

# keep the space after tab completion
ZLE_REMOVE_SUFFIX_CHARS=""

# key-bindings
if [[ -f "$HOME/.zkbd/xterm-256color" ]]; then
    source $HOME/.zkbd/xterm-256color

    [[ -n ${key[Home]} ]] && bindkey "${key[Home]}" beginning-of-line
    [[ -n ${key[End]} ]] && bindkey "${key[End]}" end-of-line
    [[ -n ${key[Delete]} ]] && bindkey "${key[Delete]}" delete-char
    [[ -n ${key[PageUp]} ]] && bindkey "${key[PageUp]}" backward-word
    [[ -n ${key[PageDown]} ]] && bindkey "${key[PageDown]}" forward-word
    [[ -n ${key[Insert]} ]] && bindkey "${key[Insert]}" vi-replace

    # disable all fn keys
    # re-enable them when needed
    [[ -n ${key[F1]} ]] && bindkey "${key[F1]}" ""
    [[ -n ${key[F2]} ]] && bindkey "${key[F2]}" ""
    [[ -n ${key[F3]} ]] && bindkey "${key[F3]}" ""
    [[ -n ${key[F4]} ]] && bindkey "${key[F4]}" ""
    [[ -n ${key[F5]} ]] && bindkey "${key[F5]}" ""
    [[ -n ${key[F6]} ]] && bindkey "${key[F6]}" ""
    [[ -n ${key[F7]} ]] && bindkey "${key[F7]}" ""
    [[ -n ${key[F8]} ]] && bindkey "${key[F8]}" ""
    [[ -n ${key[F9]} ]] && bindkey "${key[F9]}" ""
    [[ -n ${key[F10]} ]] && bindkey "${key[F10]}" ""
    [[ -n ${key[F11]} ]] && bindkey "${key[F11]}" ""
    [[ -n ${key[F12]} ]] && bindkey "${key[F12]}" ""
fi
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
bindkey "^i" expand-or-complete-prefix

# prompt
PROMPT=$'\n%F{11}─┬─[%f %F{5}%y %f%F{white}%? %D %*%f %F{11}]%f
%F{11} ├─[%f %F{red}%m:%f %F{white}%n%f %F{8}▶%f %F{cyan}%/%f %F{11}]%f
%F{11} ╰─>%F{11}%f '

# common stuff...
MACHINE_HOSTNAME=$(cat /etc/hostname)

if [[ "$MACHINE_HOSTNAME" == "flameboi" ]]; then
    # The following lines were added by compinstall
    zstyle ':completion:*' completer _arguments _complete _expand _ignored
    zstyle ':completion:*' group-name ''
    zstyle compinstall filename "$HOME/.zshrc"

    autoload -Uz compinit
    compinit
    # End of lines added by compinstall
elif [[ "$MACHINE_HOSTNAME" == "bluefeds" || "$MACHINE_HOSTNAME" == "sentinel" ]]; then
    # use bigger fonts on the console
    case $(tty) in
        (/dev/tty[0-9]) setfont /usr/share/consolefonts/Lat2-Terminus28x14.psf.gz;;
    esac
fi

# source aliases
[ -f $ALIASES_CONF ] && source $ALIASES_CONF

# source zsh syntax highlighting
[ -f $SYNTAX_HIGHLIGHT_CONF ] && source $SYNTAX_HIGHLIGHT_CONF
