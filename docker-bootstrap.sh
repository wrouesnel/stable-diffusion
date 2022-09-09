#!/bin/bash
echo "$@" 1>&2

cmd="$1"
shift

if [ -e "/root/stable-diffusion/$cmd" ]; then
    cd "/root/stable-diffusion" || exit 1
    exec "python" "/root/stable-diffusion/$cmd" "$@"
fi

if command -v "$cmd"; then
    exec "$cmd" "$@"
fi

exec bash