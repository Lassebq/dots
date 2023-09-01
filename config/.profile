# Append ~/.local/bin/ to PATH
export PATH="$HOME/.local/bin:$PATH"

if lspci | grep -E "(VGA|3D).*NVIDIA" > /dev/null; then
    export LIBVA_DRIVER_NAME=nvidia
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export WLR_NO_HARDWARE_CURSORS=1
fi

export MOZ_ENABLE_WAYLAND=1

export TERMINAL=foot
export EDITOR=nvim
export PAGER="bat -S -p --color=always"
export MANPAGER="less --use-color"
export GPG_TTY=$(tty)

# XDG Base directories
export XDG_CONFIG_HOME="$HOME"/.config
export XDG_CACHE_HOME="$HOME"/.cache
export XDG_DATA_HOME="$HOME"/.local/share
export XDG_STATE_HOME="$HOME"/.local/state

export HISTSIZE=100
export SAVEHIST=100

export MPD_HOST=/var/run/mpd/socket
export QT_QPA_PLATFORMTHEME=qt6ct
export WINEARCH=win64
export LESSHISTFILE=-
export JAVA_FONTS=/usr/share/fonts/TTF
export JAVA_HOME=/usr/lib/jvm/default

# Override paths with XDG Base Directories for apps which partially support it
#export VSCODE_PORTABLE="$XDG_DATA_HOME"/vscode
#export DOTNET_CLI_HOME="XDG_CACHE_HOME"/dotnet
export NUGET_PACKAGES="$XDG_CACHE_HOME"/NuGetPackages
export XINITRC="$XDG_CONFIG_HOME"/X11/xinitrc
export XSERVERRC="$XDG_CONFIG_HOME"/X11/xserverrc
export PASSWORD_STORE_DIR="$XDG_DATA_HOME"/pass
export WINEPREFIX="$XDG_DATA_HOME"/wineprefixes/default
export ZDOTDIR="$XDG_CONFIG_HOME"/zsh
export HISTFILE="$ZDOTDIR"/.zsh_history
export STARSHIP_CONFIG="$XDG_CONFIG_HOME"/starship.toml
export STARSHIP_CACHE="$XDG_CACHE_HOME"/starship
export _JAVA_OPTIONS="-Dawt.useSystemAAFontSettings=on -Djava.util.prefs.userRoot=$XDG_CONFIG_HOME/java -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel"
export RUSTUP_HOME="$XDG_DATA_HOME"/rustup
export CARGO_HOME="$XDG_DATA_HOME"/cargo
export GRADLE_USER_HOME="$XDG_DATA_HOME"/gradle
export GNUPGHOME="$XDG_DATA_HOME"/gnupg
export FFMPEG_DATADIR="$XDG_CONFIG_HOME"/ffmpeg
export GTK_RC_FILES="$XDG_CONFIG_HOME"/gtk-1.0/gtkrc
export GTK2_RC_FILES="$XDG_CONFIG_HOME"/gtk-2.0/gtkrc
export NPM_CONFIG_USERCONFIG=$XDG_CONFIG_HOME/npm/npmrc
export WGETRC="$XDG_CONFIG_HOME/wgetrc"
export CUDA_CACHE_PATH="$XDG_CACHE_HOME"/nv
export GOPATH=$XDG_DATA_HOME/go
export GOMODCACHE="$XDG_CACHE_HOME"/go/mod
export TERMINFO="$XDG_DATA_HOME"/terminfo
export TERMINFO_DIRS="$XDG_DATA_HOME"/terminfo:/usr/share/terminfo
export INPUTRC="$XDG_CONFIG_HOME"/readline/inputrc

