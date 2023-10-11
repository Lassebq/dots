if [ -f "$ZDOTDIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
    source "$ZDOTDIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    ZSH_HIGHLIGHT_STYLES[path]='default'
    ZSH_HIGHLIGHT_STYLES[builtin]='fg=cyan'
    ZSH_HIGHLIGHT_STYLES[command]='fg=cyan'
    ZSH_HIGHLIGHT_STYLES[function]='fg=cyan'
    ZSH_HIGHLIGHT_STYLES[alias]='fg=cyan'
    ZSH_HIGHLIGHT_STYLES[unknown-token]='default'
    ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=blue'
    ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=blue'
    ZSH_HIGHLIGHT_STYLES[assign]='fg=blue'
    ZSH_HIGHLIGHT_STYLES[redirection]='fg=blue'
    ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=green'
    ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=green'
    ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=green'
fi
