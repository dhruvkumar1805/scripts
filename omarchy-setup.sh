#!/usr/bin/env bash
# run this after a fresh omarchy install
set -euo pipefail

HYPR="$HOME/.config/hypr"

BOLD=$(tput bold)
CYAN=$(tput setaf 6)
GRN=$(tput setaf 2)
YLW=$(tput setaf 3)
RST=$(tput sgr0)

TOTAL=6
STEP=0

log() {
  STEP=$((STEP + 1))
  echo -e "\n${BOLD}${CYAN}[${STEP}/${TOTAL}] $1${RST}"
}
ok() { echo -e "${GRN}  ✓ $1${RST}"; }

# ── banner ────────────────────────────────────────────────────────────────────
echo -e "\n${BOLD}${YLW}  setting up ${USER}'s machine on $(hostname)${RST}\n"

if [[ ! -d "$HYPR" ]]; then
  echo "error: $HYPR not found — is omarchy installed?"
  exit 1
fi

# ── input.conf ───────────────────────────────────────────────────────────────
log "Patching input.conf"

sed -i 's/# natural_scroll = true/natural_scroll = true/'             "$HYPR/input.conf"
sed -i 's/repeat_delay = 250/repeat_delay = 600/'                     "$HYPR/input.conf"
sed -i 's/kb_options = compose:caps /kb_options = /'                  "$HYPR/input.conf"
sed -i 's/clickfinger_behavior = true/# clickfinger_behavior = true/' "$HYPR/input.conf"
ok "input.conf"

# ── bindings.conf ─────────────────────────────────────────────────────────────
log "Patching bindings.conf"

sed -i 's/^bindd = SUPER SHIFT, G, Signal/unbind = SUPER SHIFT, G, Signal/'     "$HYPR/bindings.conf"
sed -i 's/^bindd = SUPER SHIFT, C, Calendar/unbind = SUPER SHIFT, C, Calendar/' "$HYPR/bindings.conf"
sed -i 's/^bindd = SUPER SHIFT, E, Email/unbind = SUPER SHIFT, E, Email/'       "$HYPR/bindings.conf"
sed -i '/SUPER SHIFT, W, Typora/d'                                               "$HYPR/bindings.conf"
sed -i '/SUPER SHIFT, SLASH, Passwords/d'                                        "$HYPR/bindings.conf"
sed -i '/SUPER SHIFT CTRL, G, Google Messages/d'                                 "$HYPR/bindings.conf"
sed -i '/SUPER SHIFT, P, Google Photos/d'                                        "$HYPR/bindings.conf"
sed -i 's|SUPER SHIFT ALT, A, Grok, exec, omarchy-launch-webapp "https://grok.com"|SUPER SHIFT ALT, A, Gemini, exec, omarchy-launch-webapp "https://gemini.google.com/"|' "$HYPR/bindings.conf"
sed -i 's/SUPER SHIFT ALT, G, WhatsApp/SUPER SHIFT, W, WhatsApp/'               "$HYPR/bindings.conf"
ok "bindings.conf"

# ── webapps ──────────────────────────────────────────────────────────────────
log "Setting up webapps"

omarchy-webapp-remove "HEY" "Basecamp" "Google Photos" "Google Contacts" "Google Messages" "Google Maps" "Fizzy"

omarchy-webapp-install "Netflix"     https://netflix.com    "https://www.google.com/s2/favicons?domain=netflix.com&sz=128"
omarchy-webapp-install "Notion"      https://notion.so      "https://www.google.com/s2/favicons?domain=notion.so&sz=128"
omarchy-webapp-install "Prime Video" https://primevideo.com "https://www.google.com/s2/favicons?domain=primevideo.com&sz=128"
ok "webapps"

# ── browsers ─────────────────────────────────────────────────────────────────
log "Setting up browsers"

omarchy-pkg-drop chromium 2>/dev/null || true
omarchy-install-browser chrome
omarchy-install-browser brave
omarchy-default-browser chrome
ok "browsers"

# ── vscode ────────────────────────────────────────────────────────────────────
log "Installing VS Code"

omarchy-install-vscode
ok "vscode"

# ── monitors ─────────────────────────────────────────────────────────────────
log "Writing monitors.conf"

# external on the left, laptop on the right
cat > "$HYPR/monitors.conf" << 'EOF'
monitor = HDMI-A-1, 1920x1080@240, 0x0,    1
monitor = eDP-1,    1920x1080@144, 1920x0, 1.5
EOF
ok "monitors.conf"

# ─────────────────────────────────────────────────────────────────────────────
hyprctl reload
echo -e "\n${BOLD}${GRN}  ${USER}'s machine is ready${RST}\n"
