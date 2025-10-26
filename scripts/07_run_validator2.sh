#!/usr/bin/env bash
set -euo pipefail

# --- paths & params ---
DATADIR="${DATADIR:-./data/validator2}"
GENESIS="${GENESIS:-./genesis/mainnet.genesis.json}"
NETWORK_ID="${NETWORK_ID:-2325}"
BOOTNODE_KEY="${BOOTNODE_KEY:-./data/bootnode.key}"
JWT_FILE="${JWT_FILE:-./jwt.hex}"
PASSWORD_FILE="${PASSWORD_FILE:-./password.txt}"
COINBASE_FILE="$DATADIR/.coinbase"
PORT="${PORT:-30303}"
HTTP_ADDR="${HTTP_ADDR:-0.0.0.0}"
HTTP_PORT="${HTTP_PORT:-8545}"
WS_PORT="${WS_PORT:-8546}"
AUTHRPC_ADDR="${AUTHRPC_ADDR:-127.0.0.1}"
AUTHRPC_PORT="${AUTHRPC_PORT:-8551}"
NAT="${NAT:-extip:$(curl -s https://api.ipify.org || echo 127.0.0.1)}"
BOOTNODE_ENODE="${BOOTNODE_ENODE:-}"

mkdir -p "$DATADIR"
touch "$PASSWORD_FILE"
if [[ ! -s "$JWT_FILE" ]]; then
  echo "Generating jwt.hex"
  openssl rand -hex 32 > "$JWT_FILE"
fi

# Init if needed
if [[ ! -d "$DATADIR/geth" ]]; then
  echo "Initializing genesis..."
  geth --datadir "$DATADIR" init "$GENESIS"
fi

# Coinbase (signer) address
if [[ ! -s "$COINBASE_FILE" ]]; then
  echo "Missing $COINBASE_FILE. Run 01_make_accounts.sh first."
  exit 1
fi
COINBASE="$(cat "$COINBASE_FILE")"

# If we have a bootnode key, compute the enode (optional helper)
if [[ -z "$BOOTNODE_ENODE" && -s "$BOOTNODE_KEY" ]]; then
  # Run ephemeral bootnode to print ENR, or provide your static enode manually
  echo "Tip: start bootnode separately: bootnode -nodekey $BOOTNODE_KEY -addr :30301"
fi

# --- run geth ---
# Security note:
#  * Do NOT expose personal API over HTTP.
#  * We unlock via IPC on startup, then drop into normal sealing.
echo "Starting validator node..."

geth \
  --datadir "$DATADIR" \
  --networkid "$NETWORK_ID" \
  --port "$PORT" \
  --syncmode "full" \
  --gcmode "full" \
  --http --http.addr "$HTTP_ADDR" --http.port "$HTTP_PORT" \
  --http.api "eth,net,web3" \
  --ws --ws.addr "$HTTP_ADDR" --ws.port "$WS_PORT" --ws.api "eth,net,web3" \
  --authrpc.addr "$AUTHRPC_ADDR" --authrpc.port "$AUTHRPC_PORT" --authrpc.jwtsecret "$JWT_FILE" \
  --nat "$NAT" \
  $( [[ -n "$BOOTNODE_ENODE" ]] && echo --bootnodes "$BOOTNODE_ENODE" ) \
  --mine --miner.etherbase "$COINBASE" \
  --allow-insecure-unlock=false \
  --ipcdisable=false \
  --metrics --pprof.addr "127.0.0.1" --pprof

# Note: we do NOT pass --unlock over CLI to avoid leaking via process list / HTTP.
