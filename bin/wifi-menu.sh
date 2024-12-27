#!/bin/bash

dir="$HOME/.config/rofi/launchers/type-1"
theme='style-5'

# Check if Wi-Fi is enabled
wifi_status=$(nmcli radio wifi)
if [ "$wifi_status" = "disabled" ]; then
  notify-send "Wi-Fi is disabled. Enabling it..."
  nmcli radio wifi on
  sleep 2
fi

# Get a list of Wi-Fi networks
networks=$(nmcli -f SSID,SECURITY,SIGNAL dev wifi list | tail -n +2 | awk '{print $1}')

# Use rofi to display the list of networks
selected_network=$(echo "$networks" | rofi -dmenu -p "Select Wi-Fi" -theme ${dir}/${theme}.rasi)

# If a network is selected, ask for a password (if required) and connect
if [ -n "$selected_network" ]; then
  password=$(rofi -dmenu -p "Enter password for $selected_network")
  if [ -n "$password" ]; then
    nmcli dev wifi connect "$selected_network" password "$password"
    notify-send "Connecting to $selected_network..."
  else
    nmcli dev wifi connect "$selected_network"
    notify-send "Connecting to $selected_network..."
  fi
fi
