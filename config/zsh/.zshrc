setopt promptsubst
function _prompt() {
    printf "%%{\e[92m%%}%s%%{\e[0m%%}@%%{\e[94m%%}%s%%{\e[0m%%} %s $ " "${USER}" "${HOST}" "${PWD/#$HOME/~}"
}

eval "$(dircolors ~/.config/lf/colors)"
if [ "$TERM" = "linux" ]; then
    export PAGER="bat -S -p --theme=base16 --color=always"
    PROMPT='$(_prompt)'
else
    eval "$(starship init zsh)"
fi

autoload -Uz promptinit
promptinit

autoload -Uz compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
zstyle ':completion:*' menu select cache-path "$XDG_CACHE_HOME/zsh/zcompcache"
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

setopt dotglob

# Source plugins
for plugin in "$ZDOTDIR/"*.zsh
do
    source "$plugin"
done

setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_BEEP

set_title() {
    if [ "$TERM" != dumb ]; then
        local a
        # escape '%' in $1, make nonprintables visible
        a=${(V)1//\%/\%\%}
        # remove newlines
        a=${a//$'\n'/}
        print -n "\e]0;${(%)a}\a"
    fi
}

set_cursor() {
    if [ "$TERM" = linux ]; then
        echo -en "\e[?2c"
    else
        echo -en "\e[0 q"
    fi
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd set_cursor
add-zsh-hook preexec set_title

stty werase ^H
bindkey ^H backward-kill-word

# Reload colors in linux console
if [ "$TERM" = linux ]; then
    kill -SIGUSR1 $$
fi
