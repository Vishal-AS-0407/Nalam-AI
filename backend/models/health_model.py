from pydantic import BaseModel
from typing import Optional

class HealthData(BaseModel):
    user_id: str
    date: str
    steps: Optional[int] = None
    sleep: Optional[dict] = None
    heart_rate: Optional[float] = None
