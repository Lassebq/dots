if [ "$TERM" = linux ]; then
    setfont # Clear font
    echo -en "\e]R" # Clear custom colors
    clear
fi
