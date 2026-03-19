#!/usr/bin/env bash

FILE=$1

if [ -z "$FILE" ]; then
  echo "You must supply a script name"
  exit 1
fi

SCRIPT_NAME="${FILE}.sh"
touch "$SCRIPT_NAME"
chmod +x "$SCRIPT_NAME"

cat > "$SCRIPT_NAME" << 'TEMPLATE'
#!/usr/bin/env bash

set -Eeuo pipefail

readonly dir="$(dirname "$0")"

usage() {
  cat >&2 <<USAGE
Usage: $(basename "$0") [OPTIONS]

Description:
  <describe what this script does>

Options:
  -v        Enable verbose output
  -d        Enable debug mode
  -h        Show this help message
USAGE
  exit 1
}

verbose=""
debug=""

while getopts "hvd" OPT; do
  case "${OPT}" in
    h) usage ;;
    v) verbose=true ;;
    d) debug=true ;;
    *) usage ;;
  esac
done
shift $((OPTIND - 1))

if [ $# -lt 1 ]; then
  usage
fi

main() {
  if [ "$verbose" = "true" ]; then
    echo "Verbose mode enabled"
  fi

  echo "Hello from $0"
}

main "$@"
TEMPLATE
