#!/usr/bin/env bash
set -euo pipefail
mkdir -p node/validator1 node/validator2
echo "${PASSWORD_VAL1:-pass123}" > node/validator1/password.txt
echo "${PASSWORD_VAL2:-pass123}" > node/validator2/password.txt

ADDR1=$(geth account new --datadir node/validator1 --password node/validator1/password.txt | awk '/Public address/ {print $4}')
ADDR2=$(geth account new --datadir node/validator2 --password node/validator2/password.txt | awk '/Public address/ {print $4}')
echo -n "$ADDR1" > node/validator1/address.txt
echo -n "$ADDR2" > node/validator2/address.txt
echo "VAL1=$ADDR1"
echo "VAL2=$ADDR2"
