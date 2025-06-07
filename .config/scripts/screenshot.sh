#!/bin/bash

# Configuration
output_dir="$HOME/Pictures/Screenshots"
mkdir -p "$output_dir"
filename="$output_dir/screenshot_$(date +%Y%m%d_%H%M%S).png"
sound_path="/usr/share/sounds/freedesktop/stereo/camera-shutter.oga"

# Required commands
required_cmds=(grim slurp notify-send mktemp)

# Check dependencies
for cmd in "${required_cmds[@]}"; do
    command -v "$cmd" &>/dev/null || {
        notify-send "❌ Screenshot Error" "Missing command: $cmd"
        exit 1
    }
done

# Check environment
if [[ -z "$WAYLAND_DISPLAY" ]]; then
    notify-send "❌ Screenshot Error" "Not in a Wayland session."
    exit 1
fi

take_screenshot() {
    local mode="$1"
    local tmp
    tmp=$(mktemp) || {
        notify-send "❌ Screenshot Error" "Failed to create temp file."
        exit 1
    }

    case "$mode" in
        area) grim -g "$(slurp)" "$tmp" ;;
        full) grim "$tmp" ;;
        *)
            notify-send "❌ Screenshot Error" "Invalid mode: $mode"
            rm -f "$tmp"
            exit 1
            ;;
    esac

    if [[ -s "$tmp" ]]; then
        mv "$tmp" "$filename"

        # Optional sound
        if command -v paplay &>/dev/null && [[ -f "$sound_path" ]]; then
            paplay "$sound_path" &>/dev/null
        fi

        notify-send -i "$filename" "📸 Screenshot taken" "Saved as $filename"
    else
        rm -f "$tmp"
        notify-send "❌ Screenshot cancelled"
    fi
}

# Prevent multiple instances
(
    flock -n 9 || {
        notify-send "⚠️ Screenshot already in progress"
        exit 1
    }
    take_screenshot "$1"
) 9>/tmp/screenshot.lock