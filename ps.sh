#!/bin/bash

export DISPLAY=:0
export XAUTHORITY=/home/gato/.Xauthority

APP="/home/gato/Downloads/PPSSPP-v1.19.3-anylinux-aarch64.AppImage"

if pgrep -f PPSSPP >/dev/null; then
    echo "PPSSPP already running"
    exit 0
fi

chmod +x "$APP"
"$APP" &
