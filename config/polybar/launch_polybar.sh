#!/bin/bash

# Terminate already running bar instances
killall -q polybar

# Wait until processes have shut down
while pgrep -x polybar >/dev/null; do sleep 1; done

# Launch top bar on each connected monitor
if type "xrandr" > /dev/null 2>&1; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar --reload top --config=~/.config/polybar/config.ini &
  done
else
  polybar --reload top --config=~/.config/polybar/config.ini &
fi
