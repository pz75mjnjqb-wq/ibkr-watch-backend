#!/usr/bin/env bash
set -euo pipefail

ufw default deny incoming
ufw default allow outgoing

ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp

# If you expose FastAPI directly without nginx, allow 8000.
# ufw allow 8000/tcp

ufw --force enable
ufw status verbose
