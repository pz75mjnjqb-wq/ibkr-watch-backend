from fastapi import FastAPI, Header, HTTPException
from typing import Optional
import random

app = FastAPI()

@app.get("/")
def root():
    return {"message": "Mock IBKR Backend is running. Endpoints: /health, /price/{symbol}"}

@app.get("/health")
def health():
    # Mock: Always connected
    return {"status": "ok", "ib_connected": True}

@app.get("/price/{symbol}")
def get_price(symbol: str, x_api_token: Optional[str] = Header(None, alias="X-API-Token")):
    if not x_api_token:
        raise HTTPException(status_code=401, detail="Missing API Token")
    
    # Mock: Generate a deterministic "random" price based on the symbol
    # so it stays consistent for the same symbol but differs between symbols.
    random.seed(symbol)
    base_price = random.uniform(10, 500)
    
    # Add slight jitter to simulate live market
    jitter = random.uniform(-0.5, 0.5)
    price = base_price + jitter
    
    return {
        "symbol": symbol.upper(), 
        "price": round(price, 2)
    }