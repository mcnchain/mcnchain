#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

ensure_dir "$BOOTNODE_DIR"
BOOT_KEY="${BOOTNODE_DIR}/boot.key"
[[ -f "$BOOT_KEY" ]] || { ylw "Генерю boot.key"; bootnode -genkey "$BOOT_KEY"; }
chmod_600 "$BOOT_KEY"

# Запуск (слушаем только внешний UDP/TCP порт бутона)
exec bootnode -nodekey "$BOOT_KEY" -addr ":${BOOTNODE_PORT}"
