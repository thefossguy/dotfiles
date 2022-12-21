# ~/.zshrc: executed by zsh(1) for non-login shells

# if not running interactively, don't do anything
case $- in
    *i*) ;;
    *) return;;
esac

HISTORY_CONF=$ZSH_CONFS_DIRECTORY/10_history
ALIASES_CONF=$ZSH_CONFS_DIRECTORY/20_aliases
SYNTAX_HIGHLIGHT_CONF=$ZSH_CONFS_DIRECTORY/90_syntax_highlight

# for using comments in interactive shell
setopt INTERACTIVECOMMENTS

# directory where most of my zsh files are stored
ZSH_CONFS_DIRECTORY="$HOME/.config/zsh_confs"

# load options related to history
[ -f $HISTORY_CONF ] && source $HISTORY_CONF

# keep the space after tab completion
ZLE_REMOVE_SUFFIX_CHARS=""

# key-bindings
if [[ -f "$HOME/.zkbd/$TERM" ]]; then
    source $HOME/.zkbd/$TERM

    [[ -n ${key[Home]} ]] && bindkey "${key[Home]}" beginning-of-line
    [[ -n ${key[End]} ]] && bindkey "${key[End]}" end-of-line
    [[ -n ${key[Delete]} ]] && bindkey "${key[Delete]}" delete-char
fi
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
bindkey '^i' expand-or-complete-prefix

# prompt
PROMPT=$'\n%F{11}─┬─[%f %F{5}%y %f%F{white}%? %D %*%f %F{11}]%f
%F{11} ├─[%f %F{red}%m:%f %F{white}%n%f %F{8}▶%f %F{cyan}%/%f %F{11}]%f
%F{11} ╰─>%F{11}%f '

# common stuff...
MACHINE_HOSTNAME=$(cat /etc/hostname)

if [[ "$MACHINE_HOSTNAME" == "flameboi" ]]; then
    # The following lines were added by compinstall
    zstyle ':completion:*' completer _alternative _approximate _arguments _complete _expand _ignored 
    zstyle ':completion:*' group-name ''
    zstyle compinstall filename "$HOME/.zshrc"

    autuload -Uz compinit
    compinit
    # End of lines added by compinstall
else if [[ "$MACHINE_HOSTNAME" == "bluefeds" || "$MACHINE_HOSTNAME" == "sentinel" ]]; then
    # use bigger fonts on the console
    case $(tty) in
        (/dev/tty[0-9]) setfont /usr/share/consolefonts/Lat2-Terminus28x14.psf.gz;;
        (/dev/pts[0-9]) ;;
    esac
fi

# source aliases
[ -f $ALIASES_CONF ] && source $ALIASES_CONF

# source zsh syntax highlighting
[ -f $SYNTAX_HIGHLIGHT_CONF ] && source $SYNTAX_HIGHLIGHT_CONF
