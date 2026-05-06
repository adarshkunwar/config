#!/bin/bash
status=$(mpc status 2>/dev/null | grep -o '\[.*\]' | tr -d '[]')
case "$status" in
  playing) echo "" ;;
  paused)  echo "" ;;
  *)       echo "" ;;
esac
