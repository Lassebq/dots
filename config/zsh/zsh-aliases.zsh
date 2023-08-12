lfcd () {
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

alias icat="kitty icat"
alias fetch="nitch"
alias ncmp="ncmpcpp"
alias lfsu="sudo -E -H lf"
alias pacman="yay"
alias rmpkg="pacman -Qqd | pacman -Rsu -"
alias lf="lfcd"
alias ls="exa"
alias file="file -Lb --mime-type"
alias aliases="$EDITOR "'"'"$ZDOTDIR/zsh-aliases.zsh"'"'""
