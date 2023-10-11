autoload -U colors && colors

setopt promptsubst
function _prompt_simple() {
    local prompt_color
    if [[ $LAST_EXIT_CODE -ne 0 ]]; then
        prompt_color=31
    else
        prompt_color=32
    fi
    local user_color=92
    local host_color=94
    if [ -n "$TWDISPLAY" ]; then # twin seems to break with the other half of 16 color palette, fallback to first half
        user_color=32
        host_color=34
    fi
    printf "%%{\e[%dm%%}%s%%{\e[0m%%}@%%{\e[%dm%%}%s%%{\e[0m%%} %s %%{\e[%dm%%}$%%{\e[0m%%} " "$user_color" "${USER}" "$host_color" "${HOST}" "${PWD/#$HOME/~}" "$prompt_color"
}

function _prompt() {
    local LAST_EXIT_CODE=$?
    if [ "$TERM" = "linux" ]; then
        _prompt_simple
        return
    fi
    local cmd_status
    local cmd_status_bg
    if [[ $LAST_EXIT_CODE -ne 0 ]]; then
        status_color=101
        status_icon=""
    else
        status_color=102
        status_icon=""
    fi
    print -n "%{\e[${status_color}m%} %{\e[48;2;17;17;27;34m%} 󰉋 %{\e[1;38;2;187;195;223m%}${PWD/#$HOME/~}%{\e[0;38;2;17;17;27m%}%{\e[1m%}%{\e[0m%} "
}

eval "$(starship init zsh)"
PROMPT='$(_prompt)'

function set_cursor() {
    if [ "$TERM" = linux ]; then
        echo -en "\e[?2c"
    else
        echo -en "\e[0 q"
    fi
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd set_cursor
