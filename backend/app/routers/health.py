from fastapi import APIRouter

router = APIRouter(tags=["health"])


@router.get("/health", summary="Czy API działa")
def health() -> dict[str, str]:
    return {"status": "ok"}
