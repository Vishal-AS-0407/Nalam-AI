
from pydantic import BaseModel, Field
from datetime import date, datetime
from typing import Union

class Medicines(BaseModel):
    user_id: str
    medicine_name: str
    about_medicine: Union[str, dict]
    date_created: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        json_encoders = {
            datetime: lambda dt: dt.isoformat(),
            date: lambda d: d.isoformat()
        }