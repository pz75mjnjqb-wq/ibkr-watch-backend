import os
from fastapi import Header, HTTPException, status


def require_api_token(x_api_token: str | None = Header(default=None)) -> None:
    expected = os.getenv("API_TOKEN")
    if not expected:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="API token not configured",
        )
    if not x_api_token or x_api_token != expected:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid API token",
        )
