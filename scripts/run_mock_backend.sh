#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(cd "$SCRIPT_DIR/.." && pwd)

cd "$ROOT_DIR"

echo "Starting Mock IBKR Backend on http://127.0.0.1:8000"
echo "Use API Token: 'any-string' for testing."
python3 -m uvicorn backend.mock_main:app --reload --host 127.0.0.1 --port 8000