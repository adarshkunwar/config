#!/bin/bash

if ! bluetoothctl show | grep -q "Powered: yes"; then
    echo "󰂲"
    exit
fi

device=$(bluetoothctl devices Connected | head -n1)
battery=$(bluetoothctl info | awk '/Battery Percentage:/{print $NF}')

if [ -n "$device" ]; then
    name=$(echo "$device" | cut -d' ' -f3-)
    echo "󰂱 $name $battery"
else
    echo "󰂯"
fi
