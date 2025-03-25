from fastapi import APIRouter, HTTPException
from bson import ObjectId
from models.health_model import HealthData
from database import db

router = APIRouter()

# Validate ObjectId
def is_valid_object_id(id_str: str) -> bool:
    try:
        ObjectId(id_str)
        return True
    except:
        return False

# Store Health Data
@router.post("/")
async def create_health_data(data: HealthData):
    data_dict = data.dict()
    result = await db["health"].insert_one(data_dict)
    return {"id": str(result.inserted_id)}

# Retrieve Health Data for User
@router.get("/{user_id}")
async def get_health_data(user_id: str):
    if not is_valid_object_id(user_id):
        raise HTTPException(status_code=400, detail="Invalid user_id format")

    logs = await db["health"].find({"user_id": user_id}).to_list(100)
    if not logs:
        raise HTTPException(status_code=404, detail="No health data found")

    for log in logs:
        log["_id"] = str(log["_id"])
    return logs
