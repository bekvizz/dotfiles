#!/usr/bin/env bash

entries="󰌾 Lock\n󰍃 Log Out\n󰒲 Suspend\n󰜉 Reboot\n󰐥 Power Off"

selected=$(echo -e "$entries" | wofi --dmenu --prompt "Power Menu" --width 540 --height 390)

case "$selected" in
  *"Lock")
    "$HOME/.config/niri/lock.sh"
    ;;
  *"Log Out")
    niri msg action quit
    ;;
  *"Suspend")
    systemctl suspend
    ;;
  *"Reboot")
    systemctl reboot
    ;;
  *"Power Off")
    systemctl poweroff
    ;;
esac
