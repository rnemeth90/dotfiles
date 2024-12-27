#!/bin/sh

# Check if Bluetooth is powered on
if bluetoothctl show | grep -q "Powered: yes"; then
  if bluetoothctl info | grep -q 'Device'; then
    # Device connected
    echo "%{T0}%{F#2193ff}%{T-}" # Use font-0 (Hack Nerd Font)
  else
    # No device connected
    echo "%{T0}%{T-}"
  fi
else
  # Bluetooth powered off
  echo "%{T0}%{F#66ffffff}%{T-}"
fi
