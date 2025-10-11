#!/usr/bin/env bash
set -euo pipefail
VAL1=$(cat node/validator1/address.txt)
VAL2=$(cat node/validator2/address.txt)
ENODE=$(cat node/bootnode/enode.txt)
BOOT_IP=${BOOTNODE_IP:-127.0.0.1}
BOOT_PORT=${BOOTNODE_PORT:-30301}

python3 - <<'PY'
import json
def addrhex(a):
  a=a.strip().lower()
  return a[2:] if a.startswith('0x') else a
v1 = addrhex(open('node/validator1/address.txt').read())
v2 = addrhex(open('node/validator2/address.txt').read())
vanity = '00'*32
sign   = '00'*65
extra  = '0x'+vanity+v1+v2+sign
g = json.load(open('configs/genesis.json'))
g['extraData'] = extra
json.dump(g, open('configs/genesis.json','w'), indent=2)
print('extraData rendered for validators', v1, v2)
PY

echo "[\"enode://$ENODE@${BOOT_IP}:${BOOT_PORT}\"]" > configs/static-nodes.json
for d in node/validator1 node/validator2 node/rpc; do
  mkdir -p "$d/geth"
  cp configs/static-nodes.json "$d/geth/static-nodes.json"
done
