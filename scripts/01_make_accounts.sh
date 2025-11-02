#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

ensure_dir "$KEYSTORE_DIR"
ensure_password_file "$COINBASE_PASSWORD_FILE"
chmod_700 "$VALIDATOR_DIR" "$KEYSTORE_DIR"

if [[ -s "$COINBASE_FILE" ]]; then
  ylw "Уже есть ${COINBASE_FILE}, пропускаем создание аккаунта."
else
  grn "Создаю новый аккаунт валидатора (без пустых паролей)…"
  "$GETH_BIN" account new \
    --datadir "$VALIDATOR_DIR" \
    --keystore "$KEYSTORE_DIR" \
    --password "$COINBASE_PASSWORD_FILE" >/dev/null

  COINBASE_ADDR="$(get_coinbase_addr "$KEYSTORE_DIR")"
  echo "$COINBASE_ADDR" > "$COINBASE_FILE"
  chmod_600 "$COINBASE_FILE"
  grn "Готово. Coinbase: $COINBASE_ADDR"
fi
