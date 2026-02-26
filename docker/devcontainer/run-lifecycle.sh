#!/bin/bash
# Lifecycle hook runner for devcontainer.
#
# Usage: run-lifecycle.sh <hook-name>
#
# Executes docker/devcontainer/lifecycle/<hook-name>.sh (versioned base),
# then docker/devcontainer/lifecycle/<hook-name>.local.sh (gitignored overlay)
# if present. The overlay extends the base — it cannot suppress it.
#
# To customize a hook, create the .local.sh file:
#   touch docker/devcontainer/lifecycle/post-start.local.sh
#   chmod +x docker/devcontainer/lifecycle/post-start.local.sh

set -euo pipefail

HOOK="${1:?Usage: run-lifecycle.sh <hook-name>}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lifecycle"

BASE="${SCRIPT_DIR}/${HOOK}.sh"
LOCAL="${SCRIPT_DIR}/${HOOK}.local.sh"

if [[ ! -f "$BASE" ]]; then
  echo "ERROR: base script not found: $BASE" >&2
  exit 1
fi

echo "==> [${HOOK}] running base"
bash "$BASE"

if [[ -f "$LOCAL" ]]; then
  echo "==> [${HOOK}] running local overlay"
  bash "$LOCAL"
fi
