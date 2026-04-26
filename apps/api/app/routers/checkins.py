from datetime import date

from fastapi import APIRouter, Depends, HTTPException, status

from app.core.auth import get_current_user
from app.schemas.checkin import CheckinResponse, CreateCheckinRequest
from app.services.supabase import get_admin_client

router = APIRouter(prefix="/checkins", tags=["checkins"])


@router.post("/", response_model=CheckinResponse, status_code=status.HTTP_201_CREATED)
async def create_checkin(
    body: CreateCheckinRequest,
    user: dict = Depends(get_current_user),
):
    db = get_admin_client()
    user_id = user["sub"]
    checkin_date = body.checkin_date or date.today()

    # Prevent duplicate check-in for the same day
    existing = (
        db.table("daily_checkins")
        .select("id")
        .eq("user_id", user_id)
        .eq("checkin_date", str(checkin_date))
        .execute()
    )
    if existing.data:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Ya registraste tu check-in para hoy",
        )

    result = (
        db.table("daily_checkins")
        .insert(
            {
                "user_id": user_id,
                "mood": body.mood,
                "sleep_hours": body.sleep_hours,
                "stress_level": body.stress_level,
                "study_hours": body.study_hours,
                "notes": body.notes,
                "checkin_date": str(checkin_date),
            }
        )
        .select()
        .single()
        .execute()
    )
    return CheckinResponse(**result.data)


@router.get("/", response_model=list[CheckinResponse])
async def list_checkins(
    limit: int = 30,
    user: dict = Depends(get_current_user),
):
    db = get_admin_client()
    result = (
        db.table("daily_checkins")
        .select("*")
        .eq("user_id", user["sub"])
        .order("checkin_date", desc=True)
        .limit(limit)
        .execute()
    )
    return [CheckinResponse(**row) for row in result.data]
