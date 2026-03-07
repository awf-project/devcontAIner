#!/bin/bash
# postStartCommand — runs on every container start (not just first create).
# Launches background watchers that must stay alive for the dev session.

set -euo pipefail

HOME_DIR="$(getent passwd "$(whoami)" | cut -d: -f6)"

# JetBrains Gateway overrides XDG vars to /.jbdevcontainer/{config,data,cache}.
# Create symlinks so tools (awf, etc) still find config mounted to ${HOME_DIR}.
if [ -d "/.jbdevcontainer" ]; then
    echo "==> JetBrains XDG override detected, creating symlinks"
    
    mkdir -p "/.jbdevcontainer/config" "/.jbdevcontainer/data"
    
    ln -sfn "${HOME_DIR}/.config" "/.jbdevcontainer/config"
    ln -sfn "${HOME_DIR}/.local/share" "/.jbdevcontainer/data"

    echo " /.jbdevcontainer/config -> ${HOME_DIR}/.config"
    echo " /.jbdevcontainer/data -> ${HOME_DIR}/.local/share"
fi
