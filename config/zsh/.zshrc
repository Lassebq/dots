setopt promptsubst
function _prompt() {
    local LAST_EXIT_CODE=$?
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

function zle-clipboard-cut {
  if ((REGION_ACTIVE)); then
    zle copy-region-as-kill
    print -rn -- $CUTBUFFER | wl-copy
    zle kill-region
  fi
}
zle -N zle-clipboard-cut

function zle-clipboard-copy {
  if ((REGION_ACTIVE)); then
    zle copy-region-as-kill
    print -rn -- $CUTBUFFER | wl-copy
  else
    # Nothing is selected, so default to the interrupt command
    zle send-break
  fi
}
zle -N zle-clipboard-copy

function zle-clipboard-paste {
  if ((REGION_ACTIVE)); then
    zle kill-region
  fi
  LBUFFER+="$(wl-paste 2> /dev/null)"
}
zle -N zle-clipboard-paste

function zle-pre-cmd {
  # We are now in buffer editing mode. Clear the interrupt combo `Ctrl + C` by setting it to the null character, so it
  # can be used as the copy-to-clipboard key instead
  stty intr "^@"
}
precmd_functions=("zle-pre-cmd" ${precmd_functions[@]})

function zle-pre-exec {
  # We are now out of buffer editing mode. Restore the interrupt combo `Ctrl + C`.
  stty intr "^C"
}
preexec_functions=("zle-pre-exec" ${preexec_functions[@]})

# The `key` column is only used to build a named reference for `zle`
for kcap    seq           widget (
    x       '^X'         zle-clipboard-cut   # `Ctrl + X`
    x       '^C'         zle-clipboard-copy  # `Ctrl + C`
); do
  bindkey -M shift-select ${terminfo[$kcap]-$seq} $widget
done

bindkey ${terminfo[x]-'^V'} zle-clipboard-paste
bindkey ${terminfo[x]-'^C'} send-break

TRAPUSR1() {
    apply_theme
}

# Reload colors in linux console
if [ "$TERM" = linux ]; then
    apply_theme
fi
