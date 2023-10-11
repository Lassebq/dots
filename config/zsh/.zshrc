eval "$(dircolors ~/.config/lf/colors)"
autoload -Uz compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
zstyle ':completion:*' menu select cache-path "$XDG_CACHE_HOME/zsh/zcompcache"
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

setopt dotglob
# ZSH autosuggestions adds a lot of time to precmd hook, never rebind it
ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# Source plugins
for plugin in "$ZDOTDIR/"*.zsh
do
    if [ -f "$plugin" ]; then 
        source "$plugin"
    fi
done

setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_BEEP

stty werase ^H
bindkey ^H backward-kill-word

TRAPUSR1() {
    apply_theme
}

# Reload colors in linux console
if [ "$TERM" = linux ]; then
    apply_theme
fi
