import asyncio
import os
from ib_insync import IB, Stock

IBKR_HOST = os.getenv("IBKR_HOST", "ibgateway")
IBKR_PORT = int(os.getenv("IBKR_PORT", "4002"))
IBKR_CLIENT_ID = int(os.getenv("IBKR_CLIENT_ID", "1001"))

_ib = IB()
_connect_lock = asyncio.Lock()


async def connect_with_retry(max_attempts: int = 5) -> None:
    if _ib.isConnected():
        return

    async with _connect_lock:
        if _ib.isConnected():
            return

        for attempt in range(1, max_attempts + 1):
            try:
                await _ib.connectAsync(
                    host=IBKR_HOST,
                    port=IBKR_PORT,
                    clientId=IBKR_CLIENT_ID,
                    timeout=5,
                )
                if _ib.isConnected():
                    return
            except Exception:
                await asyncio.sleep(min(2**attempt, 10))

    raise RuntimeError("Unable to connect to IBKR gateway")


def is_connected() -> bool:
    return _ib.isConnected()


async def get_last_price(symbol: str) -> float | None:
    if not _ib.isConnected():
        await connect_with_retry()

    contract = Stock(symbol.upper(), "SMART", "USD")
    tickers = await _ib.reqTickersAsync(contract)
    if not tickers:
        return None

    ticker = tickers[0]
    price = ticker.marketPrice()
    if price is None or price != price:
        price = ticker.last

    if price is None or price != price:
        return None

    return float(price)
