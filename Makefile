.PHONY: check keys bootnode static init v1 v2 rpc smoke

check:         ; ./scripts/00_check_versions.sh
keys:          ; ./scripts/01_make_accounts.sh && ./scripts/02_make_bootnode_key.sh
static:        ; ./scripts/03_render_static_nodes.sh
init:          ; ./scripts/04_init_datadirs.sh
bootnode:      ; ./scripts/05_run_bootnode.sh
v1:            ; ./scripts/06_run_validator1.sh
v2:            ; ./scripts/07_run_validator2.sh
rpc:           ; ./scripts/08_run_rpc.sh
smoke:         ; ./scripts/10_curl_rpc_smoke.sh


.PHONY: contracts
contracts:
	cd contracts && npx hardhat compile

deploy-contracts:
	cd contracts && npx hardhat run deploy/deploy_all.js --network mcn