#!/bin/sh

set_nvim_theme() {
    if pidof nvim > /dev/null 2> /dev/null; then
        ls "$XDG_RUNTIME_DIR"/nvim.*.0 \
            | xargs -I {} nvim --server {} --remote-send "<cmd>colorscheme $1<CR>" > /dev/null
    fi
    echo "vim.cmd.colorscheme \"$1\"" > "$XDG_CONFIG_HOME/nvim/lua/theme.lua"
}
