from pydantic import BaseModel
from typing import Dict, List, Optional
from datetime import datetime

class FoodLogs(BaseModel):
    id: Optional[str]
    user_id: str
    date: datetime  # Using datetime instead of str
    meals: Dict[str, List[str]]
    total_calories: int
