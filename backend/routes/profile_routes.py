from fastapi import APIRouter, HTTPException, UploadFile, File, Form, Request
from bson import ObjectId
from typing import Optional
from models.profile import UserProfile
from database import db

router = APIRouter()

def is_valid_object_id(id_str: str) -> bool:
    try:
        ObjectId(id_str)
        return True
    except Exception:
        return False

@router.post("/create")
async def create_profile(
    user_id: str = Form(...),
    weight: Optional[float] = Form(None),
    height: Optional[float] = Form(None),
    exercise_level: Optional[str] = Form(None),
    blood_pressure: Optional[str] = Form(None),
    heart_rate: Optional[float] = Form(None),
    sleep_duration: Optional[float] = Form(None),
    family_history: Optional[str] = Form(None),
    stress_level: Optional[str] = Form(None),
    medicine_allergies: Optional[str] = Form(None)
):
    if not is_valid_object_id(user_id):
        raise HTTPException(status_code=400, detail="Invalid user_id format")

    user_object_id = ObjectId(user_id)

    # Check if profile exists
    existing_profile = await db["user_profile"].find_one({"user_id": user_object_id})
    if existing_profile:
        raise HTTPException(status_code=409, detail="Profile already exists")

    profile_data = {
        "user_id": user_object_id,  # Changed from _id to user_id
        "weight": weight,
        "height": height,
        "exercise_level": exercise_level,
        "blood_pressure": blood_pressure,
        "heart_rate": heart_rate,
        "sleep_duration": sleep_duration,
        "family_history": family_history,
        "stress_level": stress_level,
        "medicine_allergies": medicine_allergies,
    }

    result = await db["user_profile"].insert_one(profile_data)
    return {"detail": "Profile created successfully", "profile_id": str(result.inserted_id)}

@router.put("/update_profile/{user_id}")
async def update_profile(
    user_id: str,
    weight: Optional[float] = Form(None),
    height: Optional[float] = Form(None),
    exercise_level: Optional[str] = Form(None),
    blood_pressure: Optional[str] = Form(None),
    heart_rate: Optional[float] = Form(None),
    sleep_duration: Optional[float] = Form(None),
    family_history: Optional[str] = Form(None),
    stress_level: Optional[str] = Form(None),
    medicine_allergies: Optional[str] = Form(None)
):
    if not is_valid_object_id(user_id):
        raise HTTPException(status_code=400, detail="Invalid user_id format")

    user_object_id = ObjectId(user_id)

    # Changed from _id to user_id in the query
    existing_profile = await db["user_profile"].find_one({"user_id": user_object_id})
    if not existing_profile:
        # If profile doesn't exist, create it
        profile_data = {
            "user_id": user_object_id,
            "weight": weight,
            "height": height,
            "exercise_level": exercise_level,
            "blood_pressure": blood_pressure,
            "heart_rate": heart_rate,
            "sleep_duration": sleep_duration,
            "family_history": family_history,
            "stress_level": stress_level,
            "medicine_allergies": medicine_allergies,
        }
        await db["user_profile"].insert_one(profile_data)
        return {"detail": "Profile created successfully"}

    update_data = {}
    if weight is not None:
        update_data["weight"] = weight
    if height is not None:
        update_data["height"] = height
    if exercise_level is not None:
        update_data["exercise_level"] = exercise_level
    if blood_pressure is not None:
        update_data["blood_pressure"] = blood_pressure
    if heart_rate is not None:
        update_data["heart_rate"] = heart_rate
    if sleep_duration is not None:
        update_data["sleep_duration"] = sleep_duration
    if family_history is not None:
        update_data["family_history"] = family_history
    if stress_level is not None:
        update_data["stress_level"] = stress_level
    if medicine_allergies is not None:
        update_data["medicine_allergies"] = medicine_allergies

    if not update_data:
        raise HTTPException(status_code=400, detail="No valid fields to update")

    # Changed from _id to user_id in the query
    await db["user_profile"].update_one(
        {"user_id": user_object_id}, 
        {"$set": update_data}
    )
    return {"detail": "Profile updated successfully"}

@router.get("/{user_id}")
async def get_user_profile(user_id: str):
    if not is_valid_object_id(user_id):
        raise HTTPException(status_code=400, detail="Invalid user_id format")

    try:
        user_object_id = ObjectId(user_id)
        # Changed from _id to user_id in the query
        profile = await db["user_profile"].find_one({"user_id": user_object_id})

        if not profile:
            raise HTTPException(status_code=404, detail="Profile not found")

        profile["_id"] = str(profile["_id"])
        profile["user_id"] = str(profile["user_id"])
        return profile
    except Exception as e:
        print(f"Error fetching profile: {e}")
        raise HTTPException(status_code=500, detail="Internal Server Error")