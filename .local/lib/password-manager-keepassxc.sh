
command -v keepassxc-cli > /dev/null || { echo -e "\"keepassxc-cli\" command not found" ; return ; }

pm_get_info() {
  local entry="$1"
  local attribute="$2"

  if [ -z "$entry" ]; then
    echo "entry var cannot be empty"
    exit 21
  fi
  if [ -z "$attribute" ]; then
    attribute="Password"
  fi

  echo "$KEEPASS_PASSWORD" | keepassxc-cli show -q "$KEEPASS_DB_PATH" "$entry" -a "$attribute"
}


if [ -z "$KEEPASS_DB_PATH" ]; then exit_ "No Keepass database path set" ; fi

echo "Keepass password: "
read -s KEEPASS_PASSWORD
if [ -z "$KEEPASS_PASSWORD" ]; then exit_ "No Keepass password provided" ; fi
