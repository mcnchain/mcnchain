# MCN Chain

**MCN Chain** — это независимый **EVM-совместимый блокчейн**, ориентированный на низкие комиссии, поддержку DeFi, NFT, DAO и AI-интеграции.  
В репозитории находятся все необходимые материалы для запуска сети и работы со смарт-контрактами.

---

## 📂 Структура репозитория

MCN/
├── block-chain/ # файлы для запуска и настройки сети
│ ├── bothnode/
│ ├── node1/
│ ├── node2/
│ ├── genesis-mainnet.json
│ ├── genesis-testnet.json
│ ├── split.js
│ └── README.md # инструкция по нодам
│
├── smart-contracts/ # Hardhat-проект со смарт-контрактами
│ ├── contracts/
│ ├── scripts/
│ ├── test/
│ ├── hardhat.config.js
│ ├── .env.example
│ └── README.md # инструкция по деплою
│
├── LICENSE
└── README.md # этот файл



---

## 🌐 Сеть MCN Chain

### Mainnet
- **Chain ID:** `2325`
- **Currency Symbol:** `MCN`
- **RPC URL:** `https://rpc.mcnchain.org`
- **Explorer:** [https://explorer.mcnchain.org](https://explorer.mcnchain.org)

## Testnet
- **Chain ID:** `1337`
- **Currency Symbol:** `tMCN`
- **RPC URL:** `https://rpc-testnet.mcnchain.org`
- **Explorer:** [https://explorer-testnet.mcnchain.org](https://explorer-testnet.mcnchain.org)

---

## 🔑 Токеномика (Mainnet)

- **Ticker:** MCN  
- **Эмиссия:** 40 000 000 MCN  

**Комиссии:**
- Перевод токенов: $0.02  
- Вызов смарт-контракта: $0.10  
- Развёртывание контракта: $0.50  
- Swap на DEX: $0.10  
- Минт NFT: $0.05  
- Голосование в DAO: $0.01  
- Кроссчейн Bridge: 0.07%  

**Распределение комиссии:**
- 40% — валидаторы  
- 30% — сжигание токенов  
- 20% — Разработчикам  
- 10% — фонд развития  


---

## 🚀 Быстрый старт

### Запуск ноды
```bash
cd block-chain
geth --datadir node1 init genesis-mainnet.json
geth --datadir node1 --networkid 2325 --http --http.port 8545


cd smart-contracts
npm install
npx hardhat run scripts/deploy.js --network mcn