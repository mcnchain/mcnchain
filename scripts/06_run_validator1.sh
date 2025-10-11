#!/usr/bin/env bash
set -euo pipefail
ADDR=$(cat node/validator1/address.txt)
PASS=node/validator1/password.txt
geth --config configs/validator1.toml \
  --miner.etherbase $ADDR \
  --unlock $ADDR --password $PASS \
  --syncmode full --networkid ${NETWORK_ID:-23251} \
  --nat none --mine --miner.threads 1 \
  --http --http.api eth,net,web3,txpool \
  --ws --ws.api   eth,net,web3,txpool
