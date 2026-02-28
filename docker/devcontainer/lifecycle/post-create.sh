#!/bin/bash
# postCreateCommand — runs after the container is created (and after rebuilds).
# Used here to verify all expected tooling is available and print versions.

set -euo pipefail

echo "==> Verifying installed tooling"

node --version
pnpm --version
bun --version
gh --version
python3 --version
docker --version
docker compose version
uv --version
rg --version
bat --version
fzf --version
jq --version
eza --version
claude --version
gemini --version
grepai version
