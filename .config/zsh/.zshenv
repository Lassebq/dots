# Append ~/.local/bin/ to PATH
typeset -U path PATH
path=(~/.local/bin $path)
export PATH

export TERMINAL=kitty
export EDITOR=nvim
export PAGER=bat
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export GPG_TTY=$(tty)

# XDG Base directories
export XDG_CONFIG_HOME="$HOME"/.config
export XDG_CACHE_HOME="$HOME"/.cache
export XDG_DATA_HOME="$HOME"/.local/share
export XDG_STATE_HOME="$HOME"/.local/state

export HISTSIZE=100
export SAVEHIST=100

export MPD_HOST=/var/run/mpd/socket

export QT_QPA_PLATFORMTHEME=gtk2
export WINEPREFIX="$XDG_DATA_HOME"/wineprefixes/default
export WINEARCH=win64
export LESSHISTFILE=-
export HISTFILE="$XDG_DATA_HOME"/zsh/history
export ZDOTDIR="$XDG_CONFIG_HOME"/zsh
export STARSHIP_CONFIG="$XDG_CONFIG_HOME"/starship.toml
export STARSHIP_CACHE="$XDG_CACHE_HOME"/starship
export _JAVA_OPTIONS="-Dawt.useSystemAAFontSettings=on -Djava.util.prefs.userRoot=$XDG_CONFIG_HOME/java -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel"
export JAVA_FONTS=/usr/share/fonts/TTF
export JAVA_HOME=/usr/lib/jvm/default
export CARGO_HOME="$XDG_DATA_HOME"/cargo
export FFMPEG_DATADIR="$XDG_CONFIG_HOME"/ffmpeg
export GTK_RC_FILES="$XDG_CONFIG_HOME"/gtk-1.0/gtkrc
export GTK2_RC_FILES="$XDG_CONFIG_HOME"/gtk-2.0/gtkrc
export NPM_CONFIG_USERCONFIG=$XDG_CONFIG_HOME/npm/npmrc
export WGETRC="$XDG_CONFIG_HOME/wgetrc"
export CUDA_CACHE_PATH="$XDG_CACHE_HOME"/nv
export GOPATH=$XDG_DATA_HOME/go
