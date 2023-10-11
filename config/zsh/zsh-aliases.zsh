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

conf() {
    case "$1" in
        hypr)
            "$EDITOR" "$XDG_CONFIG_HOME/hypr/hyprland.conf";;
        river)
            "$EDITOR" "$XDG_CONFIG_HOME/river/init";;
        hyprbinds)
            "$EDITOR" "$XDG_CONFIG_HOME/hypr/binds.conf";;
        riverbinds)
            "$EDITOR" "$XDG_CONFIG_HOME/river/binds";;
        lfrc)
            "$EDITOR" "$XDG_CONFIG_HOME/lf/lfrc";;
        lf)
            "$EDITOR" "$XDG_CONFIG_HOME/lf/previewer";;
        lfopen)
            "$EDITOR" "$XDG_CONFIG_HOME/lf/opener";;
        waybar)
            "$EDITOR" "$XDG_CONFIG_HOME/waybar/modules.jsonc";;
    esac
}

aliases() {
    "$EDITOR" "$ZDOTDIR/zsh-aliases.zsh"
}

if [ "$TERM" = alacritty ] || [ "$TERM" = foot ]; then
    alias tmux="TERM=xterm-256color tmux"
fi
if [ "$TERM" = linux ]; then
    export PAGER="bat -S -p --theme=base16 --color=always"
    alias lf="lfcd -config \"$XDG_CONFIG_HOME/lf/lfrc_tty\""
else
    alias lf="lfcd"
fi

alias killall="pkill -x"
alias icat="kitty icat"
alias imgcat="wezterm imgcat"
alias ncmp="ncmpcpp"
alias lfsu="sudo -E -H lf"
alias rmpkgs="yay -Qqd | yay -Rsu -"
alias grep="grep --color"
alias less="$PAGER"
alias dmesg="sudo -v; sudo dmesg --color=always | less"
alias la="ls -A"
alias ll="ls -alG"
alias ls="ls --color -F --quoting-style=escape"
alias mime="file -Lb --mime-type"
alias trash="gio trash"
