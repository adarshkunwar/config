#!/usr/bin/env bash

if dunstctl is-paused | grep -q true; then
    echo "󰂛  DND"
else
    echo "󰂚  ON"
fi
