#!/usr/bin/env bash

# Source dynamic colors from Pywal
if [ -f "$HOME/.cache/wal/colors.sh" ]; then
    . "$HOME/.cache/wal/colors.sh"
fi

# Fetch current wallpaper path from Pywal cache
if [ -f "$HOME/.cache/wal/wal" ]; then
    WALLPAPER="$(cat "$HOME/.cache/wal/wal")"
fi

# Helper to remove leading '#' from hex codes for swaylock
hex() {
    echo "${1#\#}"
}

BG=$(hex "$background")
FG=$(hex "$foreground")
ACCENT=$(hex "$color5")
RING=$(hex "$color8")       # Uses muted secondary dark color for the ring track
KEY_HL=$(hex "$color2")     # Bright accent (or use $(hex "$foreground")) for keystrokes
BS_HL=$(hex "$color1")      # Red for backspace
CLEAR=$(hex "$color3")
WRONG=$(hex "$color1")

# Launch swaylock-effects with blurred wallpaper and pywal palette
swaylock \
    --daemonize \
    --image "$WALLPAPER" \
    --effect-blur 7x5 \
    --effect-vignette 0.5:0.5 \
    --fade-in 0.2 \
    --clock \
    --timestr "%H:%M" \
    --datestr "%A, %d %B" \
    --font "JetBrainsMono Nerd Font" \
    --indicator \
    --indicator-radius 100 \
    --indicator-thickness 7 \
    --indicator-idle-visible \
    --inside-color "${BG}88" \
    --inside-clear-color "${CLEAR}88" \
    --inside-ver-color "${ACCENT}88" \
    --inside-wrong-color "${WRONG}88" \
    --ring-color "$RING" \
    --ring-clear-color "$CLEAR" \
    --ring-ver-color "$ACCENT" \
    --ring-wrong-color "$WRONG" \
    --key-hl-color "$KEY_HL" \
    --line-color 00000000 \
    --separator-color 00000000 \
    --text-color "$FG" \
    --text-clear-color "$BG" \
    --text-ver-color "$BG" \
    --bs-hl-color "$BS_HL" \
    --text-wrong-color "$BG"
