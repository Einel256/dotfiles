#!/bin/bash

hyprctl clients -j \
| jq -r '.[] | select(.workspace.id == 3 and (.class | test("^dash2-"))) | .address' \
| while read addr; do
    hyprctl dispatch closewindow address:$addr
done

kitty --class dash2-tdf -d ~/Downloads -e tdf -r "II_第6章_微分法_練習解答.pdf" &
kitty --class dash2-matrix -e cmatrix &
kitty --class dash2-pomo    -e pomo &
kitty --class dash2-clock   -e tty-clock &

