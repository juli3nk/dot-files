#!/usr/bin/env bash

APT_KEYRINGS_PATH="/etc/apt/keyrings"

SSH_KEY_TYPE="ed25519"


install_docker() {
    local distrib_id
    local distrib_codename

    distrib_id="$(awk -F'=' '/^ID=/ { print $2 }' /etc/os-release)"
    distrib_codename="$(awk -F'=' '/^VERSION_CODENAME/ { print $2 }' /etc/os-release)"

    if [ "$distrib_id" == "kali" ]; then
        distrib_id="debian"
        distrib_codename="bookworm"
    fi

    if [ ! -f "${APT_KEYRINGS_PATH}/docker.gpg" ]; then
        curl -sfSL "https://download.docker.com/linux/${distrib_id}/gpg" | sudo gpg --dearmor --yes --output "${APT_KEYRINGS_PATH}/docker.gpg"
        sudo chmod a+r "${APT_KEYRINGS_PATH}/docker.gpg"
    fi

    if [ ! -f "/etc/apt/sources.list.d/docker.list" ]; then
        echo \
        "deb [arch=\"$(dpkg --print-architecture)\" signed-by=\"${APT_KEYRINGS_PATH}/docker.gpg\"] https://download.docker.com/linux/${distrib_id} \
        ${distrib_codename} stable" \
        | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        sudo apt update
    fi

    sudo apt install --no-install-recommends --yes \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin

    if [ "$(getent group docker | grep -c "$USER")" -eq 0 ]; then
        sudo usermod -aG docker "$USER"
    fi
}

configure_default_shell() {
  sudo unlink /bin/sh
  sudo ln -s /bin/bash /bin/sh
}

configure_sudoers() {
    local SUDOERS_FILE_ME="/etc/sudoers.d/localuser"
    local rule
    rule="$(id -un) ALL=(ALL) NOPASSWD:ALL"

    if [ ! -f "$SUDOERS_FILE_ME" ]; then
        echo "$rule" | sudo tee "$SUDOERS_FILE_ME"
    fi
}

configure_ssh() {
    local user_ssh_dir="${HOME}/.ssh"

    # User SSH config
    mkdir -p "$user_ssh_dir"
    chmod 770 "$user_ssh_dir"

    if [ ! -f "${user_ssh_dir}/config" ]; then
        cat << EOF > "${user_ssh_dir}/config"
Host *
  KeepAlive yes
  ServerAliveInterval 60
  ServerAliveCountMax 3
  Compression yes
EOF
    fi

    # Generate SSH key
    if [ ! -f "${user_ssh_dir}/id_${SSH_KEY_TYPE}" ]; then
        ssh-keygen -t "$SSH_KEY_TYPE" -f "${HOME}/.ssh/id_${SSH_KEY_TYPE}" -N '' -q
    fi
}

configure_git_credentials() {
  sudo apt install --no-install-recommends --yes \
    libsecret-1-0 \
    libsecret-1-dev

  cd /usr/share/doc/git/contrib/credential/libsecret
  sudo make
  # git config --global credential.helper /usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret
}

if [ "$(grep -c "ID=ubuntu" /etc/os-release)" -eq 0 ]; then
  exit 1
fi

if [ "$(id -u)" -eq 0 ]; then
  echo -e "do not execute this script as root"
  exit 1
fi

# Set default shell for /bin/sh
configure_default_shell

# Set sudoers
configure_sudoers

# APT keyrings
sudo install -m 0755 -d "$APT_KEYRINGS_PATH"

# User SSH config
configure_ssh

# Install packages
sudo apt update
sudo apt install --no-install-recommends --yes \
  curl \
  git \
  tmux \
  wget

  apt-transport-https \
  ca-certificates \

  # Security Utilities
  'clamav'        # Open source virus scanning suite
  'cryptsetup'    # Reading / writing encrypted volumes
  'gnupg'         # PGP encryption, signing and verifying
  'git-crypt'     # Transparent encryption for git repos
  'lynis'         # Scan system for common security issues
  'openssl'       # Cryptography and SSL/TLS Toolkit
  'rkhunter'      # Search / detect potential root kits

  # Monitoring, management and stats
  'btop'          # Live system resource monitoring
  'bmon'          # Bandwidth utilization monitor
  'ctop'          # Container metrics and monitoring
  htop \
  'gping'         # Interactive ping tool, with graph
  'glances'       # Resource monitor + web and API
  'goaccess'      # Web log analyzer and viewer
  'speedtest-cli' # Command line speed test utility

  # CLI Power Basics
  'aria2'         # Resuming download util (better wget)
  'bat'           # Output highlighting (better cat)
  'ctags'         # Indexing of file info + headers
  'diff-so-fancy' # Readable file compares (better diff)
  'duf'           # Get info on mounted disks (better df)
  'exa'           # Listing files with info (better ls)
  'fzf'           # Fuzzy file finder and filtering
  'hyperfine'     # Benchmarking for arbitrary commands
  'just'          # Powerful command runner (better make)
  'jq'            # JSON parser, output and query files
  'most'          # Multi-window scroll pager (better less)
  'procs'         # Advanced process viewer (better ps)
  'ripgrep'       # Searching within files (better grep)
  'scrot'         # Screenshots programmatically via CLI
  'sd'            # RegEx find and replace (better sed)
  'tealdeer'      # Reader for command docs (better man)
  'tree'          # Directory listings as tree structure
  'tokei'         # Count lines of code (better cloc)
  'trash-cli'     # Record and restore removed files
  'xsel'          # Copy paste access to the X clipboard
  'zoxide'        # Auto-learning navigation (better cd)

  gcc \
  libfuse2 \
  make \
  pwgen \
  xdg-utils

## Docker
install_docker
