from fastapi import Depends, FastAPI, HTTPException, status
from fastapi.responses import JSONResponse
from .auth import require_api_token
from .ib import connect_with_retry, get_last_price, is_connected

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

    if last_price is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Price not available",
        )

    return JSONResponse({"symbol": symbol.upper(), "price": last_price})
