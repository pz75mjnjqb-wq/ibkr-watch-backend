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
