#!/bin/bash

set -euo pipefail

HOME_DIR="$(getent passwd "$(whoami)" | cut -d: -f6)"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> Setup Claude statusline"
if [[ ! -f "${HOME_DIR}/.claude/statusline.sh" ]]; then
  mkdir -p "${HOME_DIR}/.claude"
  cp "${SCRIPT_DIR}/statusline.sh" "${HOME_DIR}/.claude/statusline.sh"
  echo "   statusline.sh copied to ~/.claude/"
else
  echo "   statusline.sh already exists, skipping"
fi

echo "==> Setup Claude settings.json"
SETTINGS_FILE="${HOME_DIR}/.claude/settings.json"
if [[ ! -f "$SETTINGS_FILE" ]]; then
  echo '{}' > "$SETTINGS_FILE"
fi
jq '.statusLine = {"type": "command", "command": "~/.claude/statusline.sh"}' "$SETTINGS_FILE" > "${SETTINGS_FILE}.tmp" \
  && mv "${SETTINGS_FILE}.tmp" "$SETTINGS_FILE"
echo "   statusLine configured in settings.json"

# --- Plugins: one-shot install ---
MARKER="${HOME_DIR}/.claude/.plugins-installed"

if [[ -f "$MARKER" ]]; then
  echo "==> Claude plugins already installed, skipping"
  exit 0
fi

echo "==> Adding Claude marketplaces"
MARKETPLACE=(
    yoanbernabeu/grepai-skills
    thedotmack/claude-mem
    anthropics/claude-plugins-official
)

for marketplace in "${MARKETPLACE[@]}"; do
  echo "   activate ${marketplace}"
  claude plugin marketplace add "${marketplace}" || true
done

echo "==> Installing Claude plugins"
PLUGINS=(
  grepai-advanced@grepai-skills
  grepai-embeddings@grepai-skills
  grepai-indexing@grepai-skills
  grepai-integration@grepai-skills
  grepai-search@grepai-skills
  grepai-storage@grepai-skills
  grepai-trace@grepai-skills
  claude-mem@thedotmack
)

for plugin in "${PLUGINS[@]}"; do
  echo "   installing ${plugin}"
  claude plugin install "${plugin}" || true
done

touch "$MARKER"
echo "==> Claude plugins installed successfully"