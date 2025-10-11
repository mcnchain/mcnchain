#!/usr/bin/env bash
set -euo pipefail
RPC=${1:-http://127.0.0.1:8545}
curl -s -H "content-type: application/json" -d '{"jsonrpc":"2.0","id":1,"method":"eth_chainId","params":[]}' $RPC; echo
curl -s -H "content-type: application/json" -d '{"jsonrpc":"2.0","id":2,"method":"net_peerCount","params":[]}' $RPC; echo
curl -s -H "content-type: application/json" -d '{"jsonrpc":"2.0","id":3,"method":"eth_blockNumber","params":[]}' $RPC; echo
