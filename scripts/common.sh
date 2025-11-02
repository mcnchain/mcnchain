#!/usr/bin/env bash
set -euo pipefail

# ── Безопасные umask и строгие ошибки ──────────────────────────────────────────
umask 077

# ── Цвета для читаемости ──────────────────────────────────────────────────────
red() { printf "\033[31m%s\033[0m\n" "$*"; }
grn() { printf "\033[32m%s\033[0m\n" "$*"; }
ylw() { printf "\033[33m%s\033[0m\n" "$*"; }

# ── .env ──────────────────────────────────────────────────────────────────────
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${ROOT_DIR}/.env"
[[ -f "$ENV_FILE" ]] || { red "Нет .env — скопируй scripts/00_env.example → .env и заполни"; exit 1; }
# shellcheck disable=SC1090
source "$ENV_FILE"

require() { local v="$1"; [[ -n "${!v:-}" ]] || { red "Переменная $v не задана в .env"; exit 1; }; }

# ── Глобальные проверки ───────────────────────────────────────────────────────
require NETWORK            # mainnet|testnet
require CHAIN_ID
require BOOTNODE_PORT
require HTTP_PORT
require WS_PORT
require DATA_DIR
require COINBASE_PASSWORD_FILE

# ── Папки/права ───────────────────────────────────────────────────────────────
ensure_dir() { mkdir -p "$1"; }
ensure_file() { [[ -f "$1" ]] || { red "Файл не найден: $1"; exit 1; }; }
chmod_600() { chmod 600 "$1" || true; }
chmod_700() { chmod 700 "$1" || true; }

# ── Без пустых паролей (EPC) ──────────────────────────────────────────────────
ensure_password_file() {
  local f="$1"
  ensure_file "$f"
  local p; p="$(tr -d '\n\r\t ' < "$f")"
  [[ -n "$p" ]] || { red "Пароль пустой в $f (EPC)"; exit 1; }
  chmod_600 "$f"
}

# ── Пути genesis (IPL) ────────────────────────────────────────────────────────
GENESIS_PATH="${ROOT_DIR}/networks/${NETWORK}/genesis.json"
ensure_file "$GENESIS_PATH"

# ── Вспомогалка: извлечь coinbase надёжно (IRQ) ───────────────────────────────
# Вместо кривых regex берём адрес из keystore или geth account list
get_coinbase_addr() {
  local ks="$1"
  # Берём самый свежий keyfile, парсим адрес из имени (стандарт Geth)
  local keyfile
  keyfile="$(ls -1t "$ks"/* | head -n1)"
  [[ -n "$keyfile" ]] || { red "Keystore пуст: $ks"; exit 1; }
  # Имя файла содержит адрес без '0x' — выдёргиваем надёжно:
  local addr
  addr="$(basename "$keyfile" | sed -E 's/^UTC--[0-9-:T]+Z--([0-9a-fA-F]{40})$/0x\1/')"
  [[ "$addr" =~ ^0x[0-9a-fA-F]{40}$ ]] || { red "Не удалось извлечь адрес из $keyfile"; exit 1; }
  echo "$addr"
}
