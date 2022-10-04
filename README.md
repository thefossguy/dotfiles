# README

Initial setup:
 - `git clone git@git.thefossguy.com:thefossguy/dotfiles-priv.git`
 - Uncomment the most appropriate line in `~/.config/alacritty/alacritty.yml`, under `import` (line 11)

Copy files using the following command:
```
rsync \
    --verbose --recursive --size-only --human-readable \
    --progress --stats \
    --itemize-changes --checksum \
    --exclude=".git" --exclude=".gitignore" --exclude="README.md" \
    ../dotfiles/ ~/ --dry-run
```
