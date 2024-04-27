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
    env __GLX_VENDOR_LIBRARY_NAME=mesa \
        __EGL_VENDOR_LIBRARY_FILENAMES=/usr/share/glvnd/egl_vendor.d/50_mesa.json \
        MESA_LOADER_DRIVER_OVERRIDE=zink GALLIUM_DRIVER=zink \
        "$@"
}

softrun() {
    # llvmpipe or softpipe
    local driver=llvmpipe
    env VK_DRIVER_FILES=/usr/share/vulkan/icd.d/lvp_icd.i686.json:/usr/share/vulkan/icd.d/lvp_icd.x86_64.json \
        LIBGL_ALWAYS_SOFTWARE=1 \
        __GLX_VENDOR_LIBRARY_NAME=mesa \
        __EGL_VENDOR_LIBRARY_FILENAMES=/usr/share/glvnd/egl_vendor.d/50_mesa.json \
        MESA_LOADER_DRIVER_OVERRIDE="$driver" GALLIUM_DRIVER="$driver" \
        "$@"
}

wined3d() {
    env WINEDLLOVERRIDES="$WINEDLLOVERRIDES;d3d9,d3d10,d3d10_1,d3d10core,d3d11,dxgi=b" "$@"
}

cpr() {
    rsync --archive -hh --partial --info=stats1,progress2 --modify-window=1 "$@"
}

mvr() {
    rsync --archive -hh --partial --info=stats1,progress2 --modify-window=1 --remove-source-files "$@"
}

aliases() {
    "$EDITOR" "$ZDOTDIR/zsh-aliases.zsh"
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

sudoalias() {
    alias "$1"="$sudo $1"
}

sudoalias apk
sudoalias pacman
sudoalias dmesg

unset -f sudoalias
unset sudo

alias code="code-oss"
alias ncmp="ncmpcpp"
alias grep="grep --color"
alias less="$PAGER"
alias la="ls -A"
alias ll="ls -al"
alias ls="ls --color -Fh"
alias mime="file -Lb --mime-type"
alias trash="gio trash"
