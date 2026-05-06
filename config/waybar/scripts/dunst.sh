#!/bin/bash
paused=$(dunstctl is-paused)
if [ "$paused" = "true" ]; then
  echo ' <span class="paused"></span>'
else
  echo ''
fi
