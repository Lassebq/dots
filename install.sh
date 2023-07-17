#!/bin/bash

preppackages=(
"base-devel"
"git"
)

checkpackages=(
"starship"
"zsh"
"kitty"
"grim"
"slurp"
"wlogout"
"wl-clipboard"
"gtklock"
"swayidle"
"pipewire-alsa"
"pipewire-pulse"
"pamixer"
"pavucontrol"
"rofi-lbonn-wayland-git"
"ttf-jetbrains-mono-nerd"
)

riverpkgs=(
"waybar"
"swww"
"wlopm"
#"xdg-desktop-portal-wlr"
)

swaypkgs=(
"waybar"
"swaybg"
"autotiling"
#"xdg-desktop-portal-wlr"
)

hyprlandpkgs=(
"waybar-hyprland"
"swww"
"xdg-desktop-portal-hyprland"
)

checkpackages_extra=(
"bat"
"btop"
"cava"
"dunst"
"exa"
"fd"
"ffmpegthumbnailer"
"wf-recorder"
"wtype"
"lf"
"mpd"
"mpd-mpris-bin"
"mpc"
"mpv"
"mpv-mpris"
"neovim"
"nitch"
"google-chrome"
"imagemagick"
"rofi-calc"
"rofi-emoji"
"xdg-desktop-portal-termfilechooser-git"
"polkit"
"polkit-gnome"
)

desktops=(
"hyprland"
"hyprland-git"
"river"
"river-git"
"sway"
"sway-git"
)

nvidiapkgs=(
"linux-headers"
"nvidia-dkms"
"nvidia-settings"
"libva"
"libva-nvidia-driver-git"
)

INST_LOG="/dev/null"

is_nvidia() {
    lspci -k | grep -A 2 -E "(VGA|3D)" | grep NVIDIA > /dev/null
}

pkg_installed() {
    pacman -Qi "$1" > /dev/null 2>&1
}

y_or_n() {
    echo -n " [y/N]:"
    read -r yn
    case $yn in
        [Yy]* ) return 0;;
        * ) return 1;;
    esac
}

echo -e '\033[94m     ____        __      
    / __ \____  / /______
   / / / / __ \/ __/ ___/
  / /_/ / /_/ / /_(__  ) 
 /_____/\____/\__/____/  
