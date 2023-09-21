if command -v fish > /dev/null; then
    source $HOME/.config/fish/config.fish
elif command -v bash > /dev/null; then
    source $HOME/.bashrc
fi
