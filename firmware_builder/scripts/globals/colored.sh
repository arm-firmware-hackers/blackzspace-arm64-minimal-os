eco() {
  local status=$1
  shift
  local message="$*"

  # ANSI-Farbcodes
  local COLOR_RESET="\033[0m"
  local COLOR_CYAN="\033[0;36m"
  local COLOR_ORANGE="\033[38;5;214m"
  local COLOR_RED="\033[0;31m"
  local COLOR_NEONGREEN="\033[38;5;10m"

  case "$status" in
    info)
      echo -e "${COLOR_CYAN}[INFO]${COLOR_RESET} $message"
      ;;
    warn)
      echo -e "${COLOR_ORANGE}[WARN]${COLOR_RESET} $message"
      ;;
    error)
      echo -e "${COLOR_RED}[ERROR]${COLOR_RESET} $message"
      ;;
    success)
      echo -e "${COLOR_NEONGREEN}[SUCCESS]${COLOR_RESET} $message"
      ;;
    *)
      echo -e "${COLOR_RED}[ERROR]${COLOR_RESET} Unbekannter Status: '$status'"
      return 1
      ;;
  esac
}
