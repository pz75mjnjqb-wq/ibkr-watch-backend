# IBKR Watch Backend
![tests](https://github.com/pz75mjnjqb-wq/ibkr-watch-backend/actions/workflows/tests.yml/badge.svg)

Backend for an iPhone/Apple Watch app that talks to Interactive Brokers (IBKR) via IB Gateway.
The mobile apps never connect to IBKR directly.

## Architecture

- IB Gateway runs headless in Docker (internal network only).
- FastAPI backend connects to the gateway and exposes REST endpoints.
- Optional Nginx reverse proxy on port 80 (HTTP only for now).

## Requirements

- Ubuntu 22.04 LTS VPS
- Docker + Docker Compose
- Optional: UFW + Nginx

## Setup

1) Copy `.env.example` to `.env` and fill in values:

```
cp .env.example .env
```

2) Start the stack:

```
docker compose up -d --build
```

3) Optional Nginx reverse proxy:

```
docker compose --profile nginx up -d --build
```

## VPS Deploy (Ubuntu 22.04)

Run the bootstrap once on a fresh VPS:

```
sudo ./scripts/vps_bootstrap.sh
```

Deploy the app:

```
sudo ./scripts/deploy.sh
```

Smoke test (local only):

```
sudo ./scripts/smoke.sh
```

## Security

- API port is bound to `127.0.0.1:8000` and not reachable externally.
- Public ports: 22, 80, 443 only.
- API Token (`X-API-Token`) is required for `/price`.
- Disable SSH password auth; use SSH keys.
- Fail2ban is enabled by `scripts/vps_bootstrap.sh`.
- Nginx applies rate limiting (10 req/s, burst 20) and basic security headers.

## TLS (Optional)

Recommended: install certbot on the host and terminate TLS in Nginx.

```
sudo apt-get update
sudo apt-get install -y certbot python3-certbot-nginx
```

Option A: Nginx HTTP-01 (recommended)

```
sudo certbot --nginx -d your-domain.example
```

Ensure Nginx is running with the profile:

```
docker compose --profile nginx up -d --build
```

Verify:

- `https://your-domain.example/health` returns 200
- `http://your-domain.example` redirects to HTTPS

Option B: nginx-proxy-manager (not recommended unless required)

- Run NPM separately and proxy to this service on port 80.

## Observability / Logs

- API logs: `docker logs -f ibkr-api`
- Gateway logs: `docker logs -f ibgateway`
- Nginx logs: `docker logs -f ibkr-nginx`

## Troubleshooting

- Gateway login fails: verify `TWS_USERID`, `TWS_PASSWORD`, and `TRADING_MODE`.
- 2FA / session expired: log into IBKR portal and approve the session.
- No market data: verify IBKR market data subscriptions for the symbol.
- `/price` returns `null`: market closed or no market data permissions.

## Runbook

Restart all services:

```
docker compose restart
```

Check status:

```
docker ps
docker compose logs --tail 50 api
```

Rotate API token:

```
sudo ./scripts/rotate_token.sh
```

## API

### Health

```
GET /health
```

Response:

```
{
  "status": "ok",
  "ib_connected": true
}
```

Notes:

- `/health` is intentionally unauthenticated for simple liveness checks.

### Price

```
GET /price/{symbol}
```

Headers:

```
X-API-Token: <API_TOKEN>
```

Response:

```
{
  "symbol": "AAPL",
  "price": 123.45
}
```

## Environment Variables

See `.env.example`. Required:

- `TWS_USERID`, `TWS_PASSWORD`, `TRADING_MODE` (IB Gateway)
- `API_TOKEN` (backend auth)
- `IBKR_PORT`, `IBKR_CLIENT_ID`

The IB Gateway image uses specific environment variables. If these differ in your setup,
adjust `.env` accordingly based on the image documentation.

## Security Notes

- IBKR API port is not published externally.
- Only FastAPI is exposed (port 8000) or Nginx (port 80).
- Use a strong `API_TOKEN` and keep it private.
- Use UFW to restrict public ports.

## UFW (Optional)

```
./scripts/init-ufw.sh
```

Adjust allowed ports as needed.

## Notes

- The backend auto-reconnects to IB Gateway if the connection drops.
- Paper/Live mode is controlled via `TRADING_MODE`.
