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

i=1
if [ -z "$selected_theme" ]; then
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
    if pidof nvim; then
        ls $XDG_RUNTIME_DIR/nvim.*.0 \
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
wallpaper=$(select_wallpaper "$themepath/wallpaper")

if [ -z "$wallpaper" ]; then
    echo "No wallpaper provided!"
    exit 1
fi

echo "Applying theme..."

# Apply sway config changes first to not mess with wallpaper animation
mkdir -p "$XDG_CONFIG_HOME"/sway
if [ -f "$themepath/sway" ] && sway -v > /dev/null 2>&1; then
    ln -sf "$themepath"/sway "$XDG_CONFIG_HOME"/sway/colors
    if pidof sway; then
        echo "Reloading sway config"
        sway reload > /dev/null 2>&1
    fi
fi

mkdir -p "$XDG_CONFIG_HOME"/river
if [ -f "$themepath/river" ]; then
    ln -sf "$themepath"/river "$XDG_CONFIG_HOME"/river/colors
    if pidof river; then
        echo "Reloading river config"
        "$XDG_CONFIG_HOME"/river/colors
    fi
fi

echo "Setting wallpaper: $(basename "$wallpaper")"

if [ -f "$wallpaper" ]; then
    mkdir -p "$XDG_CACHE_HOME"/swaybg
    ln -sf "$wallpaper" "$XDG_CACHE_HOME"/swaybg/img
    if pidof swaybg; then
        echo "Restarting swaybg"
        killall swaybg
        swaybg -m fill -o "*" -i "$wallpaper" >/dev/null 2>&1 &
    elif swww -V > /dev/null 2>&1; then
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

    if [ -f "$XDG_CONFIG_HOME/Code - OSS/User/settings.json" ] && conf=$(jq ".[\"workbench.colorTheme\"] = \"$VSCODE_THEME\"" "$XDG_CONFIG_HOME/Code - OSS/User/settings.json"); then
        echo "$conf" > "$XDG_CONFIG_HOME/Code - OSS/User/settings.json"
    fi
    
    if [ -f "$XDG_CONFIG_HOME/Code/User/settings.json" ] && conf=$(jq ".[\"workbench.colorTheme\"] = \"$VSCODE_THEME\"" "$XDG_CONFIG_HOME/Code/User/settings.json"); then
        echo "$conf" > "$XDG_CONFIG_HOME/Code/User/settings.json"
    fi
    
    if [ "$NVIM_THEME" ]; then
        set_nvim_theme "$NVIM_THEME"
    fi
fi

# kitty
mkdir -p "$XDG_CONFIG_HOME"/kitty/themes
if [ -f "$themepath/kitty.conf" ]; then
    echo "Reloading kitty"
    ln -sf "$themepath"/kitty.conf "$XDG_CONFIG_HOME"/kitty/themes/custom.conf
    pkill -USR1 kitty # Reload all kitty instances
fi

# alacritty
mkdir -p "$XDG_CONFIG_HOME"/alacritty
if [ -f "$themepath/alacritty.yml" ]; then
    echo "Reloading alacritty"
    ln -sf "$themepath"/alacritty.yml "$XDG_CONFIG_HOME"/alacritty/theme.yml
fi

# cava
mkdir -p "$XDG_CONFIG_HOME"/cava
if [ -f "$themepath/cava" ]; then
    echo "Reloading cava"
    cp -f config/cava/config "$XDG_CONFIG_HOME"/cava/config
    cat "$themepath"/cava >> "$XDG_CONFIG_HOME"/cava/config
    pkill -USR1 cava > /dev/null 2>&1 & # Reload cava config
fi

# bottom
mkdir -p "$XDG_CONFIG_HOME"/bottom
if [ -f "$themepath/bottom.toml" ]; then
    cp -f config/bottom/bottom.toml "$XDG_CONFIG_HOME"/bottom/bottom.toml
    cat "$themepath"/bottom.toml >> "$XDG_CONFIG_HOME"/bottom/bottom.toml
else
    cp -f config/bottom/bottom.toml "$XDG_CONFIG_HOME"/bottom/bottom.toml
fi

# Hyprland
mkdir -p "$XDG_CONFIG_HOME"/hypr
if [ -f "$themepath/hyprland.conf" ]; then
    ln -sf "$themepath"/hyprland.conf "$XDG_CONFIG_HOME"/hypr/colors.conf
    if pidof Hyprland > /dev/null 2>&1; then
        echo "Reloading Hyprland"
        hyprctl reload > /dev/null 2>&1 &
    fi
fi

# Waybar
mkdir -p "$XDG_CONFIG_HOME"/waybar
if [ -f "$themepath/waybar.css" ]; then
    echo "Reloading waybar"
    ln -sf "$themepath"/waybar.css "$XDG_CONFIG_HOME"/waybar/colors.css
    pkill -USR2 waybar > /dev/null 2>&1 &
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
    killall dunst > /dev/null 2>&1 &
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
mkdir -p "$XDG_CONFIG_HOME"/rofi
if [ -f "$themepath/rofi.rasi" ]; then
    ln -sf "$themepath"/rofi.rasi "$XDG_CONFIG_HOME"/rofi/colors.rasi
fi

# bat
mkdir -p "$XDG_CONFIG_HOME"/bat/themes
if [ -f "$themepath/bat.tmTheme" ]; then
    ln -sf "$themepath"/bat.tmTheme "$XDG_CONFIG_HOME"/bat/themes/custom.tmTheme
    echo '--theme="custom"' > "$XDG_CONFIG_HOME"/bat/config
else
    echo '--theme="base16"' > "$XDG_CONFIG_HOME"/bat/config
fi
echo "Building bat cache"
bat cache --build > /dev/null 2>&1

# Also reload lf to update preview with new colors
if pidof lf > /dev/null 2>&1; then
    lf -remote "send :reload"
fi

echo "Theme applied."
exit 0

