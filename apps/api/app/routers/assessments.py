from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from app.core.auth import get_current_user
from app.schemas.assessment import AssessmentResponse, SubmitAssessmentRequest
from app.services.scoring import build_burnout_result, compute_dimension_means
from app.services.supabase import get_admin_client

router = APIRouter(prefix="/assessments", tags=["assessments"])
bearer_scheme = HTTPBearer()


@router.post("/{assessment_id}/submit", response_model=AssessmentResponse)
async def submit_assessment(
    assessment_id: str,
    body: SubmitAssessmentRequest,
    user: dict = Depends(get_current_user),
):
    if body.assessment_id != assessment_id:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="assessment_id no coincide")

    db = get_admin_client()
    user_id = user["sub"]

    # Verify the assessment belongs to this user and is in progress
    assessment = (
        db.table("assessments")
        .select("id, user_id, status")
        .eq("id", assessment_id)
        .single()
        .execute()
    )
    if not assessment.data:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Assessment no encontrado")
    if assessment.data["user_id"] != user_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="No autorizado")
    if assessment.data["status"] != "started":
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="El assessment ya fue completado")

    # Load item→dimension mapping for MBI-SS
    items = (
        db.table("instrument_items")
        .select("item_number, dimension")
        .eq("instrument_id", _get_mbiss_instrument_id(db))
        .execute()
    )
    item_dimensions = {row["item_number"]: row["dimension"] for row in items.data}

    # Load cutoffs
    cutoffs_rows = (
        db.table("instrument_cutoffs")
        .select("dimension, low_threshold, high_threshold")
        .eq("instrument_id", _get_mbiss_instrument_id(db))
        .execute()
    )
    cutoffs = {
        row["dimension"]: {"low": row["low_threshold"], "high": row["high_threshold"]}
        for row in cutoffs_rows.data
    }

    # Compute scoring
    raw_responses = [r.model_dump() for r in body.responses]
    means = compute_dimension_means(raw_responses, item_dimensions)
    result = build_burnout_result(means, cutoffs)

    # Persist responses
    db.table("assessment_responses").insert(
        [{"assessment_id": assessment_id, "item_number": r.item_number, "value": r.value} for r in body.responses]
    ).execute()

    # Persist burnout score
    db.table("burnout_scores").insert(
        {
            "user_id": user_id,
            "assessment_id": assessment_id,
            "exhaustion_mean": result.exhaustion_mean,
            "cynicism_mean": result.cynicism_mean,
            "efficacy_mean": result.efficacy_mean,
            "exhaustion_level": result.exhaustion_level,
            "cynicism_level": result.cynicism_level,
            "efficacy_level": result.efficacy_level,
            "risk_level": result.risk_level,
        }
    ).execute()

    # Mark assessment as completed
    db.table("assessments").update({"status": "completed"}).eq("id", assessment_id).execute()

    # Detect and store crisis event if risk is high
    if result.risk_level == "high":
        db.table("crisis_events").insert(
            {
                "user_id": user_id,
                "assessment_id": assessment_id,
                "severity": "warning",
                "trigger_type": "assessment",
            }
        ).execute()

    return AssessmentResponse(assessment_id=assessment_id, result=result)


@router.post("/start")
async def start_assessment(user: dict = Depends(get_current_user)):
    db = get_admin_client()
    user_id = user["sub"]

    instrument_id = _get_mbiss_instrument_id(db)

    result = (
        db.table("assessments")
        .insert({"user_id": user_id, "instrument_id": instrument_id, "status": "started"})
        .select()
        .single()
        .execute()
    )
    return {"assessment_id": result.data["id"]}


def _get_mbiss_instrument_id(db) -> str:
    result = db.table("instruments").select("id").eq("code", "MBI_SS").single().execute()
    if not result.data:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Instrumento MBI-SS no encontrado")
    return result.data["id"]
