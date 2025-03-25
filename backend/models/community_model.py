# Model file for posts, discussions, events, and queries collections

from pydantic import BaseModel
from typing import List, Optional

# Model for posts
class Post(BaseModel):
    id: Optional[str]
    user_id: str
    title: str
    content: str
    image_url: Optional[str]  # New field for the image URL
    timestamp: str

# Model for discussions
class Discussion(BaseModel):
    id: Optional[str]
    user_id: str
    topic: str
    content: str
    timestamp: str
    comments: List[dict]  # Example: [{"user_id": "", "comment": "", "timestamp": ""}]

# Model for events
class Event(BaseModel):
    id: Optional[str]
    title: str
    date: str
    description: str
    participants: List[str]  # List of user_ids

# Model for queries
class Query(BaseModel):
    id: Optional[str]
    user_id: str
    question: str
    forum_type: str  # e.g., "General", "Specialist"
    responses: List[dict]  # Example: [{"responder_id": "", "response": "", "timestamp": ""}]
