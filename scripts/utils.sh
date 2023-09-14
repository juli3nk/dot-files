
get_latest_tag() {
  local repo_url="$1"

  git ls-remote --tags "https://${repo_url}.git" | grep -v "{}" | awk -F'/' '{ print $3 }' | sort -V | tail -n 1 | sed 's/^v//'
}

is_app_installed() {
  type "$1" &>/dev/null
}
