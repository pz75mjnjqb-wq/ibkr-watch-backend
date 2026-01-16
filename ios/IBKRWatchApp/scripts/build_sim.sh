#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(cd "$SCRIPT_DIR/.." && pwd)

cd "$ROOT_DIR"

if [[ ! -d "IBKRWatchApp.xcodeproj" ]]; then
  echo "IBKRWatchApp.xcodeproj not found. Run ./scripts/generate.sh first." >&2
  exit 1
fi

xcodebuild \
  -project IBKRWatchApp.xcodeproj \
  -scheme IBKRWatchApp \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  CODE_SIGNING_ALLOWED=NO \
  build
