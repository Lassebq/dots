lfcd() {
    tmp="$(mktemp)"
    # `command` is needed in case `lfcd` is aliased to `lf`
    command lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        rm -f "$tmp"
        if [ -d "$dir" ]; then
            if [ "$dir" != "$(pwd)" ]; then
                cd "$dir"
            fi
        fi
    fi
}

zinkrun() {
    __GLX_VENDOR_LIBRARY_NAME=mesa \
    __EGL_VENDOR_LIBRARY_FILENAMES=/usr/share/glvnd/egl_vendor.d/50_mesa.json \
    MESA_LOADER_DRIVER_OVERRIDE=zink GALLIUM_DRIVER=zink \
    "$@"
}

softrun() {
    # llvmpipe or softpipe
    local driver=llvmpipe
    VK_DRIVER_FILES=/usr/share/vulkan/icd.d/lvp_icd.i686.json:/usr/share/vulkan/icd.d/lvp_icd.x86_64.json \
    LIBGL_ALWAYS_SOFTWARE=1 \
    __GLX_VENDOR_LIBRARY_NAME=mesa \
    __EGL_VENDOR_LIBRARY_FILENAMES=/usr/share/glvnd/egl_vendor.d/50_mesa.json \
    MESA_LOADER_DRIVER_OVERRIDE="$driver" GALLIUM_DRIVER="$driver" \
    "$@"
}

# perhaps it's best to use libstrangle here for nvidia
vsync() {
    local mode=fifo
    local glmode=3
    if [ "$1" = --mailbox ]; then
        mode=mailbox
        glmode=0
        shift
    elif [ "$1" = --immediate ]; then
        mode=immediate
        glmode=0
        shift
    fi
    vblank_mode="$glmode" MESA_VK_WSI_PRESENT_MODE="$mode" "$@"
}

_wined3d() {
    if [ -n "$WINEDLLOVERRIDES" ]; then
        WINEDLLOVERRIDES="${WINEDLLOVERRIDES};"
    fi
    WINEDLLOVERRIDES="${WINEDLLOVERRIDES}*d3d8,*d3d9,*d3d10,*d3d10_1,*d3d10core,*d3d11,*dxgi=b" "$@"
}

damavand() {
    WINE_D3D_CONFIG="renderer=vulkan" _wined3d "$@"
}

wined3d() {
    WINE_D3D_CONFIG="renderer=gl" _wined3d "$@"
}

steamrun() {
    steamapp-launcher run "$(steamapp-launcher query appid "$1")"
}

export MANGOHUD_DLSYM=1 # or alias mangohud="mangohud --dlsym"

cpr() {
    rsync --archive -hh --partial --info=stats1,progress2 --modify-window=1 "$@"
}

mvr() {
    rsync --archive -hh --partial --info=stats1,progress2 --modify-window=1 --remove-source-files "$@"
}

aliases() {
    "$EDITOR" "$ZDOTDIR/zsh-aliases.zsh"
}

decompile() {
    java -jar /usr/share/java/cfr/cfr.jar --comments false "$1" | bat --language=java --color=always --paging=always --decorations=never
}

if [ "$TERM" = alacritty ] || [ "$TERM" = foot ]; then
    alias tmux="TERM=xterm-256color tmux"
fi
if [ "$TERM" = linux ]; then
    alias lf="lfcd -config \"$XDG_CONFIG_HOME/lf/lfrc_tty\""
else
    alias lf="lfcd"
fi


sudo=$(command -v sudo)

if [ -z "$sudo" ]; then
    sudo=$(command -v doas)
fi
alias doas="doas "
alias sudo="sudo "

sudoalias() {
    [ -z "$(command -v "$1")" ] && return
    alias "$1"="$sudo $1"
}

sudoalias apk
sudoalias pacman
sudoalias dmesg
sudoalias efibootmgr
sudoalias sbctl

unset -f sudoalias
unset sudo

alias resolvecd='cd $(realpath .)'
alias curl="curl -L"
alias hexedit="hexedit --color"
alias code="code-oss"
alias ncmp="ncmpcpp"
alias grep="grep --color"
alias less="$PAGER"
alias la="ls -A"
alias ll="ls -al"
alias ls="ls --color -Fh"
alias rm="rm -i" # Remove safely
alias mv="mv -i" # Move safely
alias cp="cp -i" # Copy safely
alias mime="file -Lb --mime-type"
alias trash="gio trash"

alias apk32="apk --arch x86 -p /alpine32"
