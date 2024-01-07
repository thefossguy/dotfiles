#!/usr/bin/env bash

set -eu

if [[ ! -f "${HOME}/.config/alacritty/platform.yml" ]]; then
    if [[ "$(uname -s)" == 'Linux' ]]; then
        ln -s "${HOME}/.config/alacritty/"{linux,platform}.yml
    elif [[ "$(uname -s)" == 'Darwin' ]]; then
        ln -s "${HOME}/.config/alacritty/"{darwin,platform}.yml
    fi
fi

if [[ ! -f "${HOME}/.local/scripts/other-common-scripts/git-prompt.sh" ]]; then
    pushd "${HOME}/.local/scripts/other-common-scripts"
    wget 'https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh'
    popd
fi
