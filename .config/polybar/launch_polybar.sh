#!/bin/bash

# terminate already running bar instances
killall -q polybar

# wait until the processes have been shut down
while pgrep -x polybar >/dev/null; do sleep 1; done

# setup monitors and launch polybar
if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar --reload top --config=~/.config/polybar/config.ini &
  done
else
  polybar --reload top --config=~/.config/polybar/config.ini &
fi
