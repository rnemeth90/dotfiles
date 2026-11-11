#!/bin/sh

if command -v betterlockscreen >/dev/null 2>&1; then
    exec betterlockscreen -l dimblur
elif command -v i3lock >/dev/null 2>&1; then
    exec i3lock
else
    printf '%s\n' "No supported screen locker found (install betterlockscreen or i3lock)." >&2
    exit 127
fi
