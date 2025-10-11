#!/usr/bin/env bash
set -euo pipefail
geth version | grep -E "Version: 1\.13\.11|Git Commit: 8f7eb9cc"
bootnode -version
jq --version >/dev/null 2>&1 || { echo "install jq"; exit 1; }
python3 -V
