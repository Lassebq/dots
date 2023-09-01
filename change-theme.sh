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

interactive=false

themes=(themes/*)

selected_theme="$1"

i=1
if [ -z "$selected_theme" ]; then
    interactive=true
    echo "Select preferred theme:"
    for theme in "${themes[@]}"
    do
        echo "$i. $(basename "$theme")"
        i=$((i+1))
    done
    printf "Type the number of a theme in the list: "
    read -r selected_num
else
    themepath=$(realpath "themes/$selected_theme")
fi

i=1
for theme in "${themes[@]}"
do
    if [ $i = "$selected_num" ]; then
        themepath=$(realpath "$theme")
        break;
    fi
    i=$((i+1))
done

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

set_nvim_theme() {
    if pidof nvim &> /dev/null; then
        ls "$XDG_RUNTIME_DIR"/nvim.*.0 \
            | xargs -I {} nvim --server {} --remote-send "<cmd>colorscheme $1<CR>" > /dev/null
    fi
    echo "vim.cmd.colorscheme \"$1\"" > "$XDG_CONFIG_HOME/nvim/lua/theme.lua"
}

random_wallpaper() {
    find "$(realpath "$themepath/wallpaper")" -maxdepth 1 -type f | shuf -n 1
}

select_wallpaper() {
    ./rofi-wallpaper "$1"
}

if [ "$interactive" = true ]; then
    wallpaper=$(random_wallpaper)
else
    wallpaper=$(select_wallpaper "$themepath/wallpaper")
fi

if [ -z "$wallpaper" ]; then
    echo "No wallpaper provided!"
    exit 1
fi

echo "Applying theme..."

# Apply sway config changes first to not mess with wallpaper animation
mkdir -p "$XDG_CONFIG_HOME"/sway
if [ -f "$themepath/sway" ] && command -v sway &> /dev/null; then
    ln -sf "$themepath"/sway "$XDG_CONFIG_HOME"/sway/colors
    if pidof sway; then
        echo "Reloading sway config"
        sway reload &> /dev/null
    fi
fi

mkdir -p "$XDG_CONFIG_HOME"/river
if [ -f "$themepath/river" ] && command -v river &> /dev/null; then
    ln -sf "$themepath"/river "$XDG_CONFIG_HOME"/river/colors
    if pidof river; then
        echo "Reloading river config"
        "$XDG_CONFIG_HOME"/river/colors
    fi
fi

echo "Setting wallpaper: $(basename "$wallpaper")"

restart_wayland_app() {
    echo "${cmd[@]}"
    local pids="$1"
    for pid in "${pids[@]}"; do
        eval "$(cat /proc/$pid/environ | tr '\0' '\n' | grep ^WAYLAND_DISPLAY=)"
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
    gsettings set org.gnome.desktop.interface color-scheme "$COLOR_SCHEME"
    gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME"
    gsettings set org.gnome.desktop.wm.preferences theme "$GTK_THEME"
    if [ -f "$GTK2_RC_FILES" ]; then
        sed -i -E 's/(gtk-theme-name=")(.*)(")/\1'"$GTK_THEME"'\3/g' "$GTK2_RC_FILES"
    fi
    sed -i -E 's/(gtk-theme-name=)(.*)/\1'"$GTK_THEME"'/g' "$XDG_CONFIG_HOME"/gtk-3.0/settings.ini

    for vscode in "Code" "Code - OSS" "VSCodium"
    do
        if [ -f "$XDG_CONFIG_HOME/$vscode/User/settings.json" ] && conf=$(jq ".[\"workbench.colorTheme\"] = \"$VSCODE_THEME\"" "$XDG_CONFIG_HOME/Code - OSS/User/settings.json"); then
            echo "$conf" > "$XDG_CONFIG_HOME/$vscode/User/settings.json"
        fi
    done
    
    if [ "$NVIM_THEME" ]; then
        set_nvim_theme "$NVIM_THEME"
    fi
fi

# foot
if [ -f "$themepath/foot.ini" ] && command -v foot &> /dev/null; then
    mkdir -p "$XDG_CONFIG_HOME"/foot
    echo "Reloading foot"
    ln -sf "$themepath"/foot.ini "$XDG_CONFIG_HOME"/foot/theme.ini
    # There's a script in $ZDOTDIR/zsh-theme.zsh which parses current foot config and applies colors using OSC4/11
    pkill -SIGUSR1 -x -P "$(pidof foot | sed 's/ /,/g')" zsh &> /dev/null
fi

# kitty
if [ -f "$themepath/kitty.conf" ] && command -v kitty &> /dev/null; then
    mkdir -p "$XDG_CONFIG_HOME"/kitty/themes
    echo "Reloading kitty"
    ln -sf "$themepath"/kitty.conf "$XDG_CONFIG_HOME"/kitty/themes/custom.conf
    pkill -USR1 -x kitty # Reload all kitty instances
fi

# alacritty
if [ -f "$themepath/alacritty.yml" ] && command -v alacritty &> /dev/null; then
    mkdir -p "$XDG_CONFIG_HOME"/alacritty
    echo "Reloading alacritty"
    ln -sf "$themepath"/alacritty.yml "$XDG_CONFIG_HOME"/alacritty/theme.yml
fi

# wezterm
if [ -f "$themepath/wezterm.lua" ] && command -v wezterm &> /dev/null; then
    mkdir -p "$XDG_CONFIG_HOME"/wezterm
    echo "Reloading wezterm"
    ln -sf "$themepath"/wezterm.lua "$XDG_CONFIG_HOME"/wezterm/colors.lua
fi

# cava
if [ -f "$themepath/cava" ] && command -v cava &> /dev/null; then
    mkdir -p "$XDG_CONFIG_HOME"/cava
    echo "Reloading cava"
    cp -f config/cava/config "$XDG_CONFIG_HOME"/cava/config
    cat "$themepath"/cava >> "$XDG_CONFIG_HOME"/cava/config
    pkill -USR1 -x cava &> /dev/null & # Reload cava config
fi

# bottom
if command -v btm &> /dev/null; then
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
if [ -f "$themepath/waybar.css" ] && command -v waybar &> /dev/null; then
    mkdir -p "$XDG_CONFIG_HOME"/waybar
    echo "Reloading waybar"
    ln -sf "$themepath"/waybar.css "$XDG_CONFIG_HOME"/waybar/colors.css
    pkill -USR2 -x waybar &> /dev/null &
fi

# TODO read profile path from .mozilla/firefox/profiles.ini
if [ -d ~/.mozilla/firefox/lassebq/chrome ]; then
    if [[ "$wallpaper" == *.jpg || "$wallpaper" == *.jpeg ]]; then
        rm -f ~/.mozilla/firefox/lassebq/chrome/background.png
        ln -f "$wallpaper" ~/.mozilla/firefox/lassebq/chrome/background.jpg
    elif [[ "$wallpaper" == *.png ]]; then        
        rm -f ~/.mozilla/firefox/lassebq/chrome/background.jpg
        ln -f "$wallpaper" ~/.mozilla/firefox/lassebq/chrome/background.png
    fi
fi

# Reload firefox using socket connection script
if [ -f /tmp/firefox-remote.pid ]; then
    ln -sf "$themepath/firefox" /tmp/firefox-remote
    kill -SIGUSR1 "$(cat /tmp/firefox-remote.pid)"
fi

# btop
mkdir -p "$XDG_CONFIG_HOME"/btop/themes
if [ -f "$themepath/btop.theme" ]; then
    ln -sf "$themepath"/btop.theme "$XDG_CONFIG_HOME"/btop/themes/custom.theme
fi
# TODO use sed to replace color_theme in btop.conf (Maybe)

# dunst
mkdir -p "$XDG_CONFIG_HOME"/dunst
if [ -f "$themepath/dunstrc" ]; then
    ln -sf "$themepath"/dunstrc "$XDG_CONFIG_HOME"/dunst/dunstrc
    pkill -x dunst &> /dev/null &
fi

# swaync
mkdir -p "$XDG_CONFIG_HOME"/swaync
if [ -f "$themepath/swaync.css" ]; then
    ln -sf "$themepath"/swaync.css "$XDG_CONFIG_HOME"/swaync/style.css
    if pidof swaync; then
        swaync-client -rs
    fi
fi

# rofi
if [ -f "$themepath/rofi.rasi" ]; then
    mkdir -p "$XDG_CONFIG_HOME"/rofi
    ln -sf "$themepath"/rofi.rasi "$XDG_CONFIG_HOME"/rofi/colors.rasi
fi

# bat
if command -v bat &> /dev/null; then
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

