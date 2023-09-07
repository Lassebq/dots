#!/bin/bash

preppkgs=(
"unzip"
"base-devel"
"git"
)

#TODO yay fucks up those packages so we will install them as soon as possible
importantpkgs=(
"noto-fonts"
"wireplumber"
"pipewire-jack"
"pipewire-alsa"
"pipewire-pulse"
"rofi-lbonn-wayland-git"
"xdg-desktop-portal-wlr"
"xdg-desktop-portal-hyprland"
"wlroots-nvidia"
"wlroots-nvidia-git"
)

checkpkgs=(
"jq"
"less"
"libadwaita-without-adwaita-git" # https://stopthemingmy.app/ fuck you gnome devs
"starship"
"grim"
"slurp"
"swayidle"
"swayosd-git"
"wireplumber"
"wlogout"
"wl-clipboard"
"noto-fonts"
"pipewire-alsa"
"pipewire-pulse"
"pipewire-jack"
"pamixer"
"brightnessctl"
"rofi-lbonn-wayland-git"
"rofi-calc"
"rofi-emoji"
"ttf-jetbrains-mono-nerd"
"xdg-utils"
)

riverpkgs=(
"waybar-git"
"wlopm"
"xdg-desktop-portal-wlr"
)

swaypkgs=(
"gtklock"
"waybar-git"
"autotiling"
"xdg-desktop-portal-wlr"
)

hyprlandpkgs=(
"gtklock"
"waybar-git"
"xdg-desktop-portal-hyprland"
)

checkpackages_extra=(
"bat"
"btop"
"bottom"
"cava"
"dunst"
"fd"
"lf-git"
"hyprpicker"
"wf-recorder"
"wtype"
"openssh"
"pavucontrol"
"man"
"mpd"
"mpv"
"ncmpcpp"
"neovim"
"xdg-desktop-portal-termfilechooser-git"
"polkit-gnome"
"wine"
)

shellpkg=(
"bash"
"zsh"
)

codepkg=(
"code"
"vscodium"
"vscodium-bin"
"visual-studio-code-bin"
)

wallpaperpkg=(
"swaybg"
"swww"
"wbg"
"hyprpaper"
)

terminalpkg=(
"foot"
"kitty"
"alacritty"
"wezterm"
)

webbrowserpkg=(
"firefox"
"firefox-nightly"
"firefox-nightly-bin"
"google-chrome"
"chromium"
)

desktops=(
"hyprland"
"hyprland-git"
"river"
"river-git"
"sway"
"sway-git"
)

vscode_themes=(
"catppuccin.catppuccin-vsc"
"arcticicestudio.nord-visual-studio-code"
"sainnhe.everforest"
"enkia.tokyo-night"
"mvllow.rose-pine"
)

nvidiapkgs=(
"linux-headers"
"nvidia-dkms"
"nvidia-settings"
"libva"
"libva-nvidia-driver-git"
)

array_contains() {
    for element in $1
    do
        if [ "$element" = "$2" ]; then
            return 0
        fi
    done
    return 1
}

is_nvidia() {
    lspci | grep -E "(VGA|3D).*NVIDIA" > /dev/null
}

exact_pkg_installed() {
    [ "$(pacman -Qq "$1" 2>/dev/null)" = "$1" ]
}

pkg_installed() {
    pacman -Q "$1" > /dev/null 2>&1
}

enable_multilib() {
    if ! grep -x "\[multilib\]\s*" /etc/pacman.conf > /dev/null; then
        ( echo "[multilib]"; echo "Include = /etc/pacman.d/mirrorlist" ) | sudo tee -a /etc/pacman.conf > /dev/null
    fi
}

bold='\033[1m'
default='\033[0m'
red='\033[31m'
yellow='\033[33m'
green='\033[32m'
cyan='\033[36m'
blue='\033[34m'
magenta='\033[35m'
black='\033[30m'
white='\033[37m'
light_red='\033[91m'
light_yellow='\033[93m'
light_green='\033[92m'
light_cyan='\033[96m'
light_blue='\033[94m'
light_magenta='\033[95m'
light_black='\033[90m'
light_white='\033[97m'

warning() {
    if [ -n "$1" ]; then
        echo -e "${light_yellow}Warning: $1${default}"
    else
        echo -e "${light_yellow}Something went wrong!${default}"
    fi
}

fatal() {
    if [ -n "$1" ]; then
        echo -e "${light_red}Error: $1${default}"
    else
        echo -e "${light_red}Something went wrong!${default}"
    fi
    exit 1
}

y_or_n() {
    echo -n " [y/n]:"
    read -r yn
    case $yn in
        [Yy]* ) return 0;;
        * ) return 1;;
    esac
}

