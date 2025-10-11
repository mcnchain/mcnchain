#!/usr/bin/env bash
set -euo pipefail
bootnode -nodekey node/bootnode/boot.key -addr :${BOOTNODE_PORT:-30301}
