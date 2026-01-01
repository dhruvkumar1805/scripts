#!/usr/bin/env bash
set -Eeuo pipefail

# ==========================
# Colors
# ==========================
RED=$(tput setaf 1)
GRN=$(tput setaf 2)
BLU=$(tput setaf 4)
BOLD=$(tput bold)
RST=$(tput sgr0)

log() {
  echo -e "${GRN}${BOLD}>>${RST} $1"
}

err() {
  echo -e "${RED}${BOLD}ERROR:${RST} $1" >&2
}

trap 'err "Script failed at line $LINENO"' ERR

# ==========================
# Root check
# ==========================
if [[ $EUID -ne 0 ]]; then
  err "Run this script with sudo"
  exit 1
fi

# ==========================
# Update system (safe)
# ==========================
log "Updating package index"
apt-get update -qq

log "Installing base packages"
apt-get install -y --no-install-recommends \
  git automake adb fastboot clang lzip apt-utils gnupg libtool \
  subversion flex bc bison neofetch build-essential zip curl \
  zlib1g-dev gcc gcc-multilib g++-multilib libc6-dev-i386 \
  lib32ncurses5-dev x11proto-core-dev libx11-dev jq lib32z1-dev \
  libgl1-mesa-dev libxml2-utils xsltproc unzip fontconfig imagemagick \
  python2 python3 python3-pip python3-dev python-is-python3 \
  schedtool ccache libtinfo5 libncurses5 lzop tmux libssl-dev \
  patch patchelf apktool dos2unix git-lfs default-jdk \
  libxml-simple-perl zram-config

# ==========================
# repo tool
# ==========================
log "Installing repo tool"
install -Dm755 <(
  curl -fsSL https://storage.googleapis.com/git-repo-downloads/repo
) /usr/local/bin/repo

# ==========================
# Git config (optional)
# ==========================
TARGET_USER="${SUDO_USER:-$USER}"

if [[ "$TARGET_USER" == "dhruv" ]]; then
  log "Configuring git for $TARGET_USER"
  sudo -u "$TARGET_USER" git config --global user.name "dhruvkumar1805"
  sudo -u "$TARGET_USER" git config --global user.email "dhruvkumar1805@gmail.com"
fi

# ==========================
# Snap apps
# ==========================
log "Ensuring snapd is available"
apt-get install -y snapd
systemctl enable --now snapd

log "Installing Telegram"
snap install telegram-desktop

log "Installing VS Code"
snap install --classic code

# ==========================
# Google Chrome
# ==========================
log "Installing Google Chrome"
TMPDIR=$(mktemp -d)
curl -fsSL https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
  -o "$TMPDIR/chrome.deb"

dpkg -i "$TMPDIR/chrome.deb" || apt-get -f install -y
rm -rf "$TMPDIR"

# ==========================
# Cleanup
# ==========================
log "Removing Firefox"
apt-get purge -y firefox || true

log "Autoremove & clean"
apt-get autoremove -y
apt-get autoclean -y

log "Setup completed successfully 🎉"
