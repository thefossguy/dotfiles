#!/usr/bin/env bash

if [[ -z "$1" ]]; then
    echo 'What is the SRC?'
    exit 1
fi

if [[ -z "$2" ]]; then
    echo 'What is the DST?'
    exit 1
fi

SRC_FILE="$1"
DST_FILE="$2"

# do a "s/ i/.i/" to preserve whitespaces when substituting it with newlines
# and then do a "s/.i/ /" to remove unnecessary characters for grep-ing
SRC_CONFIGS=($(grep -o "CONFIG_.* i\|CONFIG_.*=[m,y]" "${SRC_FILE}" | tr ' i' '.i'))
CONFIG_LIST=($(echo "${SRC_CONFIGS[@]}" | tr " " "\n"))

for OPTION in "${CONFIG_LIST[@]}"; do
    NEW_OPTION="$(echo "${OPTION}" | tr '.i' ' ' | rev | cut -c 2- | rev)"
    SRC_CONFIG="$(grep "${NEW_OPTION}" "${SRC_FILE}")"
    DST_CONFIG="$(grep "${NEW_OPTION}" "${DST_FILE}")"

    if [[ "${SRC_CONFIG}" != "${DST_CONFIG}" ]]; then
        echo '--------'
        echo -n 'SRC: ' && (grep --color=yes "${NEW_OPTION}" "${SRC_FILE}" || echo "")
        echo -n 'DST: ' && (grep --color=yes "${NEW_OPTION}" "${DST_FILE}" || echo "")
    fi
done
