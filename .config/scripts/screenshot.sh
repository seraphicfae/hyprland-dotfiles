#!/bin/bash

mkdir -p "$HOME/Pictures/Screenshots"
filename="$HOME/Pictures/Screenshots/screenshot_$(date +%Y%m%d_%H%M%S).png"
lockfile="/tmp/screenshot.lock"

# Prevent multiple screenshots
if [[ -f "$lockfile" ]]; then
    notify-send " Screenshot in progress"
    exit 1
fi

touch "$lockfile"
trap 'rm -f "$lockfile"' EXIT

# Actual logic
take_screenshot() {
    case "$1" in
        area) grim -g "$(slurp)" "$filename" ;;
        full) grim "$filename" ;;
        *) exit 1 ;;
    esac

    if [[ -s "$filename" ]]; then
        wl-copy < "$filename"
        paplay "/usr/share/sounds/freedesktop/stereo/camera-shutter.oga"

        notify-send -i "$filename" "󰄀 Screenshot taken" "Saved as $(basename "$filename") and copied to clipboard"
    else
        notify-send " Screenshot cancelled"
    fi
}

take_screenshot "$1"