#!/usr/bin/env bash

rsync \
    --verbose --recursive --size-only --human-readable \
    --progress --stats \
    --itemize-changes --checksum \
    --exclude=".git" --exclude=".gitignore" --exclude="README.md" \
    --exclude="run_me.sh" --exclude="_OTHER" \
    ../dotfiles/ ~/ --dry-run
