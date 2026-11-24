#!/usr/bin/env bash
set -eu

# Keep the watcher and picker on the same per-user runtime database.
runtime=${XDG_RUNTIME_DIR:?Clipboard history needs a user runtime directory}
db="$runtime/cliphist/db"
umask 077

case "${1:-}" in
    watch)
        exec wl-paste --watch cliphist -db-path "$db" store
        ;;
    pick)
        selection=$(cliphist -db-path "$db" list |
            wofi --dmenu --prompt Clipboard --cache-file "$runtime/wofi-clipboard" \
                --define allow_markup=false --define allow_images=false) || exit
        [[ -n $selection ]] || exit 0
        printf '%s\n' "$selection" | cliphist -db-path "$db" decode | wl-copy
        ;;
    *)
        printf 'Usage: %s {watch|pick}\n' "${0##*/}" >&2
        exit 2
        ;;
esac
