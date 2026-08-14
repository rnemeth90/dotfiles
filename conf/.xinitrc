#!/bin/sh

# Merge X resources
[ -f ~/.Xresources ] && xrdb -merge ~/.Xresources

# Keyboard: 200ms delay, 40 repeats/sec
xset r rate 200 40

# Disable screen blanking and DPMS (managed by betterlockscreen/xss-lock instead)
xset s off
xset -dpms

# Set cursor
xsetroot -cursor_name left_ptr

# Start dbus if not already running
export $(dbus-launch)

exec i3
