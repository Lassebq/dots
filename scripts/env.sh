#!/bin/sh

if [ "$(id -u)" = 0 ]; then
    echo "This script MUST NOT be run as root user."
    exit 1
fi

if [ -z "$XDG_CONFIG_HOME" ]; then
    XDG_CONFIG_HOME=~/.config
fi

if [ -z "$XDG_CACHE_HOME" ]; then
    XDG_CACHE_HOME=~/.cache
fi

if [ -z "$XDG_DATA_HOME" ]; then
    XDG_DATA_HOME=~/.local/share
fi

append_to_path() {
    export PATH="$1:$PATH"
}

# append directory with the script location to PATH
append_to_path "$(dirname "$(realpath "$0")")"
