# 🌐 AIKOL Mainnet

AIKOL — собственный EVM-совместимый блокчейн с интеграцией AI, низкими комиссиями и поддержкой Web3, NFT, DAO, DeFi.

---

## ✅ Параметры сети

| Параметр                | Значение                  |
|-------------------------|---------------------------|
| Chain ID                | `2325`              |
| Currency Symbol         | `MCN`                   |
| RPC URL                 | `http://localhost:8545` *(пример)* |
| Explorer URL            | (добавить позже)          |
| Genesis-файл            | `genesis-mainnet.json`    |

---

## 🛠 Деплой ноды (валидатора)

```bash
# 1. Инициализировать
geth --datadir ./mainnet init genesis-mainnet.json

# 2. Запустить ноду
geth --datadir node1 init genesis-mainnet.json
geth --datadir node1 --networkid 2325 --http --http.port 8545
```



## 📡 Bootnode / Seed-пиры

Для настройки публичных узлов необходимо:
- Получить enode через `admin.nodeInfo.enode`
- Использовать `--bootnodes <enode>` для соединения с основной сетью









