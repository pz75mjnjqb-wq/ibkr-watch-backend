# Changelog

## v0.1.0

### Backend
- FastAPI backend with IB Gateway connectivity and `/health`, `/price/{symbol}` endpoints.
- CI-safe test isolation (no live IBKR connections in CI).

### iOS
- SwiftUI app (iOS 17+) with Status and Prices screens.
- Keychain-backed API token and configurable base URL.

### Watch
- Companion watchOS app using WCSession with cached payloads.
- Minimal watch UI showing backend/IB status and latest prices.
