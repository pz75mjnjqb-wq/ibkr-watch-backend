#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR=${TARGET_DIR:-"/opt/ibkr-watch-backend"}
API_URL=${API_URL:-"http://127.0.0.1:8000"}

if [[ ! -f "$TARGET_DIR/.env" ]]; then
  echo "Missing $TARGET_DIR/.env" >&2
  exit 1
fi

API_TOKEN=$(grep '^API_TOKEN=' "$TARGET_DIR/.env" | cut -d= -f2-)
if [[ -z "$API_TOKEN" ]]; then
  echo "API_TOKEN missing in .env" >&2
  exit 1
fi

health_code=$(curl -s -o /tmp/health.json -w "%{http_code}" "$API_URL/health")
if [[ "$health_code" != "200" ]]; then
  echo "Health check failed with status $health_code" >&2
  exit 1
fi

unauth_code=$(curl -s -o /dev/null -w "%{http_code}" "$API_URL/price/AAPL")
if [[ "$unauth_code" != "401" ]]; then
  echo "Expected 401 without token, got $unauth_code" >&2
  exit 1
fi

auth_code=$(curl -s -o /tmp/price.json -w "%{http_code}" -H "X-API-Token: $API_TOKEN" "$API_URL/price/AAPL")
if [[ "$auth_code" != "200" ]]; then
  echo "Expected 200 with token, got $auth_code" >&2
  exit 1
fi

echo "SUCCESS: Health + auth checks passed."
