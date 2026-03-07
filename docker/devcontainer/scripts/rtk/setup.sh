#!/bin/bash

set -euo pipefail

echo "==> Setup rtk"
rtk init --global --auto-patch
