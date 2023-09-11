if [ "$TERM" = linux ]; then
    font="/usr/share/kbd/consolefonts/Unifont-APL8x16.psf.gz"
    if [ -f "$font" ]; then
        setfont "$font"
    fi
    if command -v fetch &> /dev/null; then fetch; fi
fi
