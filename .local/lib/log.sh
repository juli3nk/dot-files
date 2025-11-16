
# ANSI color codes
RESET="\e[0m"
RED="\e[1;31m"
BLUE="\e[1;34m"
ORANGE="\e[38;5;214m"
GREEN="\e[1;32m"
PURPLE="\e[1;35m"
YELLOW="\e[1;33m"

# Default log level (can be overridden: export LOG_LEVEL=debug)
LOG_LEVEL="${LOG_LEVEL:-info}"

# Log function
log() {
  local level_name="$1"
  shift
  local msg="$*"
  local color level_num msg_level_num

  # Map level to color
  case "$level_name" in
    fatal)   color=$RED;    level_num=0 ;;
    error)   color=$RED;    level_num=1 ;;
    warning) color=$ORANGE; level_num=2 ;;
    success) color=$GREEN;  level_num=3 ;;
    debug)   color=$PURPLE; level_num=4 ;;
    info|*)  color=$BLUE;   level_num=5 ;;
  esac

  # Map LOG_LEVEL to numeric
  case "$LOG_LEVEL" in
    fatal)   msg_level_num=0 ;;
    error)   msg_level_num=1 ;;
    warning) msg_level_num=2 ;;
    success) msg_level_num=3 ;;
    debug)   msg_level_num=4 ;;
    info|*)  msg_level_num=5 ;;
  esac

  # Only print if level is >= LOG_LEVEL
  if (( level_num <= msg_level_num )); then
    # Errors to stderr, others to stdout
    if (( level_num <= 1 )); then
      echo -e "${color}${level_name^^}${RESET}: $msg" >&2
    else
      echo -e "${color}${level_name^^}${RESET}: $msg"
    fi
  fi
}
