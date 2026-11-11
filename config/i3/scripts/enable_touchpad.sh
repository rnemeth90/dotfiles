#!/bin/sh

devices=$(xinput list --name-only) || exit 1
printf '%s\n' "$devices" | while IFS= read -r device; do
    case "$device" in
        '∼ '*)
            device=${device#∼ }
            ;;
    esac

    case "$device" in
        *Touchpad*)
            xinput reattach "$device" 'Virtual core pointer' || exit 1
            xinput enable "$device" || exit 1
            properties=$(xinput list-props "$device") || exit 1
            if printf '%s\n' "$properties" | grep -Fq 'libinput Tapping Enabled ('; then
                xinput set-prop "$device" 'libinput Tapping Enabled' 1 || exit 1
            fi
            if printf '%s\n' "$properties" | grep -Fq 'libinput Tapping Drag Enabled ('; then
                xinput set-prop "$device" 'libinput Tapping Drag Enabled' 1 || exit 1
            fi
            if printf '%s\n' "$properties" | grep -Fq 'libinput Click Method Enabled ('; then
                xinput set-prop "$device" 'libinput Click Method Enabled' 0 1 || exit 1
            fi
            ;;
    esac
done
