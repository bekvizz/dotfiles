#!/usr/bin/env bash

cache="${XDG_CACHE_HOME:-$HOME/.cache}/wal"
# The plain palette contains one color per line. Accept only six hex digits.
palette=()
if [[ -f "$cache/colors" && -r "$cache/colors" ]]; then
    mapfile -t -n 16 palette < "$cache/colors"
fi

color() {
    local value=${palette[$1]:-}
    if [[ $value =~ ^#([[:xdigit:]]{6})$ ]]; then
        printf '%s' "${BASH_REMATCH[1]}"
    else
        printf '%s' "$2"
    fi
}

BG=$(color 0 1a1b26)
FG=$(color 15 c0caf5)
ACCENT=$(color 5 bb9af7)
RING=$(color 8 565f89)
KEY_HL=$(color 2 9ece6a)
BS_HL=$(color 1 f7768e)
CLEAR=$(color 3 e0af68)
WRONG=$BS_HL

image_args=()
if [[ -f "$cache/wal" && -r "$cache/wal" ]]; then
    wallpaper=$(< "$cache/wal")
    if [[ $wallpaper == /* && -f $wallpaper ]] && exec 3< "$wallpaper"; then
        # swaylock-effects expands image paths. Give it only a fixed descriptor path.
        image_args=(--image /proc/self/fd/3 --effect-blur 7x5 --effect-vignette 0.5:0.5)
    fi
fi

fade_args=()
if [[ ${1:-} == --fade ]]; then
    fade_args=(--fade-in 0.2)
fi

exec swaylock \
    "${fade_args[@]}" \
    --daemonize \
    --color "$BG" \
    "${image_args[@]}" \
    --clock \
    --timestr "%H:%M" \
    --datestr "%a, %d %b" \
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
