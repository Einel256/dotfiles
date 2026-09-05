#!/bin/bash

hyprctl clients -j \
| jq -r '.[] | select(.workspace.id == 3 and (.class | test("^dash2-"))) | .address' \
| while read addr; do
    hyprctl dispatch closewindow address:$addr
done

kitty --class dash2-tdf -d /home/einel256/ &
kitty --class dash2-matrix -e cmatrix -C blue &
kitty --class dash2-pomo    -e pomo &
kitty --class dash2-clock   -e cmatrix -C blue &

