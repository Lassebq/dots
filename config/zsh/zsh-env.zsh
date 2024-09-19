export EDITOR=nvim
export PAGER="bat -S -p --color=always --paging=always --decorations=never"
if [ "$TERM" = linux ]; then
    export PAGER="$PAGER --theme=base16"
fi
export MANPAGER="less"
export GPG_TTY=$(tty)
export GCC_COLORS='error=01;31:warning=01;33:note=01;36:caret=01;32:locus=01:quote=01'

export LESS_TERMCAP_mb=$'\e[1;35m'
export LESS_TERMCAP_md=$'\e[36m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[7;1;32m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;34m'
export GROFF_NO_SGR=1

export USE_COLORS=1

export HISTSIZE=100
export SAVEHIST=100

export LESSHISTFILE=-
export HISTFILE="$XDG_DATA_HOME"/.history

export WORDCHARS='*?_.[]~=&;!#$%^'
