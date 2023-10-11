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
