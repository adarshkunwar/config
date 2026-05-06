#!/bin/bash
choice=$(printf "  shutdown\n  reboot\n  logout\n  cancel" | wofi --dmenu --prompt "" --width 200 --height 160 --hide-scroll --no-actions --insensitive)
case "$choice" in
  "  shutdown") systemctl poweroff ;;
  "  reboot")   systemctl reboot ;;
  "  logout")   hyprctl dispatch exit ;;
esac
