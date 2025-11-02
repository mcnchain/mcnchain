#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

# Проверка timestamp в genesis.json (ZGT)
if jq -e '.timestamp' "$GENESIS_PATH" >/dev/null 2>&1; then
  TS_HEX="$(jq -r '.timestamp' "$GENESIS_PATH")"
  if [[ "$TS_HEX" == "0x0" || "$TS_HEX" == "0x00" ]]; then
    ylw "timestamp=0x0 в $GENESIS_PATH — исправляю на текущий UNIX."
    NOW_HEX="$(printf '0x%X' "$(date +%s)")"
    tmp="$(mktemp)"
    jq --arg ts "$NOW_HEX" '.timestamp = $ts' "$GENESIS_PATH" > "$tmp"
    mv "$tmp" "$GENESIS_PATH"
    grn "timestamp → $NOW_HEX"
  fi
else
  ylw "В $GENESIS_PATH нет поля .timestamp — добавляю."
  NOW_HEX="$(printf '0x%X' "$(date +%s)")"
  tmp="$(mktemp)"
  jq --arg ts "$NOW_HEX" '. + { "timestamp": $ts }' "$GENESIS_PATH" > "$tmp"
  mv "$tmp" "$GENESIS_PATH"
  grn "timestamp → $NOW_HEX"
fi

# Инициализация датадира
"$GETH_BIN" init --datadir "$VALIDATOR_DIR" "$GENESIS_PATH"
grn "init OK: $VALIDATOR_DIR"
