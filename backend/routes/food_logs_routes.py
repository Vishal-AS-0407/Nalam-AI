from fastapi import APIRouter, HTTPException
from bson import ObjectId  # Import ObjectId to handle MongoDB's _id
from models.food_logs_model import FoodLogs
from database import db

router = APIRouter()

# Helper function to validate ObjectId
def is_valid_object_id(id_str: str) -> bool:
    try:
        ObjectId(id_str)
        return True
    except Exception:
        return False

# Create Food Log
@router.post("/")
async def create_food_log(log: FoodLogs):
    log_dict = log.dict()
    result = await db["food_logs"].insert_one(log_dict)
    return {"id": str(result.inserted_id)}

# Get Food Logs by user_id
@router.get("/{user_id}")
async def get_food_logs(user_id: str):
    # Validate if the user_id is a valid ObjectId
    if not is_valid_object_id(user_id):
        raise HTTPException(status_code=400, detail="Invalid user_id format")
    
    try:
        # Convert user_id to ObjectId
        user_id = ObjectId(user_id)
        
        # Query the database
        logs = await db["food_logs"].find({"user_id": str(user_id)}).to_list(length=100)
        
        # Check if logs exist
        if not logs:
            raise HTTPException(status_code=404, detail="Food logs not found")
        
        # Format the logs for output
        for log in logs:
            log["_id"] = str(log["_id"])  # Convert ObjectId to string
        
        return logs
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching food logs: {str(e)}")

# Update Food Log by log_id
@router.put("/{log_id}")
async def update_food_log(log_id: str, updated_log: FoodLogs):
    try:
        log_id = ObjectId(log_id)  # Convert log_id to ObjectId
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid log ID format")

    result = await db["food_logs"].update_one(
        {"_id": log_id},
        {"$set": updated_log.dict()}
    )

    if result.matched_count == 0:
        raise HTTPException(status_code=404, detail="Log not found")

    return {"detail": "Food log updated successfully"}

# Delete Food Log by log_id
@router.delete("/{log_id}")
async def delete_food_log(log_id: str):
    try:
        log_id = ObjectId(log_id)  # Convert log_id to ObjectId
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid log ID format")

    result = await db["food_logs"].delete_one({"_id": ObjectId(log_id)})


    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Log not found")

    return {"detail": "Food log deleted successfully"}
