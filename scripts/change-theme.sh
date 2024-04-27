#!/bin/bash

# Setup script environment and functions
. "$(dirname "$0")/env.sh"
. nvim.sh
. utils.sh

get_theme_folder_path() {
    if [ -n "$WAYLAND_DISPLAY" ] && [ "$XDG_CURRENT_DESKTOP" != GNOME ]; then
        selected="$(for theme in "${themes[@]}"
        do
            echo "$(basename "$theme")"
        done | sort -u | rofi -p "Choose a theme" -i -dmenu)"

        if [ -z "$selected" ]; then
            return 1
        fi

        realpath "themes/$selected"
        return
    elif [ -n "$DISPLAY" ]; then
        selected="$(for theme in "${themes[@]}"
        do
            echo "$(basename "$theme")"
        done | sort -u | zenity --title "Theme chooser" --height 400 --width 300 --text "Choose a theme" --list --column "Theme")"
        
        
        if [ -z "$selected" ]; then
            return 1
        fi

        realpath "themes/$selected"
        return
    else
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
                realpath "$theme"
                return
            fi
            n=$((n+1))
        done
    fi
    return 1
}

random_wallpaper() {
    find "$(realpath "$themepath/wallpaper")" -mindepth 1 -maxdepth 1 -type f | shuf -n 1
}

