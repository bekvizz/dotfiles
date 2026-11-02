#!/usr/bin/env bash
set -Eeuo pipefail

WAL_CACHE="$HOME/.cache/wal/wal"
DEFAULT_WALLPAPER="$HOME/Pictures/wallpapers/eepy_pony.png"

usage() {
    printf 'Usage: %s [wallpaper-path]\n' "${0##*/}"
    printf 'Pass an image to generate a new Pywal16 palette and apply it.\n'
    printf 'Run without arguments to restore the last selected wallpaper.\n'
}

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
    usage
    exit 0
fi

if (( $# > 1 )); then
    usage >&2
    exit 2
fi

for cmd in wal swaybg pkill; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        printf 'Error: required command not found: %s\n' "$cmd" >&2
        exit 1
    fi
done

restore_palette=false

if (( $# == 1 )); then
    wallpaper=$1

    # Expand a leading ~/ even when the argument was quoted by the caller.
    case "$wallpaper" in
        \~/*) wallpaper="$HOME/${wallpaper#\~/}" ;;
    esac
else
    wallpaper=""

    if [[ -r "$WAL_CACHE" ]]; then
        IFS= read -r cached_wallpaper < "$WAL_CACHE" || true
        if [[ -n ${cached_wallpaper:-} && -f $cached_wallpaper ]]; then
            wallpaper=$cached_wallpaper
            restore_palette=true
        fi
    fi

    # First launch, or the previously selected image is no longer available.
    if [[ -z "$wallpaper" ]]; then
        wallpaper=$DEFAULT_WALLPAPER
    fi
fi

if [[ ! -f "$wallpaper" ]]; then
    printf 'Error: wallpaper file does not exist: %s\n' "$wallpaper" >&2
    exit 1
fi

if [[ "$restore_palette" == true ]]; then
    wal -R
else
    # Generate the palette without letting Pywal16 manage the wallpaper.
    wal -i "$wallpaper" -n
fi

# Niri uses swaybg for the actual background, independently of Pywal16.
pkill -x swaybg 2>/dev/null || true
swaybg -m fill -i "$wallpaper" >/dev/null 2>&1 &

# Waybar watches imported CSS files (reload_style_on_change is enabled).
# SwayNC needs an explicit stylesheet reload after its imported CSS changes.
if command -v swaync-client >/dev/null 2>&1 && pgrep -x swaync >/dev/null 2>&1; then
    swaync-client -rs >/dev/null 2>&1 || true
fi

printf 'Wallpaper and Pywal16 colors updated: %s\n' "$wallpaper"
