if getent passwd $LOGNAME | cut -d: -f7 | grep fish; then
    source $HOME/.config/fish/config.fish
elif getent passwd $LOGNAME | cut -d: -f7 | grep fish; then
    source $HOME/.bashrc
fi
