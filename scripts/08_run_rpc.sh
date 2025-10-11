#!/usr/bin/env bash
set -euo pipefail
geth --config configs/rpc.toml \
  --syncmode full --networkid ${NETWORK_ID:-23251} \
  --nat none --http --ws
