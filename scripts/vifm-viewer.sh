#!/usr/bin/env bash
readonly ID_PREVIEW="vifm-preview"

if [ -e "$FIFO_UEBERZUG" ]; then
    if [[ "$1" == "draw" ]]; then
        declare -p -A cmd=([action]=add [identifier]="$ID_PREVIEW"
                           [x]="$2" [y]="$3" [width]="$4" [height]="$5" \
                           [path]="${PWD}/$6") \
            > "$FIFO_UEBERZUG"
    elif [[ "$1" == "videopreview" ]]; then
        [[ ! -f "/tmp/$6.png" ]] && ffmpegthumbnailer -i "${PWD}/$6" -o "/tmp/$6.png" -s 0 -q 10
        declare -p -A cmd=([action]=add [identifier]="$ID_PREVIEW"
           [x]="$2" [y]="$3" [width]="$4" [height]="$5" \
           [path]="/tmp/$6.png") \
        > "$FIFO_UEBERZUG"
    elif [[ "$1" == "clear" ]]; then
        declare -p -A cmd=([action]=remove [identifier]="$ID_PREVIEW") \
            > "$FIFO_UEBERZUG"
    fi
fi
