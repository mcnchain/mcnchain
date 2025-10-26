#!/usr/bin/env bash
set -euo pipefail

DATADIR="${DATADIR:-./data/validator1}"
PASSWORD_FILE="${PASSWORD_FILE:-./password.txt}"

mkdir -p "$DATADIR"
touch "$PASSWORD_FILE"

echo "Creating new account in $DATADIR ..."
ADDR_RAW="$(geth account new --datadir "$DATADIR" --password "$PASSWORD_FILE" 2>&1 | tee /dev/stderr)"
# On success geth prints: "Address: {0xABC...}"
ADDR="$(printf '%s\n' "$ADDR_RAW" | grep -oE 'Address:[[:space:]]*\{0x[0-9a-fA-F]+\}' | grep -oE '0x[0-9a-fA-F]+')"

if [[ -z "${ADDR:-}" ]]; then
  # Fallback: list keystore and pick the newest
  ADDR="$(geth account list --datadir "$DATADIR" | awk -F'[{}]' '/Address/{print "0x"$2}' | tail -n1)"
fi

if [[ -z "${ADDR:-}" ]]; then
  echo "Failed to obtain account address"; exit 1
fi

echo "$ADDR" > "$DATADIR/.coinbase"
echo "Coinbase: $ADDR"
