import os
from fastapi import Depends, FastAPI, HTTPException, status
from fastapi.responses import JSONResponse
from .auth import require_api_token
from . import ib

app = FastAPI(title="IBKR Watch Backend", version="1.0.0")


@app.on_event("startup")
async def startup_event() -> None:
    if os.getenv("SKIP_IB_CONNECT_ON_STARTUP") == "1":
        return
    try:
        await ib.connect_with_retry()
    except Exception:
        # Connection can be established later by endpoints.
        pass


@app.get("/health")
async def health() -> JSONResponse:
    return JSONResponse(
        {
            "status": "ok",
            "ib_connected": ib.is_connected(),
            "ib_last_connect_attempt": ib.last_connect_attempt(),
            "ib_last_error": ib.last_error(),
        }
    )


@app.get("/price/{symbol}", dependencies=[Depends(require_api_token)])
async def price(symbol: str) -> JSONResponse:
    try:
        last_price = await ib.get_last_price(symbol)
    except Exception as exc:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=str(exc),
        ) from exc

    return JSONResponse({"symbol": symbol.upper(), "price": last_price})
