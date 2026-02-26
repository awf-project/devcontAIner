#!/bin/bash
# postStartCommand — runs on every container start (not just first create).
# Launches background watchers that must stay alive for the dev session.

set -euo pipefail

