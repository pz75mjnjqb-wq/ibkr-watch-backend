#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR=${TARGET_DIR:-"/opt/ibkr-watch-backend"}
ENV_FILE="$TARGET_DIR/.env"

TOKEN=$(openssl rand -hex 32)

if [[ ! -f "$ENV_FILE" ]]; then
  echo "$TOKEN"
  echo "No .env found. Copy this token into your .env as API_TOKEN." >&2
  exit 0
fi

if grep -q '^API_TOKEN=' "$ENV_FILE"; then
  sed -i "s/^API_TOKEN=.*/API_TOKEN=$TOKEN/" "$ENV_FILE"
else
  echo "API_TOKEN=$TOKEN" >> "$ENV_FILE"
fi

echo "API_TOKEN rotated."
