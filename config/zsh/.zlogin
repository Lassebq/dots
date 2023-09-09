if [ "$TERM" = linux ]; then
    if [ -f /usr/share/kbd/consolefonts/ter-118b.psf.gz ]; then
        setfont /usr/share/kbd/consolefonts/ter-118b.psf.gz
    fi
fi
