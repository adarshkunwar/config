#!/usr/bin/env bash

# Always use explicit host/port
mpc_cmd="mpc --host=127.0.0.1 --port=6600"

# Get current song
song=$($mpc_cmd current)
[ -z "$song" ] && echo "MPD offline" && exit 0

# Get elapsed / total times
times=$($mpc_cmd status | grep -oP '\d+:\d+(?::\d+)? / \d+:\d+(?::\d+)?' | head -1)
[ -z "$times" ] && echo "$song (offline)" && exit 0

elapsed_str=$(echo "$times" | awk '{print $1}')
total_str=$(echo "$times" | awk '{print $3}')

# Convert MM:SS or HH:MM:SS to seconds
time_to_sec() {
    IFS=: read -r h m s <<< "$1"
    if [ -z "$s" ]; then
        # MM:SS format
        s=$m
        m=$h
        h=0
    fi
    echo $((h*3600 + m*60 + s))
}

elapsed=$(time_to_sec "$elapsed_str")
total=$(time_to_sec "$total_str")

# Convert seconds to HH:MM:SS
sec2hms() {
    printf "%02d:%02d:%02d" $(( $1/3600 )) $(( ($1/60)%60 )) $(( $1%60 ))
}

# Play/pause icons
state=$($mpc_cmd status | grep -oP '\[(playing|paused)\]' | tr -d '[]')
icon_play=""
icon_pause=""
[ "$state" == "playing" ] && icon="$icon_play"
[ "$state" == "paused" ] && icon="$icon_pause"

# Output for Polybar
echo "$icon $song $(sec2hms $elapsed) / $(sec2hms $total)"
