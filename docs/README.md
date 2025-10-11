# Your Chain (Geth 1.13.11, Clique)

## Overview
This repo contains a minimal EVM PoA network based on geth v1.13.11 with Clique.
- Consensus / networking / storage: **upstream geth**, pinned image in Docker.
- Transaction & block formats: see `docs/BLOCK_TX_FORMATS.en.md`.
- Chain spec (genesis): `configs/genesis.json`.
- CLI / run scripts: `scripts/*.sh`, `Makefile`.
- State DB and storage: `docs/STATE_DB.en.md`.
- Tests: `tests/*.js` (see also `docs/TESTS.en.md`).

## Quick start (local)
```bash
make check
make keys
make static
make init
make bootnode    # window 1
make v1          # window 2
make v2          # window 3
# optional:
make rpc
make smoke

## split.js
geth attach node/validator1/geth.ipc --exec 'loadScript("scripts/split/split.js")'
# или systemd: scripts/split/split.service
