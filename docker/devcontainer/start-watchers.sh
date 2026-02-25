#!/bin/bash
# Background watchers launched on every container start via postStartCommand

# GrepAI — watch for file changes and update embeddings index
# https://yoanbernabeu.github.io/grepai/watch-guide/
nohup grepai watch > /tmp/grepai-watch.log 2>&1 &
