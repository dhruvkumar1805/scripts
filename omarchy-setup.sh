#!/usr/bin/env bash
# run this after a fresh omarchy install
set -euo pipefail

HYPR="$HOME/.config/hypr"

log() { echo ">> $1"; }

if [[ ! -d "$HYPR" ]]; then
  echo "ERROR: $HYPR not found. is omarchy installed?"
  exit 1
fi

# ── input.conf ───────────────────────────────────────────────────────────────
log "Patching input.conf"
INPUT="$HYPR/input.conf"

sed -i 's/# natural_scroll = true/natural_scroll = true/' "$INPUT"
sed -i 's/repeat_delay = 250/repeat_delay = 600/' "$INPUT"
sed -i 's/kb_options = compose:caps /kb_options = /' "$INPUT"
sed -i 's/clickfinger_behavior = true/# clickfinger_behavior = true/' "$INPUT"

# ── bindings.conf ─────────────────────────────────────────────────────────────
log "Patching bindings.conf"
BINDINGS="$HYPR/bindings.conf"

# don't use these apps
sed -i 's/^bindd = SUPER SHIFT, G, Signal/unbind = SUPER SHIFT, G, Signal/' "$BINDINGS"
sed -i 's/^bindd = SUPER SHIFT, C, Calendar/unbind = SUPER SHIFT, C, Calendar/' "$BINDINGS"
sed -i 's/^bindd = SUPER SHIFT, E, Email/unbind = SUPER SHIFT, E, Email/' "$BINDINGS"
sed -i '/SUPER SHIFT, W, Typora/d' "$BINDINGS"
sed -i '/SUPER SHIFT, SLASH, Passwords/d' "$BINDINGS"
sed -i '/SUPER SHIFT CTRL, G, Google Messages/d' "$BINDINGS"
sed -i '/SUPER SHIFT, P, Google Photos/d' "$BINDINGS"

sed -i 's|SUPER SHIFT ALT, A, Grok, exec, omarchy-launch-webapp "https://grok.com"|SUPER SHIFT ALT, A, Gemini, exec, omarchy-launch-webapp "https://gemini.google.com/"|' "$BINDINGS"
sed -i 's/SUPER SHIFT ALT, G, WhatsApp/SUPER SHIFT, W, WhatsApp/' "$BINDINGS"

# ── webapps ──────────────────────────────────────────────────────────────────
log "Setting up webapps"

# remove omarchy defaults we don't use
omarchy-webapp-remove "HEY" "Basecamp" "Google Photos" "Google Contacts" "Google Messages" "Google Maps" "Fizzy"

# add ones omarchy doesn't install by default
omarchy-webapp-install "Netflix"     https://netflix.com      "https://www.google.com/s2/favicons?domain=netflix.com&sz=128"
omarchy-webapp-install "Notion"      https://notion.so        "https://www.google.com/s2/favicons?domain=notion.so&sz=128"
omarchy-webapp-install "Prime Video" https://primevideo.com   "https://www.google.com/s2/favicons?domain=primevideo.com&sz=128"

# ── browsers ─────────────────────────────────────────────────────────────────
# omarchy-install-browser handles aur install + theme sync + policy setup
log "Setting up browsers"

omarchy-pkg-drop chromium 2>/dev/null || true
omarchy-install-browser chrome
omarchy-install-browser brave
omarchy-default-browser chrome

# ── vscode ────────────────────────────────────────────────────────────────────
log "Installing VS Code"
omarchy-install-vscode

# ── monitors.conf ─────────────────────────────────────────────────────────────
# external on the left, laptop on the right
# positions are in logical pixels (so eDP-1 starts at 1920, not 1920/1.5)
log "Writing monitors.conf"
cat > "$HYPR/monitors.conf" << 'MONITORS'
monitor = HDMI-A-1, 1920x1080@240, 0x0,    1
monitor = eDP-1,    1920x1080@144, 1920x0, 1.5
MONITORS

log "done — restart hyprland to apply changes"
