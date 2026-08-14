#!/bin/bash

# ─────────────────────────────────────────────
#  Logging configuration
# ─────────────────────────────────────────────

LOG_FILE="${LOG_FILE:-/tmp/dotfiles-setup-$(date +%Y%m%d-%H%M%S).log}"
LOG_LEVEL="${LOG_LEVEL:-INFO}"   # DEBUG | INFO | WARN | ERROR

# Ensure log file exists
mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"

_log_levels=(DEBUG INFO WARN ERROR)

_level_index() {
  local level="$1"
  local i=0
  for l in "${_log_levels[@]}"; do
    [[ "$l" == "$level" ]] && echo $i && return
    ((i++))
  done
  echo 1  # default INFO
}

_should_log() {
  local msg_level="$1"
  [[ $(_level_index "$msg_level") -ge $(_level_index "$LOG_LEVEL") ]]
}

_timestamp() {
  date +"%H:%M:%S"
}

# Write to log file without color codes
_log_file() {
  local level="$1"
  local msg="$2"
  printf "[%s] [%s] %s\n" "$(_timestamp)" "$level" "$msg" >> "$LOG_FILE"
}


# ─────────────────────────────────────────────
#  Color primitives (256-color)
# ─────────────────────────────────────────────

_has_color() {
  [[ -t 1 ]] && command -v tput &>/dev/null && [[ "$(tput colors 2>/dev/null)" -ge 8 ]]
}

_color() {
  local code="$1"; shift
  if _has_color; then
    printf "\033[%sm%s\033[0m" "$code" "$*"
  else
    printf "%s" "$*"
  fi
}

_bold()    { _color "1"      "$@"; }
_dim()     { _color "2"      "$@"; }
_red()     { _color "0;31"   "$@"; }
_green()   { _color "0;32"   "$@"; }
_yellow()  { _color "0;33"   "$@"; }
_blue()    { _color "0;34"   "$@"; }
_magenta() { _color "0;35"   "$@"; }
_cyan()    { _color "0;36"   "$@"; }
_white()   { _color "0;37"   "$@"; }

# Backward-compatible wrappers used by create_symbolic_links.sh and others
print_in_color() { printf "%b" "$(tput setaf "$2" 2>/dev/null)" "$1" "$(tput sgr0 2>/dev/null)"; }
print_in_green()  { print_in_color "$1" 2; }
print_in_purple() { print_in_color "$1" 5; }
print_in_red()    { print_in_color "$1" 1; }
print_in_yellow() { print_in_color "$1" 3; }


# ─────────────────────────────────────────────
#  Structured log functions
# ─────────────────────────────────────────────

_PREFIX_INFO="$(_cyan     "$(_timestamp)")"
_prefix()   { printf "%s  " "$(_dim "$(_timestamp)")"; }

print_info() {
  local msg="$1"
  _should_log INFO || return 0
  printf "  %s  %s\n" "$(_cyan    "·")" "$msg"
  _log_file INFO "$msg"
}

print_success() {
  local msg="$1"
  printf "  %s  %s\n" "$(_green   "✔")" "$(_green "$msg")"
  _log_file INFO "SUCCESS: $msg"
}

print_warning() {
  local msg="$1"
  printf "  %s  %s\n" "$(_yellow  "!")" "$(_yellow "$msg")"
  _log_file WARN "$msg"
}

print_error() {
  local msg="$1"
  printf "  %s  %s\n" "$(_red     "✖")" "$(_red "$msg")" >&2
  _log_file ERROR "$msg"
}

print_question() {
  printf "  %s  %s" "$(_yellow "?")" "$(_yellow "$1")"
  _log_file INFO "PROMPT: $1"
}

print_result() {
  local code="$1"
  local msg="$2"
  if [[ "$code" -eq 0 ]]; then
    print_success "$msg"
  else
    print_error "$msg"
  fi
  return "$code"
}

print_debug() {
  local msg="$1"
  _should_log DEBUG || return 0
  printf "  %s  %s\n" "$(_dim "·")" "$(_dim "$msg")"
  _log_file DEBUG "$msg"
}


# ─────────────────────────────────────────────
#  Section headers
# ─────────────────────────────────────────────

