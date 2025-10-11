# Tests
- `e2e_send_raw_tx.js`: send and confirm value transfer.
- `smoke_rpc.js`: basic JSON-RPC health.
- `clique_status.js`: signer metrics / sealing.
Run:
```bash
node tests/smoke_rpc.js
node tests/clique_status.js
RPC=http://127.0.0.1:8547 node tests/e2e_send_raw_tx.js