find_missing_pkgs() {
    for pkg in $1; do
        if ! pkg_installed "$pkg"; then
            installpkgs+=("$pkg")
        fi
    done
}

fancy_fmt="%d. [$light_blue%s$default]\\n"

select_msg() {
    while true; do
        local i=1
        echo "$1:" >> /dev/tty
        for option in $2
        do
            printf "$fancy_fmt" "$i" "$option" >> /dev/tty
            i=$((i+1))
        done
        echo -n "Type the number of option in the list: " >> /dev/tty
        read -r selected_num

        i=1
        for option in $2
        do
            if [ $i = "$selected_num" ]; then
                selected_option=$option
                break
            fi
            i=$((i+1))
        done
        if [ -n "$selected_option" ]; then
            break
        fi
    done
    echo "$selected_option"
}

if [ "$(id -u)" = 0 ]; then
    echo "Please log in as the user which will be using these dots"
    exit 1
fi

echo -en "$bold$blue"
echo -e '
     ____        __
    / __ \____  / /______
   / / / / __ \/ __/ ___/
  / /_/ / /_/ / /_(__  )
 /_____/\____/\__/____/'
echo -en "$default"

echo "This script will install a wayland compositor of your choice with my dot files"
echo
echo -n "Do you want to proceed with install?"
y_or_n || exit

if [ -z "${BASH_SOURCE[0]}" ]; then
    if ! pkg_installed "git"; then
        sudo pacman -Sy git
    fi
    git clone https://github.com/Lassebq/dots.git dots
    cd dots || fatal
else
    parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
    cd "$parent_path" || fatal
fi

makeyay=()

for pkg in "${preppkgs[@]}"; do
    if ! pkg_installed "$pkg"; then
        makeyay+=("$pkg")
    fi
done

if ! pkg_installed "yay"; then
    echo "Installing yay"
    sudo pacman -Sy || fatal "Could not update database!"
    if (( ${#makeyay[@]} )); then
        sudo pacman -S --noconfirm "${makeyay[@]}" || fatal "Failed to install necessary packages!"
    fi
    tempdir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$tempdir" || fatal
    cd "$tempdir" || fatal
    makepkg -si --noconfirm || fatal "Failed to install necessary packages!"
fi

installpkgs=()

if is_nvidia && ! pkg_installed nvidia; then
    echo -e "Looks like you're using ${light_green}NVIDIA${default} graphics card."
    echo -n "Rebuild initramfs with nvidia-dkms?"
    if y_or_n; then
        find_missing_pkgs "${nvidiapkgs[*]}"
        yay -S --noconfirm "${installpkgs[@]}" || fatal "Failed to install!"
        sudo sed -i 's/MODULES=()/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
        echo "options nvidia-drm modeset=1" | sudo tee -a /etc/modprobe.d/nvidia.conf
        sudo mkinitcpio -p linux
	sudo systemctl enable nvidia-hibernate.service nvidia-persistenced.service nvidia-powerd.service nvidia-resume.service nvidia-suspend.service
    fi
fi

installpkgs=()

selected_desktop="$(select_msg "Select preferred desktop" "${desktops[*]}")"
echo "Selected desktop: $selected_desktop"

if ! exact_pkg_installed "$selected_desktop"; then
    desktop_pkgs=("$selected_desktop")
    if is_nvidia; then
        if [ "$selected_desktop" = "hyprland" ]; then
            desktop_pkgs=(hyprland-nvidia)
        elif [ "$selected_desktop" = "hyprland-git" ]; then
            # If we already have wlroots installed and it's not -git, install regular hyprland-git
            if exact_pkg_installed "wlroots"; then
                desktop_pkgs=(hyprland-nvidia-git)
            else
                desktop_pkgs=(wlroots-nvidia-git hyprland-shared-wlroots-git)
            fi
        elif [[ "$selected_desktop" = "*-git" && "$selected_desktop" != "river-git" ]]; then
            desktop_pkgs=(wlroots-nvidia-git "$selected_desktop")
        else
            desktop_pkgs=(wlroots-nvidia "$selected_desktop")
        fi
    else
        if [ "$selected_desktop" = "hyprland-git" ]; then
            # If we already have wlroots installed and it's not -git, install regular hyprland-git
            if exact_pkg_installed "wlroots"; then
                desktop_pkgs=(hyprland-git)
            else
                desktop_pkgs=(hyprland-shared-wlroots-git)
            fi
        fi
    fi
    installpkgs+=("${desktop_pkgs[@]}")
fi

find_missing_pkgs "${checkpkgs[*]}"

case "$selected_desktop" in
"hyprland" | "hyprland-git")
    find_missing_pkgs "${hyprlandpkgs[*]}";;
"river" | "river-git")
    find_missing_pkgs "${riverpkgs[*]}";;
"sway" | "sway-git")
    find_missing_pkgs "${swaypkgs[*]}";;
