#!/usr/bin/env bash
set -euo pipefail

REQ_GETH="1.13.11"
which geth >/dev/null 2>&1 || { echo "geth not found"; exit 1; }
which bootnode >/dev/null 2>&1 || { echo "bootnode not found"; exit 1; }

GETH_VER="$(geth version | awk -F': ' '/Version:/{print $2; exit}' | sed 's/[[:space:]]*$//')"
echo "Detected geth: ${GETH_VER}"
if [[ "${GETH_VER}" != "${REQ_GETH}"* ]]; then
  echo "Warning: expected geth ${REQ_GETH}, got ${GETH_VER}"
fi

# Ensure bootnode key & ENR
BOOTNODE_KEY="./data/bootnode.key"
mkdir -p "$(dirname "$BOOTNODE_KEY")"
if [[ ! -s "$BOOTNODE_KEY" ]]; then
  echo "Generating bootnode key..."
  bootnode -genkey "$BOOTNODE_KEY"
fi

echo "Versions OK and bootnode key ready."
