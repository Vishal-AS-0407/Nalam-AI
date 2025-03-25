from pydantic import BaseModel
from typing import Optional

class UserProfile(BaseModel):
    user_id: str
    weight: Optional[float] = None
    height: Optional[float] = None
    exercise_level: Optional[str] = None
    blood_pressure: Optional[str] = None
    heart_rate: Optional[float] = None
    sleep_duration: Optional[float] = None
    family_history: Optional[str] = None
    stress_level: Optional[str] = None
    medicine_allergies: Optional[bool] = None