esac

vscode="$(select_msg "Select Visual Studio Code" "${codepkg[*]} SKIP")"
if [ "$vscode" != "SKIP" ] && ! exact_pkg_installed "$vscode"; then
    installpkgs+=("$vscode")
    if [ "$vscode" != "visual-studio-code-bin" ]; then
        installpkgs+=("${vscode}-features")
        installpkgs+=("${vscode}-marketplace")
    fi
fi

bgutil="$(select_msg "Select wallpaper daemon" "${wallpaperpkg[*]}")"
if ! exact_pkg_installed "$bgutil"; then
    installpkgs+=("$bgutil")
fi

case "$bgutil" in
    "swaybg")
        wallpapercmd='swaybg -i ~/.cache/swaybg/img &';;
    "swww")
        wallpapercmd='swww init && swww img ~/.cache/swaybg/img';;
    "wbg")
        wallpapercmd='wbg ~/.cache/swaybg/img &';;
esac

shell="$(select_msg "Select shell" "${shellpkg[*]}")"
if ! exact_pkg_installed "$shell"; then
    installpkgs+=("$shell")
fi

terminal="$(select_msg "Select terminal emulator" "${terminalpkg[*]}")"
if ! exact_pkg_installed "$terminal"; then
    installpkgs+=("$terminal")
fi

browser="$(select_msg "Select web browser" "${webbrowserpkg[*]}")"
if ! exact_pkg_installed "$browser"; then
    installpkgs+=("$browser")
fi

installpkgs1=()
for pkg in "${checkpackages_extra[@]}"; do
    if ! pkg_installed "$pkg"; then
        installpkgs1+=("$pkg")
    fi
done

