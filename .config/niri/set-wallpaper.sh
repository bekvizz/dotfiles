#!/usr/bin/env bash
set -Eeuo pipefail

wal_dir="${PYWAL_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/wal}"
wallpaper_dir="$HOME/Pictures/Wallpapers"
DEFAULT_WALLPAPER="$wallpaper_dir/eepy_pony.png"

usage() {
    printf 'Usage: %s [wallpaper-path | --next | --prev]\n' "${0##*/}"
    printf 'Pass an image to generate a new Pywal16 palette and apply it.\n'
    printf 'Cycle through images in %s with --next or --prev.\n' "$wallpaper_dir"
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

# Serialize selection and application so rapid key presses advance in order.
mkdir -p -- "$wal_dir"
exec 9< "$wal_dir"
flock 9
cached_wallpaper=""
if [[ -r "$wal_dir/wal" ]]; then
    cached_wallpaper=$(< "$wal_dir/wal")
fi

cycle_wallpaper() {
    local LC_ALL=C
    local direction=$1 candidate i index
    local -a images=()
    shopt -s nullglob nocasematch
    for candidate in "$wallpaper_dir"/*; do
        [[ -f $candidate && -r $candidate ]] || continue
        case "$candidate" in
            *.jpg|*.jpeg|*.png|*.webp|*.bmp|*.tif|*.tiff|*.avif) images+=("$candidate") ;;
        esac
    done
    if (( ${#images[@]} == 0 )); then
        printf 'No supported images found in %s\n' "$wallpaper_dir" >&2
        return 1
    fi

    index=0
    if (( direction < 0 )); then index=$(( ${#images[@]} - 1 )); fi
    for i in "${!images[@]}"; do
        if [[ ${images[i]} -ef $cached_wallpaper ]]; then
            index=$(( (i + direction + ${#images[@]}) % ${#images[@]} ))
            break
        fi
    done
    wallpaper=${images[index]}
}

restore_palette=false

if [[ ${1:-} == --next ]]; then
    cycle_wallpaper 1
elif [[ ${1:-} == --prev ]]; then
    cycle_wallpaper -1
elif (( $# == 1 )); then
    wallpaper=$1

    # Expand a leading ~/ even when the argument was quoted by the caller.
    case "$wallpaper" in
        \~/*) wallpaper="$HOME/${wallpaper#\~/}" ;;
    esac
else
    if [[ -f $cached_wallpaper ]]; then
        wallpaper=$cached_wallpaper
        restore_palette=true
    else
        wallpaper=$DEFAULT_WALLPAPER
    fi
fi

if [[ ! -f "$wallpaper" ]]; then
    printf 'Error: wallpaper file does not exist: %s\n' "$wallpaper" >&2
    exit 1
fi

if [[ "$restore_palette" == true ]]; then
    wal -R -n 9<&-
else
    # Generate the palette without letting Pywal16 manage the wallpaper.
    wal -i "$wallpaper" -n 9<&-
fi

# Niri uses swaybg for the actual background, independently of Pywal16.
pkill -u "$UID" -x swaybg 2>/dev/null || true
swaybg -m fill -i "$wallpaper" 9<&- >/dev/null 2>&1 &

# Publish a fixed-aspect thumbnail only after the image is completely encoded.
# ImageMagick reads the first frame from stdin so filenames are treated literally.
thumbnail="$wal_dir/waybar-wallpaper.png"
write_thumbnail() (
    tmp=$(mktemp -- "$wal_dir/.waybar-preview.XXXXXXXX") || return 1
    trap 'rm -f -- "$tmp"' EXIT
    magick '-[0]' -auto-orient -thumbnail '156x66^' -gravity center \
        -extent 156x66 +repage -strip png:- < "$wallpaper" > "$tmp" || return 1
    mv -fT -- "$tmp" "$thumbnail"
)

if ! write_thumbnail; then
    rm -f -- "$thumbnail"
    printf 'Could not generate a Waybar preview for %s\n' "$wallpaper" >&2
fi
# A Pywal reload can happen before the thumbnail is ready.
pkill -RTMIN+7 -u "$UID" -x waybar 2>/dev/null || true

# Waybar watches imported CSS files (reload_style_on_change is enabled).
# SwayNC needs an explicit stylesheet reload after its imported CSS changes.
if command -v swaync-client >/dev/null 2>&1 && pgrep -x swaync >/dev/null 2>&1; then
    swaync-client -rs 9<&- >/dev/null 2>&1 || true
fi

printf 'Wallpaper and Pywal16 colors updated: %s\n' "$wallpaper"
