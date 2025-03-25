from pydantic import BaseModel
from typing import List

class ExerciseLogEntry(BaseModel):
    exercise_type: str
    duration_minutes: int
    calories_burned: int
    target_calories: int

class ExerciseLogs(BaseModel):
    id: str | None
    user_id: str
    date: str
    exercises: List[ExerciseLogEntry]
