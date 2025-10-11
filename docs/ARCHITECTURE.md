# Архитектура сети (Geth 1.13.11, Clique)
Роли узлов: bootnode (peer discovery), 2×validators (sealers), rpc-node (public API).
P2P: devp2p, static-nodes.json указывает bootnode. Консенсус: Clique(period=2, epoch=30000).
RPC-экспорт: eth, net, web3, txpool, debug (rpc-node).
Журналирование: stdout + systemd. Метрики (по желанию) --metrics/--pprof.
