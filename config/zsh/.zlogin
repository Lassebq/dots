source ~/.profile

if [[ "$-" = *i* ]] && [ "$TERM" = linux ] && [ -z "$TWDISPLAY" ]; then
    font="/usr/share/kbd/consolefonts/Unifont-APL8x16.psf.gz"
    if [ -f "$font" ]; then
        setfont "$font"
    fi
fi

if [[ "$-" = *i* ]] && [ "$TERM" = linux ]; then
    #tmux
    #exit
fi
