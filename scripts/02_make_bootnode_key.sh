#!/usr/bin/env bash
set -euo pipefail
mkdir -p node/bootnode
bootnode -genkey node/bootnode/boot.key
ENODE=$(bootnode -nodekey node/bootnode/boot.key -writeaddress)
echo -n "$ENODE" > node/bootnode/enode.txt
echo "ENODE=$ENODE"
