function set_title() {
    if [ "$TERM" != dumb ]; then
        local a="$1"
        # remove newlines
        a=${a//$'\n'/}
        print -n "\e]0;${(%)a}\a"
    fi
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec set_title
