from typing import Literal
from pydantic import BaseModel, Field


DimensionCutoffMap = dict[str, dict[str, float]]


class ItemResponse(BaseModel):
    item_number: int = Field(ge=1, le=15)
    value: int = Field(ge=0, le=6)


class SubmitAssessmentRequest(BaseModel):
    assessment_id: str
    responses: list[ItemResponse] = Field(min_length=15, max_length=15)


class DimensionMeans(BaseModel):
    exhaustion: float
    cynicism: float
    efficacy: float


class BurnoutResult(BaseModel):
    exhaustion_mean: float
    cynicism_mean: float
    efficacy_mean: float
    exhaustion_level: Literal["low", "medium", "high"]
    cynicism_level: Literal["low", "medium", "high"]
    efficacy_level: Literal["low", "medium", "high"]
    risk_level: Literal["low", "medium", "high"]


class AssessmentResponse(BaseModel):
    assessment_id: str
    result: BurnoutResult
