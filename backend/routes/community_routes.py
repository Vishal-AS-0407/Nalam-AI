from fastapi import APIRouter, HTTPException
from bson import ObjectId
from models.community_model import Post, Discussion, Event, Query
from database import db

router = APIRouter()

# Helper function to validate ObjectId
def is_valid_object_id(id_str: str) -> bool:
    try:
        ObjectId(id_str)
        return True
    except Exception:
        return False

# ------------------ Posts ------------------
@router.post("/posts")
async def create_post(post: Post):
    post_dict = post.dict()
    result = await db["posts"].insert_one(post_dict)
    return {"id": str(result.inserted_id)}

@router.get("/posts")
async def get_all_posts():
    posts = await db["posts"].find().to_list(100)
    for post in posts:
        post["_id"] = str(post["_id"])
    return posts

@router.get("/posts/{post_id}")
async def get_post(post_id: str):
    if not is_valid_object_id(post_id):
        raise HTTPException(status_code=400, detail="Invalid post ID format")
    post = await db["posts"].find_one({"_id": ObjectId(post_id)})
    if not post:
        raise HTTPException(status_code=404, detail="Post not found")
    post["_id"] = str(post["_id"])
    return post

@router.delete("/posts/{post_id}")
async def delete_post(post_id: str):
    if not is_valid_object_id(post_id):
        raise HTTPException(status_code=400, detail="Invalid post ID format")
    result = await db["posts"].delete_one({"_id": ObjectId(post_id)})
    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Post not found")
    return {"detail": "Post deleted successfully"}

# ------------------ Discussions ------------------
@router.post("/discussions")
async def create_discussion(discussion: Discussion):
    discussion_dict = discussion.dict()
    result = await db["discussions"].insert_one(discussion_dict)
    return {"id": str(result.inserted_id)}

@router.get("/discussions")
async def get_all_discussions():
    discussions = await db["discussions"].find().to_list(100)
    for discussion in discussions:
        discussion["_id"] = str(discussion["_id"])
    return discussions

@router.get("/discussions/{discussion_id}")
async def get_discussion(discussion_id: str):
    if not is_valid_object_id(discussion_id):
        raise HTTPException(status_code=400, detail="Invalid discussion ID format")
    discussion = await db["discussions"].find_one({"_id": ObjectId(discussion_id)})
    if not discussion:
        raise HTTPException(status_code=404, detail="Discussion not found")
    discussion["_id"] = str(discussion["_id"])
    return discussion

@router.put("/discussions/{discussion_id}")
async def update_discussion(discussion_id: str, updated_discussion: Discussion):
    if not is_valid_object_id(discussion_id):
        raise HTTPException(status_code=400, detail="Invalid discussion ID format")
    result = await db["discussions"].update_one(
        {"_id": ObjectId(discussion_id)}, {"$set": updated_discussion.dict()}
    )
    if result.matched_count == 0:
        raise HTTPException(status_code=404, detail="Discussion not found")
    return {"detail": "Discussion updated successfully"}

@router.put("/discussions/{discussion_id}/response")
async def add_response_to_discussion(discussion_id: str, response: dict):
    if not is_valid_object_id(discussion_id):
        raise HTTPException(status_code=400, detail="Invalid discussion ID format")
    result = await db["discussions"].update_one(
        {"_id": ObjectId(discussion_id)},
        {"$push": {"comments": response}}
    )
    if result.matched_count == 0:
        raise HTTPException(status_code=404, detail="Discussion not found")
    return {"detail": "Response added successfully"}


# ------------------ Events ------------------
@router.post("/events")
async def create_event(event: Event):
    event_dict = event.dict()
    result = await db["events"].insert_one(event_dict)
    return {"id": str(result.inserted_id)}

@router.get("/events")
async def get_all_events():
    events = await db["events"].find().to_list(100)
    for event in events:
        event["_id"] = str(event["_id"])
    return events

@router.get("/events/{event_id}")
async def get_event(event_id: str):
    if not is_valid_object_id(event_id):
        raise HTTPException(status_code=400, detail="Invalid event ID format")
    event = await db["events"].find_one({"_id": ObjectId(event_id)})
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")
    event["_id"] = str(event["_id"])
    return event

# ------------------ Queries ------------------
@router.post("/queries")
async def create_query(query: Query):
    query_dict = query.dict()
    result = await db["queries"].insert_one(query_dict)
    return {"id": str(result.inserted_id)}

@router.get("/queries")
async def get_all_queries():
    queries = await db["queries"].find().to_list(100)
    for query in queries:
        query["_id"] = str(query["_id"])
    return queries

@router.get("/queries/{query_id}")
async def get_query(query_id: str):
    if not is_valid_object_id(query_id):
        raise HTTPException(status_code=400, detail="Invalid query ID format")
    query = await db["queries"].find_one({"_id": ObjectId(query_id)})
    if not query:
        raise HTTPException(status_code=404, detail="Query not found")
    query["_id"] = str(query["_id"])
    return query

@router.put("/queries/{query_id}/response")
async def add_response_to_query(query_id: str, response: dict):
    if not is_valid_object_id(query_id):
        raise HTTPException(status_code=400, detail="Invalid query ID format")
    result = await db["queries"].update_one(
        {"_id": ObjectId(query_id)}, {"$push": {"responses": response}}
    )
    if result.matched_count == 0:
        raise HTTPException(status_code=404, detail="Query not found")
    return {"detail": "Response added successfully"}
