#!/bin/bash

# terminate already running bar instances
killall -q polybar

# wait until the processes have been shut down
while pgrep -x polybar >/dev/null; do sleep 1; done

# launch a top and bottom bar on each connected monitor
if type "xrandr" > /dev/null 2>&1; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar --reload top --config=~/.config/polybar/config.ini &
    MONITOR=$m polybar --reload bottom --config=~/.config/polybar/config.ini &
  done
else
  polybar --reload top --config=~/.config/polybar/config.ini &
  polybar --reload bottom --config=~/.config/polybar/config.ini &
fi
