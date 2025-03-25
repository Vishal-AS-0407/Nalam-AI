# models/reports_model.py
from pydantic import BaseModel, Field
from datetime import date, datetime
from typing import Union ,Dict, Any

class Reports(BaseModel):
    user_id: str
    report_title: str
    report_content: Union[str, Dict[Any, Any]]
    date_created: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        json_encoders = {
            datetime: lambda dt: dt.isoformat(),
            date: lambda d: d.isoformat()
        }