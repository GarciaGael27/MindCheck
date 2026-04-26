from fastapi import APIRouter, Depends

from app.core.auth import get_current_user
from app.services.supabase import get_admin_client

router = APIRouter(prefix="/scores", tags=["scores"])


@router.get("/latest")
async def get_latest_score(user: dict = Depends(get_current_user)):
    db = get_admin_client()
    result = (
        db.table("burnout_scores")
        .select("*")
        .eq("user_id", user["sub"])
        .order("created_at", desc=True)
        .limit(1)
        .execute()
    )
    if not result.data:
        return None
    return result.data[0]


@router.get("/history")
async def get_score_history(
    limit: int = 10,
    user: dict = Depends(get_current_user),
):
    db = get_admin_client()
    result = (
        db.table("burnout_scores")
        .select("risk_level, exhaustion_mean, cynicism_mean, efficacy_mean, created_at")
        .eq("user_id", user["sub"])
        .order("created_at", desc=True)
        .limit(limit)
        .execute()
    )
    return result.data
