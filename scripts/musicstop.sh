#!/usr/bin/env bash

mpc stop >/dev/null 2>&1
systemctl --user stop mpd

# Hyprland の UNIX ソケットパスを取得
HYPR_SOCK="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket.sock"

# dash- から始まるクラスのウィンドウアドレスを取得してソケットに直接送る
hyprctl clients -j \
| jq -r '.[] | select(.class | test("^dash-")) | .address' \
| while read -r addr; do
    if [ -S "$HYPR_SOCK" ]; then
        # Lua ラッパーを通さず、Hyprland 本体に直接 dispatch 命令を叩き込む
        printf "dispatch closewindow address:%s" "$addr" | socat - UNIX-CONNECT:"$HYPR_SOCK" >/dev/null 2>&1
    fi
done

# （万が一ソケット経由で閉じなかった場合のフォールバック: プロセス名で殺す）
pkill -f "dash-rmpc|dash-clock|dash-pomo|dash-matrix|dash-btop|dash-cava|dash-yazi|dash2-tdf|dash2-clock|dash2-pomo|dash2-matrix" >/dev/null 2>&1
