#!/bin/bash
# postStartCommand — runs on every container start (not just first create).
# Launches background watchers that must stay alive for the dev session.

set -euo pipefail

# GrepAI — watches for file changes and keeps the embeddings index up-to-date.
# https://yoanbernabeu.github.io/grepai/watch-guide/
nohup grepai watch > /tmp/grepai-watch.log 2>&1 &
echo "==> grepai watch started (log: /tmp/grepai-watch.log)"
