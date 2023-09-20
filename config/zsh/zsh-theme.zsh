fgesc="\033]10;#%s\007"
bgesc="\033]11;#%s\007"
curesc="\033]12;#%s\007"
colesc="\033]4;%d;#%s\007"
hfgesc="\033]19;#%s\007"
hbgesc="\033]17;#%s\007"

colesc_l="\033]P%s%s"
hex_array=({0..9} {A..F})

apply_foot_theme() {
    local group
    while IFS= read -r line
    do
        if [ -z "$line" ]; then continue; fi
        if [ "$line" = "[colors]" ]; then
            group="colors"
            continue
        elif [ "$line" = "[cursor]" ]; then
            group="cursor"
            continue
        elif [ "$line" = "[main]" ]; then
            group="main"
            continue
        elif [[ "$line" = "["*"]" ]]; then
            group="unknown"
            continue
        fi
        line="$(echo "$line" | sed "s/ = /=/g")"
        if [[ "$group" = main && "$line" = "include="* ]]; then
            eval "local $line"
            apply_foot_theme "$include"
            continue
        fi
        if [[ "$group" = cursor && "$line" = "color="* ]]; then
            cursor="$(echo "$line" | sed 's/color=[0-9a-fA-F]\{6\}\ //g')"
            continue
        fi
        if [ "$group" = colors ]; then
            if [[ "$line" = "selection-background="* ]]; then
                selection_background="$(echo "$line" | cut -c 22-)"
            elif [[ "$line" = "selection-foreground="* ]]; then          
                selection_foreground="$(echo "$line" | cut -c 22-)"
            elif [[ "$line" != *-* ]]; then
                eval "local $line"
            fi
            continue
        fi
    done < "$1"
    if [ "$TERM" = foot ]; then
        for i in {0..15}
        do
            var="regular$i"
            if [ $i -gt 7 ]; then
                var="bright$(($i - 8))"
            fi
            if [ ! -z ${(P)var} ]; then
                printf "$colesc" "$i" "${(P)var}"
            fi
        done
        
        if [ ! -z ${background} ]; then
            printf "$bgesc" "${background}"
        fi
        if [ ! -z ${foreground} ]; then
            printf "$fgesc" "${foreground}"
        fi
        if [ ! -z ${selection_background} ]; then
            printf "$hbgesc" "${selection_background}"
        fi
        if [ ! -z ${selection_foreground} ]; then
            printf "$hfgesc" "${selection_foreground}"
        fi
        if [ ! -z ${cursor} ]; then
            printf "$curesc" "${cursor}"
        fi
    elif [ "$TERM" = linux ]; then        
        for i in {0..15}
        do
            var="regular$i"
            if [ $i -gt 7 ]; then
                var="bright$(($i - 8))"
            fi
            if [ ! -z ${(P)var} ]; then
                printf "$colesc_l" "${hex_array[(($i + 1))]}" "${(P)var}"
            fi
        done
        if [ ! -z ${background} ]; then
            printf "$colesc_l" 0 "${background}"
        fi
        if [ ! -z ${foreground} ]; then
            printf "$colesc_l" F "${foreground}"
        fi
        clear
    fi
}

apply_theme() {
    if [[ "$TERM" = foot || "$TERM" = linux ]]; then
        [ "$TERM" = foot ] && echo -en "\e]112"
        apply_foot_theme "$XDG_CONFIG_HOME/foot/foot.ini"
    fi
}
