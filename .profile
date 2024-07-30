user_default_shell="$(basename "$(getent passwd "$LOGNAME" | cut -d: -f7)")"

if [ "${user_default_shell}" = 'bash' ]; then
    source "${HOME}/.bashrc"
fi
