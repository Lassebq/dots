#!/bin/bash

if [ "$(id -u)" = 0 ]; then
    echo "This script MUST NOT be run as root user."
    exit 1
fi

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path" || exit

if [ ! -d themes ]; then
    echo "Could not find themes folder."
    exit 1
fi

themes=(themes/*)

selected_theme="$1"

interactive=false
if [[ "$-" = *i* ]]; then
    interactive=true
fi

if [ -z "$selected_theme" ] && [ "$interactive" = true ]; then
    i=1
    echo "Select preferred theme:"
    for theme in "${themes[@]}"
    do
        echo "$i. $(basename "$theme")"
        i=$((i+1))
    done
    printf "Type the number of a theme in the list: "
    read -r selected_num
    n=1
    for theme in "${themes[@]}"
    do
        if [ $n = "$selected_num" ]; then
            themepath=$(realpath "$theme")
            break;
        fi
        n=$((n+1))
    done
else
    themepath=$(realpath "themes/$selected_theme")
fi

if [ ! -d "$themepath" ]; then
    echo "Theme doesn't exist."
    exit 1
fi

if [ -z "$XDG_CONFIG_HOME" ]; then
    XDG_CONFIG_HOME=~/.config
fi

if [ -z "$XDG_CACHE_HOME" ]; then
    XDG_CACHE_HOME=~/.cache
fi

if [ -z "$XDG_DATA_HOME" ]; then
    XDG_DATA_HOME=~/.local/share
fi

check_command() {
    command -v "$1" &> /dev/null
}

set_nvim_theme() {
    if pidof nvim &> /dev/null; then
        ls "$XDG_RUNTIME_DIR"/nvim.*.0 \
            | xargs -I {} nvim --server {} --remote-send "<cmd>colorscheme $1<CR>" > /dev/null
    fi
    echo "vim.cmd.colorscheme \"$1\"" > "$XDG_CONFIG_HOME/nvim/lua/theme.lua"
}

set_gtk_theme() {
    gsettings set org.gnome.desktop.interface gtk-theme "$1"
    gsettings set org.gnome.desktop.wm.preferences theme "$1"
    if [ -f "$GTK2_RC_FILES" ]; then
        sed -i -E 's/(gtk-theme-name=")(.*)(")/\1'"$1"'\3/g' "$GTK2_RC_FILES"
    elif [ -f "$HOME/.gtkrc-2.0" ]; then
        sed -i -E 's/(gtk-theme-name=")(.*)(")/\1'"$1"'\3/g' "$HOME/.gtkrc-2.0"
    fi
    if [ -f "$XDG_CONFIG_HOME"/gtk-3.0/settings.ini ]; then
        sed -i -E 's/(gtk-theme-name=)(.*)/\1'"$1"'/g' "$XDG_CONFIG_HOME"/gtk-3.0/settings.ini
    fi
}

random_wallpaper() {
    find "$(realpath "$themepath/wallpaper")" -maxdepth 1 -type f | shuf -n 1
}

select_wallpaper() {
    ./rofi-wallpaper "$1"
}

if [ "$interactive" = false ]; then
    # DISPLAY is set in arch-chroot? Messes up install script
    if [ -n "$WAYLAND_DISPLAY" ]; then
        wallpaper="$(select_wallpaper "$themepath/wallpaper")"
    else
        wallpaper="$(random_wallpaper)"
    fi
else
    wallpaper="$(random_wallpaper)"
fi

if [ -z "$wallpaper" ]; then
    echo "No wallpaper provided!"
    exit 1
fi

echo "Applying theme..."

# Apply sway config changes first to not mess with wallpaper animation
mkdir -p "$XDG_CONFIG_HOME"/sway
if [ -f "$themepath/sway" ] && check_command sway; then
    ln -sf "$themepath"/sway "$XDG_CONFIG_HOME"/sway/colors
    if pidof sway > /dev/null; then
        echo "Reloading sway config"
        sway reload &> /dev/null
    fi
fi

mkdir -p "$XDG_CONFIG_HOME"/river
if [ -f "$themepath/river" ] && check_command river; then
    ln -sf "$themepath"/river "$XDG_CONFIG_HOME"/river/colors
    if pidof river > /dev/null && [ -n "$WAYLAND_DISPLAY" ]; then
        echo "Reloading river config"
        "$XDG_CONFIG_HOME"/river/colors
    fi
fi

echo "Setting wallpaper: $(basename "$wallpaper")"

restart_wayland_app() {
    local pids="$1"
    for pid in "${pids[@]}"; do
        eval "export $(cat /proc/$pid/environ | tr '\0' '\n' | grep ^WAYLAND_DISPLAY=)"
        "${cmd[@]}" &> /dev/null &
        kill "$pid"
    done
}

if [ -f "$wallpaper" ]; then
    mkdir -p "$XDG_CACHE_HOME"/swaybg
    ln -sf "$wallpaper" "$XDG_CACHE_HOME"/swaybg/img
    wbg_pids=($(pidof wbg))
    if [ -n "${wbg_pids[*]}" ]; then
        echo "Restarting wbg"
        cmd=(wbg "$wallpaper")
        restart_wayland_app "$wbg_pids"
    fi
    swaybg_pids=($(pidof swaybg))
    if [ -n "${swaybg_pids[*]}" ]; then
        echo "Restarting swaybg"
        cmd=(swaybg -m fill -o "*" -i "$wallpaper")
        restart_wayland_app "$swaybg_pids"
    fi
    if pidof hyprpaper > /dev/null; then
        echo "Reloading hyprpaper"
        if pidof Hyprland > /dev/null; then
            hyprctl hyprpaper unload ~/.cache/swaybg/img
            hyprctl hyprpaper preload ~/.cache/swaybg/img
            hyprctl hyprpaper wallpaper ,~/.cache/swaybg/img
        elif kill "$(cat /run/user/1000/hyprpaper.lock)"; then
            hyprpaper &
        fi
    fi
    if pidof swww-daemon > /dev/null; then
        swww img --transition-fps=60 --transition-type=wipe "$wallpaper"    
    fi
fi

if [ -f "$themepath/theme" ]; then
    echo "Applying GTK theme"
    source "$themepath/theme"
    # Detect chroot and use `dbus-launch --exit-with-session` there
    gsettings set org.gnome.desktop.interface color-scheme "$COLOR_SCHEME"
    set_gtk_theme "$GTK_THEME"

    if [ -n "$VSCODE_PORTABLE" ]; then        
        if [ -f "$VSCODE_PORTABLE/user-data/User/settings.json" ] && conf=$(jq ".[\"workbench.colorTheme\"] = \"$VSCODE_THEME\"" "$VSCODE_PORTABLE/user-data/User/settings.json"); then
            echo "$conf" > "$VSCODE_PORTABLE/user-data/User/settings.json"
        fi
    else
        for vscode in "Code" "Code - OSS" "VSCodium"
        do
            if [ -f "$XDG_CONFIG_HOME/$vscode/User/settings.json" ] && conf=$(jq ".[\"workbench.colorTheme\"] = \"$VSCODE_THEME\"" "$XDG_CONFIG_HOME/$vscode/User/settings.json"); then
                echo "$conf" > "$XDG_CONFIG_HOME/$vscode/User/settings.json"
            fi
        done
    fi
    
    if [ "$NVIM_THEME" ]; then
        set_nvim_theme "$NVIM_THEME"
    fi
fi

# foot
if [ -f "$themepath/foot.ini" ] && check_command foot; then
    mkdir -p "$XDG_CONFIG_HOME"/foot
    echo "Reloading foot"
    ln -sf "$themepath"/foot.ini "$XDG_CONFIG_HOME"/foot/theme.ini
    zsh_pids=($(pgrep -x -P "$(pidof foot | tr ' ' ',')" zsh))
    kill -SIGUSR1 "${zsh_pids[*]}"
    apply_theme="$(zsh -c 'TERM=foot; source $ZDOTDIR/zsh-theme.zsh; apply_theme')"
    for zsh_pid in "${zsh_pids[@]}"
    do
        echo -n "$apply_theme" >> /proc/$zsh_pid/fd/0
    done
fi

# kitty
if [ -f "$themepath/kitty.conf" ] && check_command kitty; then
    mkdir -p "$XDG_CONFIG_HOME"/kitty/themes
    echo "Reloading kitty"
    ln -sf "$themepath"/kitty.conf "$XDG_CONFIG_HOME"/kitty/themes/custom.conf
    pkill -USR1 -x kitty # Reload all kitty instances
fi

# alacritty
if [ -f "$themepath/alacritty.yml" ] && check_command alacritty; then
    mkdir -p "$XDG_CONFIG_HOME"/alacritty
    echo "Reloading alacritty"
    ln -sf "$themepath"/alacritty.yml "$XDG_CONFIG_HOME"/alacritty/theme.yml
fi

# wezterm
if [ -f "$themepath/wezterm.lua" ] && check_command wezterm; then
    mkdir -p "$XDG_CONFIG_HOME"/wezterm
    echo "Reloading wezterm"
    ln -sf "$themepath"/wezterm.lua "$XDG_CONFIG_HOME"/wezterm/colors.lua
fi

# cava
if [ -f "$themepath/cava" ] && check_command cava; then
    mkdir -p "$XDG_CONFIG_HOME"/cava
    echo "Reloading cava"
    cp -f config/cava/config "$XDG_CONFIG_HOME"/cava/config
    cat "$themepath"/cava >> "$XDG_CONFIG_HOME"/cava/config
    pkill -USR1 -x cava &> /dev/null & # Reload cava config
fi

# bottom
if check_command btm; then
    mkdir -p "$XDG_CONFIG_HOME"/bottom
    cp -f config/bottom/bottom.toml "$XDG_CONFIG_HOME"/bottom/bottom.toml
    if [ -f "$themepath/bottom.toml" ]; then
        cat "$themepath"/bottom.toml >> "$XDG_CONFIG_HOME"/bottom/bottom.toml
    fi
fi

# Hyprland
if [ -f "$themepath/hyprland.conf" ]; then
    mkdir -p "$XDG_CONFIG_HOME"/hypr
    ln -sf "$themepath"/hyprland.conf "$XDG_CONFIG_HOME"/hypr/colors.conf
    if pidof Hyprland &> /dev/null; then
        echo "Reloading Hyprland"
        hyprctl reload &> /dev/null &
    fi
fi

# Waybar
if [ -f "$themepath/waybar.css" ] && check_command waybar; then
    mkdir -p "$XDG_CONFIG_HOME"/waybar
    echo "Reloading waybar"
    ln -sf "$themepath"/waybar.css "$XDG_CONFIG_HOME"/waybar/colors.css
    pkill -USR2 -x waybar &> /dev/null &
fi

if [ -d ~/.mozilla/firefox/"$USER"/chrome ]; then
    if [[ "$wallpaper" == *.jpg || "$wallpaper" == *.jpeg ]]; then
        rm -f ~/.mozilla/firefox/"$USER"/chrome/background.png
        ln -f "$wallpaper" ~/.mozilla/firefox/"$USER"/chrome/background.jpg
    elif [[ "$wallpaper" == *.png ]]; then        
        rm -f ~/.mozilla/firefox/"$USER"/chrome/background.jpg
        ln -f "$wallpaper" ~/.mozilla/firefox/"$USER"/chrome/background.png
    fi
fi

# Reload firefox using socket connection script
if [ -f /tmp/firefox-remote.pid ]; then
    ln -sf "$themepath/firefox" /tmp/firefox-remote
    kill -SIGUSR1 "$(cat /tmp/firefox-remote.pid)"
fi

# btop
if [ -f "$themepath/btop.theme" ] && check_command btop; then
    mkdir -p "$XDG_CONFIG_HOME"/btop/themes
    ln -sf "$themepath"/btop.theme "$XDG_CONFIG_HOME"/btop/themes/custom.theme
fi
# TODO use sed to replace color_theme in btop.conf (Maybe)

# dunst
if [ -f "$themepath/dunstrc" ] && check_command dunst; then
    mkdir -p "$XDG_CONFIG_HOME"/dunst
    ln -sf "$themepath"/dunstrc "$XDG_CONFIG_HOME"/dunst/dunstrc
    #pkill -x dunst &> /dev/null &
fi

# swaync
if [ -f "$themepath/swaync.css" ] && check_command swaync; then
    mkdir -p "$XDG_CONFIG_HOME"/swaync
    ln -sf "$themepath"/swaync.css "$XDG_CONFIG_HOME"/swaync/style.css
    if pidof swaync; then
        swaync-client -rs
    fi
fi

# rofi
if [ -f "$themepath/rofi.rasi" ] && check_command rofi; then
    mkdir -p "$XDG_CONFIG_HOME"/rofi
    ln -sf "$themepath"/rofi.rasi "$XDG_CONFIG_HOME"/rofi/colors.rasi
fi

# bat
if check_command bat; then
    if [ -f "$themepath/bat.tmTheme" ]; then
        mkdir -p "$XDG_CONFIG_HOME"/bat/themes
        ln -sf "$themepath"/bat.tmTheme "$XDG_CONFIG_HOME"/bat/themes/custom.tmTheme
        echo '--theme="custom"' > "$XDG_CONFIG_HOME"/bat/config
    else
        echo '--theme="base16"' > "$XDG_CONFIG_HOME"/bat/config
    fi
    echo "Building bat cache"
    bat cache --build &> /dev/null
fi

# Also reload lf to update preview with new colors
if pidof lf &> /dev/null; then
    lf -remote "send :reload"
fi

echo "Theme applied."
exit 0

