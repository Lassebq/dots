# My dotfiles

Primarily used software is underlined, but my dots and the installer script contain configuration for other options as well.

| Distro: | [Arch](https://archlinux.org)|
| --- | ----------- |
| Wayland compositor: | [<ins>Hyprland</ins>](https://hyprland.org), [<ins>River</ins>](https://github.com/riverwm/river), [Sway](https://github.com/swaywm/sway)       |
| Bar: | [<ins>Waybar</ins>](https://github.com/Alexays/Waybar)           |
| Terminal: | [<ins>foot</ins>](https://codeberg.org/dnkl/foot), [kitty](https://github.com/kovidgoyal/kitty), [alacritty](https://github.com/alacritty/alacritty), [WezTerm](https://wezfurlong.org/wezterm)<!-- God damn it sucks --> |
| Shell: | [<ins>zsh</ins>](https://www.zsh.org), [bash](https://www.gnu.org/software/bash/)|
| Editor: | [<ins>VSCode</ins>](https://github.com/microsoft/vscode), [<ins>Neovim</ins>](https://neovim.io)                        |
| Wallpaper daemon: | [<ins>swaybg</ins>](https://github.com/swaywm/swaybg), [swww](https://github.com/Horus645/swww), [wbg](https://codeberg.org/dnkl/wbg), [hyprpaper](https://github.com/hyprwm/hyprpaper) |
| App launcher: | [<ins>rofi</ins>](https://github.com/davatorium/rofi)   |
| Lock screen: | [<ins>gtklock</ins>](https://github.com/jovanlanik/gtklock)  <!-- Meh, I need a lock screen for riverwm, but gtklock doesn't work on it --> |

There's an install script for Arch Linux. It will install required packages and back up your .config directory before copying new configs

I can confirm that it works with Artix, but it wasn't intended for it, so use at your own risk.

You can clone this repo and run install.sh or run this command directly from your home directory:
```bash
bash -c "$(curl https://raw.githubusercontent.com/Lassebq/dots/main/install.sh)"
```
