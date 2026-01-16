#!/usr/bin/env bash
set -euo pipefail

REPO_URL=${REPO_URL:-"https://github.com/pz75mjnjqb-wq/ibkr-watch-backend.git"}
TARGET_DIR=${TARGET_DIR:-"/opt/ibkr-watch-backend"}

if [[ ${EUID} -ne 0 ]]; then
  echo "Please run as root (sudo)." >&2
  exit 1
fi

if [[ -d "$TARGET_DIR/.git" ]]; then
  git -C "$TARGET_DIR" pull --ff-only
else
  git clone "$REPO_URL" "$TARGET_DIR"
fi

cd "$TARGET_DIR"

if [[ ! -f .env ]]; then
  cp .env.example .env
  echo "Created .env from .env.example. Please edit secrets." >&2
fi

if grep -q "your_ibkr_username" .env || grep -q "your_ibkr_password" .env || grep -q "replace-with-long-random-token" .env; then
  echo "Default secrets detected in .env. Please update before deployment." >&2
  exit 1
fi

docker compose up -d --build

docker ps

docker compose logs --tail 50 api
