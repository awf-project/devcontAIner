#!/bin/bash
# postStartCommand — runs on every container start (not just first create).
# Launches background watchers that must stay alive for the dev session.

set -euo pipefail

# JetBrains Gateway overrides XDG vars to /.jbdevcontainer/{config,data,cache}.
# Create symlinks so tools (awf, etc) still find config mounted to /home/vscode.
if [ -d "/.jbdevcontainer" ]; then
    echo "==> JetBrains XDG override detected, creating symlinks"
    
    mkdir -p "/.jbdevcontainer/config" "/.jbdevcontainer/data"
    
    ln -sfn /home/vscode/.config /.jbdevcontainer/config
    ln -sfn /home/vscode/.local/share /.jbdevcontainer/data

    echo " /.jbdevcontainer/config -> /home/vscode/.config"
    echo " /.jbdevcontainer/data -> /home/vscode/.local/share"
fi