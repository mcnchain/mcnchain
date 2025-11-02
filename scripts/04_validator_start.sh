#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

ensure_file "$COINBASE_FILE"
ensure_password_file "$COINBASE_PASSWORD_FILE"

COINBASE_ADDR="$(tr -d '\n\r ' < "$COINBASE_FILE")"
[[ "$COINBASE_ADDR" =~ ^0x[0-9a-fA-F]{40}$ ]] || { red "Неверный адрес в $COINBASE_FILE"; exit 1; }

# Опциональные статические пиры (через admin.addPeer позже — см. 05_peer_seed.sh)
if [[ -s "$STATIC_PEERS_FILE" ]]; then
  ylw "Найдены статические пиры: $STATIC_PEERS_FILE"
fi

# Жёстко закрываем HTTP/WS наружу (PNI)
# Оставляем только локалхост — наружу через Nginx/mTLS/SSH-туннель
HTTP_FLAGS=(
  --http --http.addr "$HTTP_ADDR" --http.port "$HTTP_PORT"
  --http.api "$HTTP_APIS" --http.corsdomain "$HTTP_CORS"
)
if [[ "${WS_ENABLE}" == "true" ]]; then
  WS_FLAGS=( --ws --ws.addr "$WS_ADDR" --ws.port "$WS_PORT" --ws.origins "$WS_ORIGINS" )
else
  WS_FLAGS=()
fi

# Bootnodes (если заданы)
BN_FLAGS=()
[[ -n "${BOOTNODES}" ]] && BN_FLAGS=( --bootnodes "$BOOTNODES" )

exec "$GETH_BIN" \
  --datadir "$VALIDATOR_DIR" \
  --networkid "$NETWORK_ID" \
  --syncmode full \
  --port 30303 \
  "${BN_FLAGS[@]}" \
  "${HTTP_FLAGS[@]}" \
  "${WS_FLAGS[@]}" \
  --miner.etherbase "$COINBASE_ADDR" \
  --unlock "$COINBASE_ADDR" \
  --password "$COINBASE_PASSWORD_FILE" \
  --mine --miner.threads 1 \
  --txpool.accountslots 256 --txpool.globalslots 8192
