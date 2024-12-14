#!/bin/bash

# Path to the keymaps.lua file
KEYMAPS_FILE="$HOME/.config/nvim/lua/user/keymaps.lua"

# Check if the file exists
if [[ ! -f "$KEYMAPS_FILE" ]]; then
  echo "Error: $KEYMAPS_FILE not found."
  exit 1
fi

# Temporary files for grouping keymaps by mode
TEMP_FILE=$(mktemp)
TEMP_FILE_N=$(mktemp)
TEMP_FILE_I=$(mktemp)
TEMP_FILE_V=$(mktemp)

# Parse keymaps.lua
echo "Parsing keymaps from $KEYMAPS_FILE..."
while IFS= read -r line; do
  # Extract mode, lhs, rhs, and desc
  if [[ "$line" =~ keymap\(\"([a-z]+)\"\,\s*\"([^\"]+)\"\,\s*\"([^\"]+)\"\,\s*\"([^\"]*)\" ]]; then
    mode="${BASH_REMATCH[1]}"
    lhs="${BASH_REMATCH[2]}"
    rhs="${BASH_REMATCH[3]}"
    desc="${BASH_REMATCH[4]}"
    desc="${desc:-No description}"

    # Append to the appropriate temporary file based on mode
    case "$mode" in
      n) echo "  $lhs -> $rhs ($desc)" >> "$TEMP_FILE_N" ;;
      i) echo "  $lhs -> $rhs ($desc)" >> "$TEMP_FILE_I" ;;
      v) echo "  $lhs -> $rhs ($desc)" >> "$TEMP_FILE_V" ;;
      *) echo "  $lhs -> $rhs ($desc)" >> "$TEMP_FILE" ;; # Catch-all for other modes
    esac
  fi
done < "$KEYMAPS_FILE"

# Display grouped keymaps
if [[ -s "$TEMP_FILE_N" ]]; then
  echo "Mode: n (Normal)"
  cat "$TEMP_FILE_N"
  echo
fi

if [[ -s "$TEMP_FILE_I" ]]; then
  echo "Mode: i (Insert)"
  cat "$TEMP_FILE_I"
  echo
fi

if [[ -s "$TEMP_FILE_V" ]]; then
  echo "Mode: v (Visual)"
  cat "$TEMP_FILE_V"
  echo
fi

if [[ -s "$TEMP_FILE" ]]; then
  echo "Other Modes:"
  cat "$TEMP_FILE"
  echo
fi

# Clean up temporary files
rm -f "$TEMP_FILE" "$TEMP_FILE_N" "$TEMP_FILE_I" "$TEMP_FILE_V"