if (( ${#installpkgs[@]} )); then
    echo "Extra packages:"
    i=1
    for pkg in "${installpkgs1[@]}"; do
        printf "$fancy_fmt" "$i" "$pkg"
        i=$((i+1))
    done
    echo 'Packages to install: (eg: "1-3 5 7")'
    read -r string
    IFS=' ' read -r -a include <<< "$string"
    
    for id in "${include[@]}"; do
        if [[ "$id" = *-* ]]; then
            start="${id//-[0-9]*/}"
            end="${id//[0-9]*-/}"
            for ((i="$start"; i <= "$end"; i++))
            do
                installpkgs+=("${installpkgs1[(($i-1))]}")
            done
        else
            installpkgs+=("${installpkgs1[(($id-1))]}")
        fi
    done
fi

# Resolve optional dependencies

if array_contains "${installpkgs[*]}" "ncmpcpp"; then
    installpkgs+=("mpd")
fi

if array_contains "${installpkgs[*]}" "mpd"; then
    installpkgs+=("mpd-mpris" "mpc")
fi

if array_contains "${installpkgs[*]}" "mpv"; then
    installpkgs+=("mpv-mpris")
fi

if array_contains "${installpkgs[*]}" "lf"; then
    installpkgs+=("imagemagick" "ffmpegthumbnailer" "bat")
fi

if array_contains "${installpkgs[*]}" "wine"; then
    if is_nvidia; then
        installpkgs+=("lib32-nvidia-utils")
    else
        installpkgs+=("lib32-mesa")
    fi
    installpkgs+=("lib32-pipewire")
    enable_multilib
fi

printf "\n"
echo "Following packages will be installed:"
printf "$light_blue"
i=1
for pkg in "${installpkgs[@]}"
do
    printf "%s\n" "$pkg"
    i=$((i+1))
done | sort | column -c$(tput cols)
printf "$default\n"

read -n 1 -s -r -p "Press any key to continue"
printf "\n"


installpkgs1=()
for pkg in "${importantpkgs[@]}"; do
    if array_contains "${installpkgs[@]}" "$pkg"; then
        installpkgs1+=("$pkg")
    fi
done
yay -Sy --noconfirm "${installpkgs1[@]}" || fatal "Failed to install packages!"

yay -S --noconfirm "${installpkgs[@]}" || fatal "Failed to install packages!"

modify_env() {
    #TODO slashes in a variable?
    sed "s|\(export $1=\).*|\1\"$2\"|g" ~/.profile
}

write_script() {
    echo '#!/bin/sh'
    echo "$1"
}

echo -n "Backup config?"
if y_or_n; then
    cp -r "$HOME/.config" "$HOME/.config_BACKUP"
fi

echo -e "Copy new config files? [\e[91mY\e[0mes | \e[91mN\e[0mo | Sym\e[91mL\e[0mink]:"
read -r copyconf
[ "$copyconf" = Y ] && copyconf=y
[ "$copyconf" = N ] && copyconf=n

if [ "$copyconf" = y ] || [ "$copyconf" = l ]; then
    gsettings set org.gnome.desktop.interface font-name "JetBrainsMono NF 12"
    sudo chsh -s /bin/"$shell" "$USER" || warning "Shell could not be changed"
    if pkg_installed mpd; then
        mkdir -p ~/.local/share/mpd
    fi
    # Cleanup bash leftovers
    rm -f ~/.bashrc ~/.bash_logout ~/.bash_profile ~/.bash_history ~/.lesshst
    if [ "$shell" = zsh ]; then 
        mkdir -p ~/.cache/zsh
        ln -sfT ~/.config/zsh/.zshenv ~/.zshenv
    elif [ "$shell" = bash ]; then
        ln -sfT ~/.config/bash/.bashrc ~/.bashrc
        ln -sfT ~/.config/bash/.bash_profile ~/.bash_profile
    fi
    cp -rf ./local/. ~/.local/
    # make .mozilla/firefox/$USER the default profile
    if [[ "$browser" = firefox* ]]; then
        mkdir -p ~/.mozilla/firefox/"$USER"
        echo "[Profile0]
Name=$USER
IsRelative=1
Path=$USER
Default=1
" > ~/.mozilla/firefox/profiles.ini
	echo "[4F96D1932A9F858E]
Default=$USER
Locked=1
" > ~/.mozilla/firefox/installs.ini
        git clone https://github.com/black7375/Firefox-UI-Fix.git ~/.mozilla/firefox/"$USER"/chrome
        cp ~/.mozilla/firefox/"$USER"/chrome/user.js ~/.mozilla/firefox/"$USER"/user.js
        #TODO may need to tweak some options in user.js
    fi
    # Set default browser
    case "$browser" in
        "firefox" | "firefox-nightly" | "google-chrome" | "chromium")
            xdg-settings set default-web-browser "$browser.desktop";;
        "firefox-nightly-bin")
            xdg-settings set default-web-browser "firefox-nightly.desktop";;
    esac

    if [ "$copyconf" = y ]; then
        cp -r ./config/. ~/.config/
    elif [ "$copyconf" = l ]; then
        ln -sf "$(realpath ./config)"/* ~/.config/
    fi
    
    if [[ "$browser" = firefox* ]]; then
        mv ~/.config/firefox/* ~/.mozilla/firefox/"$USER"/chrome/
    else
        rm -rf ~/.config/firefox
    fi
    mv ~/.config/profile ~/.profile
    
    modify_env "TERMINAL" "$terminal"

    if ! pkg_installed "bat"; then
        modify_env "PAGER" "less --use-color"
    fi
    
    if [ -f ~/.profile ]; then
        source ~/.profile
    fi

    if [ -n "$ZDOTDIR" ]; then
        mkdir -p "$ZDOTDIR"
        curl "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/lib/key-bindings.zsh" -o "$ZDOTDIR/zsh-key-bindings.zsh"
        curl "https://raw.githubusercontent.com/zsh-users/zsh-autosuggestions/master/zsh-autosuggestions.zsh" -o "$ZDOTDIR/zsh-autosuggestions.zsh"
        curl "https://raw.githubusercontent.com/jirutka/zsh-shift-select/master/zsh-shift-select.plugin.zsh" -o "$ZDOTDIR/zsh-shift-select.zsh"
    fi

    write_script "$wallpapercmd" > ~/.local/bin/wallpaper
    chmod +x ~/.local/bin/wallpaper
    ./change-theme.sh "$(basename "$(find themes/ -maxdepth 1 -mindepth 1 | head -1)")"
fi

if [ -z "$VSCODE_PORTABLE" ]; then
    if [ -f "$XDG_CONFIG_HOME/Code/User/settings.json" ]; then
        for vscode in "Code - OSS" "VSCodium"
        do
            mkdir -p "$XDG_CONFIG_HOME/$vscode/User"
            cp -f "$XDG_CONFIG_HOME/Code/User/settings.json" "$XDG_CONFIG_HOME/$vscode/User/settings.json"
        done
    fi
else
    if [ -f "$XDG_CONFIG_HOME/Code/User/settings.json" ]; then
        mkdir -p "$VSCODE_PORTABLE"
        mv -T "$XDG_CONFIG_HOME/Code" "$VSCODE_PORTABLE/user-data"
    fi
fi

if pkg_installed "code"; then
    echo -n "Install VSCode themes?"
    if y_or_n; then
        for theme in "${vscode_themes[@]}"
        do
            code --install-extension "$theme"
        done
    fi
elif pkg_installed "codium"; then
    echo -n "Install VSCodium themes?"
    if y_or_n; then
        for theme in "${vscode_themes[@]}"
        do
            codium --install-extension "$theme"
        done
    fi
fi

echo "Setup complete."
