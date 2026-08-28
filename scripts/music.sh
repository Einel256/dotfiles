#!/bin/bash

pidfile="/tmp/music_script.pid"
if [ -f "$pidfile" ] && kill -0 $(cat "$pidfile") 2>/dev/null; then
    exit 0
fi
echo $$ > "$pidfile"
trap 'rm -f "$pidfile"' EXIT

hyprctl clients -j \
| jq -r '.[] | select(.workspace.id == 2 and (.class | test("^dash-"))) | .address' \
| while read addr; do
    hyprctl dispatch closewindow address:$addr
done

systemctl --user start mpd
mpc play > /dev/null 2>&1

kitty --class dash-rmpc -e rmpc &
kitty --class dash-matrix -e cmatrix &
kitty --class dash-pomo    -e pomo &
kitty --class dash-cava -e cava &
kitty --class dash-yazi    -e yazi &
kitty --class dash-clock -e tty-clock &
