#!/bin/bash

# Source the Pywal colors
source "$HOME/.cache/wal/colors.sh"

# Strip the '#' from the variables for swaylock
BG="${background:1}"
RING="${color5:1}"
INSIDE="${background:1}"
HL="${color4:1}"
TEXT="${foreground:1}"
WRONG="${color1:1}"

# Run swaylock with dynamic colors
swaylock \
    --color "$BG" \
    --inside-color "$INSIDE" \
    --ring-color "$RING" \
    --key-hl-color "$HL" \
    --line-color "$BG" \
    --text-color "$TEXT" \
    --inside-clear-color "$INSIDE" \
    --ring-clear-color "$color3:1" \
    --inside-wrong-color "$INSIDE" \
    --ring-wrong-color "$WRONG" \
    --indicator-radius 100 \
    --indicator-thickness 7
