#!/usr/bin/env bash

stylua \
    --num-threads 1 \
    --verify \
    --call-parentheses always \
    --collapse-simple-statement always \
    --column-width 120 \
    --indent-type spaces \
    --indent-width 2 \
    --line-endings Unix \
    --quote-style ForceDouble \
    --space-after-function-names Always \
    --syntax All \
    "${HOME}/.config/nvim"
