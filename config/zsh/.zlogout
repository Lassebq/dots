if [[ "$-" = *i* ]] && [ "$TERM" = linux ] && [ -z "$TWDISPLAY" ]; then
    setfont # Clear font
    echo -en "\e]R" # Clear custom colors
    clear
fi
