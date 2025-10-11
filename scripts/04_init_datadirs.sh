#!/usr/bin/env bash
set -euo pipefail
geth --datadir node/validator1 init configs/genesis.json
geth --datadir node/validator2 init configs/genesis.json
geth --datadir node/rpc        init configs/genesis.json
