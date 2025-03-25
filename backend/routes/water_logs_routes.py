from fastapi import APIRouter, HTTPException
from bson import ObjectId  # Import ObjectId to handle MongoDB's _id
from models.water_logs_model import WaterLogs
from database import db

router = APIRouter()

# Helper function to validate ObjectId
def is_valid_object_id(id_str: str) -> bool:
    try:
        ObjectId(id_str)
        return True
    except Exception:
        return False

# Create Water Log
@router.post("/")
async def create_water_log(log: WaterLogs):
    log_dict = log.dict()
    result = await db["water_logs"].insert_one(log_dict)
    return {"id": str(result.inserted_id)}

# Get Water Logs by user_id
@router.get("/{user_id}")
async def get_water_logs(user_id: str):
    if not is_valid_object_id(user_id):
        raise HTTPException(status_code=400, detail="Invalid user_id format")

    try:
        user_id = ObjectId(user_id)
        logs = await db["water_logs"].find({"user_id": str(user_id)}).to_list(length=100)
        if not logs:
            raise HTTPException(status_code=404, detail="Water logs not found")

        for log in logs:
            log["_id"] = str(log["_id"])
        return logs
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching water logs: {str(e)}")

# Update Water Log by log_id
@router.put("/{log_id}")
async def update_water_log(log_id: str, updated_log: WaterLogs):
    try:
        log_id = ObjectId(log_id)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid log ID format")

    result = await db["water_logs"].update_one(
        {"_id": log_id},
        {"$set": updated_log.dict()}
    )

    if result.matched_count == 0:
        raise HTTPException(status_code=404, detail="Log not found")

    return {"detail": "Water log updated successfully"}

# Delete Water Log by log_id
@router.delete("/{log_id}")
async def delete_water_log(log_id: str):
    try:
        log_id = ObjectId(log_id)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid log ID format")

    result = await db["water_logs"].delete_one({"_id": ObjectId(log_id)})

    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Log not found")

    return {"detail": "Water log deleted successfully"}
