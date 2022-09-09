#!/bin/bash
echo "$@" 1>&2

if [ -e "/root/stable-diffusion/$1" ]; then
    exec "python3.8" "$@"
fi

exec bash