print_section() {
  local title="$1"
  local width=50
  local line
  line="$(printf '─%.0s' $(seq 1 $width))"
  printf "\n  %s\n  %s  %s\n  %s\n" \
    "$(_cyan "$line")" \
    "$(_bold "$(_cyan "▶")")" \
    "$(_bold "$title")" \
    "$(_cyan "$line")"
  _log_file INFO "=== $title ==="
}

print_step() {
  local step="$1"
  local total="$2"
  local msg="$3"
  printf "\n  %s  %s\n" \
    "$(_cyan "[${step}/${total}]")" \
    "$(_bold "$msg")"
  _log_file INFO "Step $step/$total: $msg"
}


# ─────────────────────────────────────────────
#  Spinner
# ─────────────────────────────────────────────

_spinner_frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")

show_spinner() {
  local pid="$1"
  local msg="${2:-Working...}"
  local i=0
  while kill -0 "$pid" 2>/dev/null; do
    local frame="${_spinner_frames[$((i % ${#_spinner_frames[@]}))]}"
    printf "  %s  %s\r" "$(_cyan "$frame")" "$msg"
    sleep 0.1
    ((i++))
  done
  printf "    %*s\r" "${#msg}" ""   # clear the line
}


# ─────────────────────────────────────────────
#  Command execution
# ─────────────────────────────────────────────

execute() {
  local cmds="$1"
  local msg="${2:-$1}"
  local tmp_file
  tmp_file="$(mktemp /tmp/dotfiles-XXXXX)"

  _log_file DEBUG "RUN: $cmds"

  eval "$cmds" \
    >>"$LOG_FILE" \
    2>"$tmp_file" &

  local pid=$!
  show_spinner "$pid" "$msg"
  wait "$pid"
  local exit_code=$?

  print_result $exit_code "$msg"

  if [[ $exit_code -ne 0 ]]; then
    local err
    err="$(cat "$tmp_file")"
    [[ -n "$err" ]] && print_error "$err"
  fi

  rm -f "$tmp_file"
  return $exit_code
}


# ─────────────────────────────────────────────
#  Duration tracking
# ─────────────────────────────────────────────

_SETUP_START=$(date +%s)

print_duration() {
  local end
  end=$(date +%s)
  local elapsed=$(( end - _SETUP_START ))
  local mins=$(( elapsed / 60 ))
  local secs=$(( elapsed % 60 ))
  printf "\n  %s  Completed in %dm %ds\n\n" \
    "$(_cyan "⏱")" "$mins" "$secs"
}

print_log_path() {
  printf "\n  %s  Full log: %s\n" "$(_dim "📄")" "$(_dim "$LOG_FILE")"
}


# ─────────────────────────────────────────────
#  Sudo keep-alive
# ─────────────────────────────────────────────

sudo_keepalive() {
  # Prompt once, then refresh the token in the background every 60s
  # for the lifetime of the calling process.
  print_info "Sudo access required for system configuration"
  sudo -v || { print_error "sudo authentication failed"; exit 1; }

  ( while true; do
      sudo -n true
      sleep 60
      kill -0 "$$" 2>/dev/null || exit
    done
  ) &

  _SUDO_KEEPALIVE_PID=$!
  # Clean up the background job when the script exits
  trap 'kill "$_SUDO_KEEPALIVE_PID" 2>/dev/null' EXIT
  print_success "Sudo credentials cached for this session"
}


# ─────────────────────────────────────────────
#  User interaction
# ─────────────────────────────────────────────

ask() {
  print_question "$1"
  read -r
}

ask_for_confirmation() {
  print_question "$1 (y/n) "
  read -r -n 1
  printf "\n"
}

answer_is_yes() {
  [[ "$REPLY" =~ ^[Yy]$ ]] && return 0 || return 1
}

get_answer() {
  printf "%s" "$REPLY"
}


# ─────────────────────────────────────────────
#  Utility functions
# ─────────────────────────────────────────────

cmd_exists() {
  command -v "$1" &>/dev/null
}

set_trap() {
  trap -p "$1" | grep "$2" &>/dev/null || trap "$2" "$1"
}

get_os() {
  local os="" kernelName=""
  kernelName="$(uname -s)"
  if [[ "$kernelName" == "Darwin" ]]; then
    os="macos"
  elif [[ "$kernelName" == "Linux" ]] && [[ -e "/etc/os-release" ]]; then
    os="$(. /etc/os-release; printf "%s" "$ID")"
  else
    os="$kernelName"
  fi
  printf "%s" "$os"
}
