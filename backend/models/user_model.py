from pydantic import BaseModel, EmailStr
from typing import List, Optional
from datetime import datetime

class PatientData(BaseModel):
    current_diagnosis: List[str]
    medications: List[str]
    dietary_preferences: List[str]
    exercise_routine: List[str]
    health_goals: List[str]
    current_symptoms: List[str]

class User(BaseModel):
    id: Optional[str]  # MongoDB will auto-generate this if not provided
    email: EmailStr
    full_name: str
    phone: str
    age: int
    profession: str
    patient_data: Optional[PatientData]
    created_at: Optional[datetime]  # Automatically set current date when creating a user
