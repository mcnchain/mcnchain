# split.js — распределение комиссий
- Назначение: off-chain деление комиссий/чаевых валидатора.
- Запуск: `geth attach node/validator1/geth.ipc --exec 'loadScript("scripts/split/split.js")'`
- Автозапуск через systemd: см. `split.service`
- Политика: SHARES (валидаторы 40%, burn 30%, devs 20%, eco 10%)
- Исключения: транзакции coinbase не попадают в пул распределения
- Безопасность: приватные ключи не хардкодятся; скрипт шлёт выплаты от coinbase