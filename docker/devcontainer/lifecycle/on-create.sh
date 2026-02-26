#!/bin/bash
# onCreateCommand — runs once when the container is first created.
# Safe to be idempotent but not guaranteed to run on rebuild.

set -euo pipefail

# Seed .gitconfig from host-mounted copy so git works inside the container.
# The host gitconfig is mounted read-only at .gitconfig.host to avoid
# "device or resource busy" errors on the bind-mount target.
if [[ -f /home/vscode/.gitconfig.host ]]; then
  cp /home/vscode/.gitconfig.host /home/vscode/.gitconfig
  echo "==> gitconfig seeded from host"
fi

# tree-sitter-cli is installed via npm because the upstream binary requires
# GLIBC >= 2.39 which is unavailable on Debian Bookworm (2.36).
npm install -g tree-sitter-cli
