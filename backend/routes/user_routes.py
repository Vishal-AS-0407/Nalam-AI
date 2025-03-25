from fastapi import APIRouter, HTTPException
from database import db
from models.user_model import User
from bson import ObjectId

router = APIRouter()

@router.post("/")
async def create_user(user: User):
    user_dict = user.dict()
    result = await db["users"].insert_one(user_dict)
    return {"id": str(result.inserted_id)}

@router.get("/{user_id}")
async def get_user(user_id: str):
    user = await db["users"].find_one({"_id": ObjectId(user_id)})
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    user["_id"] = str(user["_id"])
    return user

@router.get("/user/{email}")
async def get_user(email: str):
    user = await db["users"].find_one({"email": email})
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    user["_id"] = str(user["_id"])  # Convert ObjectId to string
    return user

@router.put("/{user_id}")
async def update_user(user_id: str, updated_user: User):
    result = await db["users"].update_one(
        {"_id": ObjectId(user_id)},
        {"$set": updated_user.dict()}
    )
    if result.matched_count == 0:
        raise HTTPException(status_code=404, detail="User not found")
    return {"detail": "User updated successfully"}

@router.delete("/{user_id}")
async def delete_user(user_id: str):
    result = await db["users"].delete_one({"_id": ObjectId(user_id)})
    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="User not found")
    return {"detail": "User deleted successfully"}
