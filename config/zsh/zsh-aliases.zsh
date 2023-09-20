lfcd() {
    tmp="$(mktemp)"
    # `command` is needed in case `lfcd` is aliased to `lf`
    command lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        rm -f "$tmp"
        if [ -d "$dir" ]; then
            if [ "$dir" != "$(pwd)" ]; then
                cd "$dir"
            fi
        fi
    fi
}

alias killall="pkill -x"
alias icat="kitty icat"
alias imgcat="wezterm imgcat"
alias ncmp="ncmpcpp"
alias lfsu="sudo -E -H lf"
alias rmpkg="yay -Qqd | yay -Rsu -; sudo rm -rf /var/cache/pacman/pkg/"
alias lf="lfcd"
alias grep="grep --color"
alias less="$PAGER"
alias dmesg="sudo -v; sudo dmesg --color=always | less"
alias la="ls -A"
alias ll="ls -alG"
alias ls="ls --color -F"
alias file="file -Lb --mime-type"
alias trash="gio trash"
alias aliases="$EDITOR "'"'"$ZDOTDIR/zsh-aliases.zsh"'"'""
if [ "$TERM" = linux ]; then
    alias lf="lfcd -config $HOME/.config/lf/lfrc_tty"
fi
