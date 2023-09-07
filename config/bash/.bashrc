source ~/.config/zsh/zsh-aliases.zsh

stty werase ^H

#trap TRAPUSR1 USR1

#TRAPUSR1() {
#}

eval "$(dircolors ~/.config/lf/colors)"
eval "$(starship init bash)"
