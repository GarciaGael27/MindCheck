from datetime import date
from typing import Literal
from pydantic import BaseModel, Field


class CreateCheckinRequest(BaseModel):
    mood: int = Field(ge=1, le=5)
    sleep_hours: float = Field(ge=0, le=24)
    stress_level: int = Field(ge=1, le=5)
    study_hours: float = Field(ge=0, le=24)
    notes: str | None = Field(default=None, max_length=500)
    checkin_date: date | None = None


class CheckinResponse(BaseModel):
    id: str
    user_id: str
    mood: int
    sleep_hours: float
    stress_level: int
    study_hours: float
    notes: str | None
    checkin_date: str
    created_at: str
