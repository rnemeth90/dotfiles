#!/bin/bash

declare DOT=$HOME/dotfiles

cd "$(dirname "${BASH_SOURCE[0]}")" &&
  source "$DOT/utils/utils.sh"

create_bash_local() {
  local -r FILE_PATH="$HOME/.bash.local"
  local DOTFILES_BIN_DIR="${DOTFILES_BIN_DIR:-$(dirname "$(pwd)")/bin}"

  if [ -f "$FILE_PATH" ] && grep -q "$DOTFILES_BIN_DIR" "$FILE_PATH"; then
    print_in_yellow "\n [✔] $FILE_PATH already exists and is correctly configured. Skipping...\n"
    return
  fi

  print_in_purple "\n • Creating or updating $FILE_PATH \n\n"

  {
    printf "%s\n" \
      "#!/bin/bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Set PATH additions and anything else you don't want source controlled
PATH=\"$DOTFILES_BIN_DIR:\$PATH\"
export PATH

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
"
  } >>"$FILE_PATH"

  if [ $? -eq 0 ]; then
    print_in_green "\n [✔] Successfully created or updated $FILE_PATH\n"
  else
    print_in_red "\n [✖] Failed to create or update $FILE_PATH\n"
    exit 1
  fi
}

main() {
  print_in_purple "\n • Create local bash config\n\n"
  create_bash_local
}

main