\033[0m'

echo "This script will install a wayland compositor of your choice with my dot files"
echo
echo -n "Do you want to proceed with install?"
y_or_n || exit

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path" || exit

desktops_fmt="%d. [\033[94m%s\033[0m]\\n"

while true; do
    i=1
    echo "Select preferred desktop:"
    for desktop in "${desktops[@]}"
    do
        printf "$desktops_fmt" "$i" "$desktop"
        i=$((i+1))
    done
    printf "Type the number of a desktop in the list: "
    read -r selected_num

    i=1
    for desktop in "${desktops[@]}"
    do
        if [ $i = "$selected_num" ]; then
            selected_desktop=$desktop
            break
        fi
        i=$((i+1))
    done
    if [ -z "$selected_desktop" ]; then
        echo "Invalid desktop"
    else
        break
    fi
done

echo "Selected desktop: $selected_desktop"

installpkgs=()
makeyay=()

echo "Finding necessary packages..."
for pkg in "${preppackages[@]}"; do
    if pkg_installed "$pkg"; then
        printf "[\e[92mFOUND\e[0m] %s\\n" "$pkg"
    else
        makeyay+=("$pkg")
        printf "[\e[91mNOT FOUND\e[0m] %s\\n" "$pkg"
    fi
done

for pkg in "${checkpackages[@]}"; do
    if pkg_installed "$pkg"; then
        printf "[\e[92mFOUND\e[0m] %s\\n" "$pkg"
    else
        installpkgs+=("$pkg")
        printf "[\e[91mNOT FOUND\e[0m] %s\\n" "$pkg"
    fi
done

if (( ${#installpkgs[@]} )) || (( ${#makeyay[@]} )); then
    echo -n "Install missing packages?"
    y_or_n || (echo "Cannot proceed without necessary packages!"; exit)
    sudo pacman -Syy || ( echo "Could not update database!"; exit)
    if (( ${#makeyay[@]} )); then
        sudo pacman -S --noconfirm "${makeyay[@]}"
    fi
    if ! pkg_installed "yay"; then
        tempdir=$(mktemp -d)
        git clone https://aur.archlinux.org/yay.git "$tempdir" || exit
        cd "$tempdir" || exit
        makepkg -si --noconfirm || exit
    fi
    echo "Installing: ${installpkgs[*]}"
    yay -S --noconfirm "${installpkgs[@]}"
fi

if ! pkg_installed "$selected_desktop"; then
if is_nvidia; then
    echo "Looks like you're using NVIDIA graphics card."
    if [ "$selected_desktop" = "hyprland" ]; then
        echo "Use hyprland-nvidia?"
        if y_or_n; then
            yay -S --noconfirm hyprland-nvidia
        else
            yay -S --noconfirm hyprland
        fi
    elif [ "$selected_desktop" = "hyprland-git" ]; then
        echo "Use wlroots-nvidia-git?"
        if y_or_n; then
            yay -S --noconfirm wlroots-nvidia-git hyprland-shared-wlroots-git
        else
            yay -S --noconfirm hyprland-shared-wlroots-git
        fi
    elif [ "$selected_desktop" = "*-git" ]; then
        echo "Use wlroots-nvidia-git?"
        if y_or_n; then
            yay -S --noconfirm wlroots-nvidia-git "$selected_desktop"
        else
            yay -S --noconfirm "$selected_desktop"
        fi 
    else
        echo "Use wlroots-nvidia?"
        if y_or_n; then
            yay -S --noconfirm wlroots-nvidia "$selected_desktop"
        else
            yay -S --noconfirm "$selected_desktop"
        fi
    fi
    echo "Rebuild kernel with NVIDIA Dynamic Kernel Module Support?"
    if y_or_n; then
        installpkgs=()
        for pkg in "${nvidiapkgs[@]}"; do
            if ! pkg_installed "$pkg"; then
                installpkgs+=("$pkg")
            fi
        done
        yay -S --noconfirm "${installpkgs[@]}"
        sudo sed -i 's/MODULES=()/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
        echo "options nvidia-drm modeset=1" | sudo tee -a /etc/modprobe.d/nvidia.conf
        sudo mkinitcpio -p linux
    fi
else
    if [ "$selected_desktop" = "hyprland-git" ]; then
        yay -S --noconfirm hyprland-shared-wlroots-git
    else
        yay -S --noconfirm "$selected_desktop"
    fi
fi
fi

installpkgs=()
case "$selected_desktop" in
"hyprland" | "hyprland-git")
    for pkg in "${hyprlandpkgs[@]}"; do
        if ! pkg_installed "$pkg"; then
            installpkgs+=("$pkg")
        fi
    done
    yay -S --noconfirm "${installpkgs[@]}"
    ;;
"river" | "river-git")
    for pkg in "${riverpkgs[@]}"; do
        if ! pkg_installed "$pkg"; then
            installpkgs+=("$pkg")
        fi
    done
    yay -S --noconfirm "${installpkgs[@]}"
    ;;
"sway" | "sway-git")
    for pkg in "${swaypkgs[@]}"; do
        if ! pkg_installed "$pkg"; then        
            installpkgs+=("$pkg")
        fi
    done
    yay -S --noconfirm "${installpkgs[@]}"
    ;;
esac

installpkgs=()
for pkg in "${checkpackages_extra[@]}"; do
    if ! pkg_installed "$pkg"; then
        installpkgs+=("$pkg")
    fi
done

installpkgs2=()

if (( ${#installpkgs[@]} )); then
    echo "Extra packages:"
    i=1
    for pkg in "${installpkgs[@]}"; do
        printf "$desktops_fmt" "$i" "$pkg"
        i=$((i+1))
    done
    echo 'Packages to exclude: (eg: "1 2 3")'
    read -r string
    IFS=' ' read -r -a exclude <<< "$string"
    

    i=1
    for pkg in "${installpkgs[@]}"; do
        excluded=false
        for n in "${exclude[@]}"
        do 
            if [ "$i" -eq "$n" ]; then
                excluded=true
                break
            fi
        done
        if [ "$excluded" = false ]; then
            installpkgs2+=("$pkg")
        fi
        i=$((i+1))
    done
    yay -S --noconfirm "${installpkgs2[@]}"
fi

pwd

echo -n "Backup config?"
if y_or_n; then
    cp -r "$HOME/.config" "$HOME/.config_BACKUP"
fi

echo -n "Copy new config files?"
if y_or_n; then
    sudo chsh -s /bin/zsh "$USER"
    ln -sf ~/.config/zsh/.zshenv ~/.zshenv
    mkdir -p ~/.local/share/zsh
    mkdir -p ~/.cache/zsh
    mkdir -p ~/.local/share/mpd
    cp -r ./config/. ~/.config/
    cp -r ./local/share/. ~/.local/share/
    ./change-theme.sh "$(basename "$(find themes/ -maxdepth 1 -mindepth 1 | head -1)")"
fi

echo "Setup complete."
