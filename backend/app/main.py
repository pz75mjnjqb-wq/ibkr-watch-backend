from fastapi import Depends, FastAPI, HTTPException, status
from fastapi.responses import JSONResponse
from .auth import require_api_token
from .ib import (
    connect_with_retry,
    get_last_price,
    is_connected,
    last_connect_attempt,
    last_error,
)

app = FastAPI(title="IBKR Watch Backend", version="1.0.0")


@app.on_event("startup")
async def startup_event() -> None:
    try:
        await connect_with_retry()
    except Exception:
        # Connection can be established later by endpoints.
        pass


@app.get("/health")
async def health() -> JSONResponse:
    return JSONResponse(
        {
            "status": "ok",
            "ib_connected": is_connected(),
            "ib_last_connect_attempt": last_connect_attempt(),
            "ib_last_error": last_error(),
        }
    )


@app.get("/price/{symbol}", dependencies=[Depends(require_api_token)])
async def price(symbol: str) -> JSONResponse:
    try:
        last_price = await get_last_price(symbol)
    except Exception as exc:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=str(exc),
        ) from exc

    return JSONResponse({"symbol": symbol.upper(), "price": last_price})
