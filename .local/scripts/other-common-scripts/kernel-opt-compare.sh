#!/usr/bin/env bash

if [[ -z "$1" ]]; then
    echo 'What do you want to grep for, bud?'
    exit 1
fi

if [[ -z "$2" ]]; then
    echo 'What is the SRC?'
    exit 1
fi

if [[ -z "$3" ]]; then
    echo 'What is the DST?'
    exit 1
fi

SRC_FILE="$2"
SRC_MATCHES=($(grep -o "CONFIG_.*$1.*\ i\|CONFIG_.*$1.*=[m,y]" "${SRC_FILE}" | tr " i" ".i"))

DST_FILE="$3"
DST_MATCHES=($(grep -o "CONFIG_.*$1.*\ i\|CONFIG_.*$1.*=[m,y]" "${DST_FILE}" | tr " i" ".i"))

ALL_CONFIGS=()

for OPTION in "${SRC_MATCHES[@]}" "${DST_MATCHES[@]}"; do
    NEW_OPTION=$(echo "${OPTION}" | rev | cut -c 3- | rev)
    ALL_CONFIGS+=( "${NEW_OPTION}" )
done

NEW_CONFIGS=($(echo "${ALL_CONFIGS[@]}" | tr " " "\n" | sort | uniq))

for OPTION in "${NEW_CONFIGS[@]}"; do
    echo '----'
    echo -n 'SRC: ' && (grep --color=yes "${OPTION}" "$SRC_FILE" || echo "")
    echo -n 'DST: ' && (grep --color=yes "${OPTION}" "$DST_FILE" || echo "")
done
