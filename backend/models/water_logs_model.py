from pydantic import BaseModel

class WaterLogs(BaseModel):
    id: str | None
    user_id: str
    date: str
    water_intake: dict  # {"quantity": int, "unit": str}
