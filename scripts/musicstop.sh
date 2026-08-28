#!/usr/bin/env bash

mpc stop >/dev/null 2>&1
systemctl --user stop mpd

HYPR_SOCK="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket.sock"

hyprctl clients -j \
| jq -r '.[] | select(.class | test("^dash-")) | .address' \
| while read -r addr; do
    if [ -S "$HYPR_SOCK" ]; then
    
        printf "dispatch closewindow address:%s" "$addr" | socat - UNIX-CONNECT:"$HYPR_SOCK" >/dev/null 2>&1
    fi
done

pkill -f "dash-rmpc|dash-clock|dash-pomo|dash-matrix|dash-btop|dash-cava|dash-yazi|dash2-tdf|dash2-clock|dash2-pomo|dash2-matrix" >/dev/null 2>&1