rofi_wallpapers() {
    for file in "$1"/*
    do
        if [ -f "$file" ]; then
            printf "%s\0icon\037%s\n" "$(basename "$file")" "$(realpath "$file")"
        fi
    done
}

select_wallpaper() {
    if [ -n "$WAYLAND_DISPLAY" ] && [ "$XDG_CURRENT_DESKTOP" != GNOME ]; then
        selected_wallpaper="$(rofi_wallpapers "$1" | rofi -p "Choose a wallpaper" -i -dmenu -config "$XDG_CONFIG_HOME/rofi/images.rasi")"
        if [ -n "$selected_wallpaper" ]; then
            realpath "$themepath/wallpaper/$selected_wallpaper"
            return
        else
            return 1
        fi
    elif [ -n "$DISPLAY" ]; then
        wallpaper="$(find -L "$1" -mindepth 1 -maxdepth 1 -type f | head -1)"
        zenity --file-selection --filename "$(realpath "$wallpaper")"
    fi

    if [ -z "$selected_wallpaper" ]; then
        return 1;
    fi

    realpath "$1/$selected_wallpaper"
}

symlink_cfg() {
    if [ ! -f "$1" ]; then
        return 0
    fi
    mkdir -p "$(dirname "$2")"
    ln -sf "$1" "$2"
}

themes_path=./themes

if [ ! -d "$themes_path" ]; then
    echo "Could not find themes folder."
    exit 1
fi

readarray -t themes < <(find "$themes_path" -maxdepth 1 -mindepth 1 -not -name template)

autoselect=false
if [ "$1" = "-a" ]; then
    autoselect=true
    shift 1
fi

selected_theme="$1"

if [ -z "$selected_theme" ] && [ "$autoselect" = false ]; then
    themepath="$(get_theme_folder_path)"
    if [ -z "$themepath" ]; then
        exit
    fi
else
    themepath="$([ -n "$selected_theme" ] || realpath "themes/$selected_theme")"
fi

if [ ! -d "$themepath" ]; then
    echo "Theme doesn't exist."
    exit 1
fi

if [ "$autoselect" = false ]; then
    wallpaper="$(select_wallpaper "$themepath/wallpaper")"
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
if has_command sway && symlink_cfg "$themepath"/sway "$XDG_CONFIG_HOME"/sway/colors; then
    if is_running sway; then
        echo "Reloading sway config"
        sway reload &> /dev/null
    fi
fi

mkdir -p "$XDG_CONFIG_HOME"/river
if has_command river && symlink_cfg "$themepath"/river "$XDG_CONFIG_HOME"/river/colors; then
    if is_running river && [ -n "$WAYLAND_DISPLAY" ]; then
        echo "Reloading river config"
        "$XDG_CONFIG_HOME"/river/colors
    fi
fi

echo "Setting wallpaper: $(basename "$wallpaper")"

# copy /proc/$pid/environ and start a new process with it
restart_wayland_app() {
    local pids="$1"
    for pid in "${pids[@]}"; do
        eval "export $(cat /proc/$pid/environ | tr '\0' '\n' | grep ^WAYLAND_DISPLAY=)"
        "${cmd[@]}" &> /dev/null &
        kill "$pid"
    done
}

if [ -f "$wallpaper" ]; then
    symlink_cfg "$wallpaper" "$XDG_CACHE_HOME"/swaybg/img
    gsettings set org.gnome.desktop.background picture-uri "file://$(realpath "$wallpaper")"
    gsettings set org.gnome.desktop.background picture-uri-dark "file://$(realpath "$wallpaper")"
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
    if is_running hyprpaper; then
        echo "Reloading hyprpaper"
        if pidof Hyprland > /dev/null; then
            hyprctl hyprpaper unload ~/.cache/swaybg/img
            hyprctl hyprpaper preload ~/.cache/swaybg/img
            hyprctl hyprpaper wallpaper ,~/.cache/swaybg/img
        elif kill "$(cat /run/user/"$(id -u)"/hyprpaper.lock)"; then
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
    if [ "$COLOR_SCHEME" = "prefer-dark" ]; then
        gtk-theme -d
    elif [ "$COLOR_SCHEME" = "prefer-light" ]; then
        gtk-theme -l
    fi

    gtk-theme -t "$GTK_THEME"
    if [ -n "$GTK_ICON_THEME" ]; then
        gtk-theme -i "$GTK_ICON_THEME"
    fi
    if [ -n "$CURSOR_THEME" ]; then
        gtk-theme -c "$CURSOR_THEME"
    fi

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
    
    if [ -n "$NVIM_THEME" ]; then
        set_nvim_theme "$NVIM_THEME"
    fi
fi

gen-term-colors gnome-terminal "$themepath/term"

# foot
if has_command foot && symlink_cfg "$themepath"/foot.ini "$XDG_CONFIG_HOME"/foot/theme.ini; then
    zsh_pids=($(pgrep -x -P "$(pidof foot | tr ' ' ',')" zsh 2>/dev/null))
    if [ -n "${zsh_pids[*]}" ]; then 
        kill -SIGUSR1 "${zsh_pids[*]}"
        apply_theme="$(zsh -c 'TERM=foot; source $ZDOTDIR/zsh-theme.zsh; apply_theme')"
        for zsh_pid in "${zsh_pids[@]}"
        do
            echo -n "$apply_theme" >> /proc/$zsh_pid/fd/0
        done
    fi
fi

# kitty
has_command kitty && symlink_cfg "$themepath"/kitty.conf "$XDG_CONFIG_HOME"/kitty/themes/custom.conf && pkill -USR1 -x kitty

# alacritty
has_command alacritty && symlink_cfg "$themepath"/alacritty.yml "$XDG_CONFIG_HOME"/alacritty/theme.yml

# wezterm
has_command wezterm && symlink_cfg "$themepath"/wezterm.lua "$XDG_CONFIG_HOME"/wezterm/colors.lua

# cava
if [ -f "$themepath/cava" ] && has_command cava; then
    mkdir -p "$XDG_CONFIG_HOME"/cava
    echo "Reloading cava"
    cp -f config/cava/config "$XDG_CONFIG_HOME"/cava/config
    cat "$themepath"/cava >> "$XDG_CONFIG_HOME"/cava/config
    pkill -USR1 -x cava &> /dev/null & # Reload cava config
fi

# bottom
if has_command btm; then
    mkdir -p "$XDG_CONFIG_HOME"/bottom
    cp -f config/bottom/bottom.toml "$XDG_CONFIG_HOME"/bottom/bottom.toml
    if [ -f "$themepath/bottom.toml" ]; then
        cat "$themepath"/bottom.toml >> "$XDG_CONFIG_HOME"/bottom/bottom.toml
    fi
fi

# Hyprland
if symlink_cfg "$themepath"/hyprland.conf "$XDG_CONFIG_HOME"/hypr/colors.conf; then
    if pidof Hyprland &> /dev/null; then
        echo "Reloading Hyprland"
        hyprctl reload &> /dev/null &
    fi
fi

# Waybar
has_command waybar && symlink_cfg "$themepath"/waybar.css "$XDG_CONFIG_HOME"/waybar/colors.css && pkill -USR2 -x waybar &> /dev/null

# Reload firefox using socket connection script
if [ -f /tmp/firefox-remote.pid ]; then
    ln -sf "$themepath/firefox" /tmp/firefox-remote
    kill -SIGUSR1 "$(cat /tmp/firefox-remote.pid)"
fi

# btop
has_command btop && symlink_cfg "$themepath"/btop.theme "$XDG_CONFIG_HOME"/btop/themes/custom.theme

# dunst
has_command dunst && symlink_cfg "$themepath"/dunstrc "$XDG_CONFIG_HOME"/dunst/dunstrc

# rofi
has_command rofi && symlink_cfg "$themepath"/rofi.rasi "$XDG_CONFIG_HOME"/rofi/colors.rasi

# bat
if has_command bat; then
    if [ -f "$themepath/bat.tmTheme" ]; then
        symlink_cfg "$themepath"/bat.tmTheme "$XDG_CONFIG_HOME"/bat/themes/custom.tmTheme
        echo '--theme="custom"' > "$XDG_CONFIG_HOME"/bat/config
    else
        echo '--theme="base16"' > "$XDG_CONFIG_HOME"/bat/config
    fi
    echo "Building bat cache"
    bat cache --build &> /dev/null
fi

# Also reload lf to update preview with new colors
if is_running lf; then
    lf -remote "send :reload"
fi

echo "Theme applied."
