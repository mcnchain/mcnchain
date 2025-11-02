#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

IPC_PATH="${VALIDATOR_DIR}/geth.ipc"
[[ -S "$IPC_PATH" ]] || { red "Нет IPC ${IPC_PATH} — нода запущена?"; exit 1; }

[[ -s "$STATIC_PEERS_FILE" ]] || { ylw "Нет $STATIC_PEERS_FILE — пропускаю засев пиров."; exit 0; }

while IFS= read -r ENODE; do
  [[ "$ENODE" =~ ^enode:// ]] || continue
  echo "admin.addPeer(\"$ENODE\")" | "$GETH_BIN" attach "$IPC_PATH" >/dev/null || true
  grn "addPeer: $ENODE"
done < "$STATIC_PEERS_FILE"
