typeset -U path PATH
path=(~/.local/bin $path)
export PATH

autoload -Uz promptinit
promptinit

autoload -Uz compinit -d $XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION
compinit -d $XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION
zstyle ':completion:*' menu select cache-path $XDG_CACHE_HOME/zsh/zcompcache

source $ZDOTDIR/zsh-shift-select.zsh
source $ZDOTDIR/zsh-autosuggestions.zsh
source $ZDOTDIR/zsh-aliases.zsh
source $ZDOTDIR/zsh-key-bindings.zsh

stty werase ^H
bindkey ^H backward-kill-word

eval "$(starship init zsh)"
