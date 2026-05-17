
command_exists() {
  if ! command -v "$1" > /dev/null; then
    log error "The command '${1}' is missing. Please install it."
    exit 1
  fi
}

# Check for sudo privileges to ensure the user can run the script
sudo_check() {
    if ! sudo -v; then
        log error "You need sudo privileges to run this script."
        exit 1
    fi
}
