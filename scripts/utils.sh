#!/bin/sh

is_running() {
    pidof "$1" > /dev/null 2> /dev/null
}

is_running_pid() {
    ps "$1" > /dev/null 2> /dev/null
}

warning() {
    if [ -n "$1" ]; then
        echo -e "${light_yellow}Warning: $1${default}"
    else
        echo -e "${light_yellow}Something went wrong!${default}"
    fi
}

fatal() {
    if [ -n "$1" ]; then
        echo -e "${light_red}Error: $1${default}"
    else
        echo -e "${light_red}Something went wrong!${default}"
    fi
    exit 1
}

y_or_n() {
    echo -n " [y/n]:"
    read -r yn
    case $yn in
        [Yy]* ) return 0;;
        * ) return 1;;
    esac
}

has_command() {
    command -v "$1" &> /dev/null
}
