from motor.motor_asyncio import AsyncIOMotorClient
from dotenv import load_dotenv
import os

# Load environment variables from .env file
load_dotenv()

# Retrieve the MONGO_URI from the environment variables
MONGO_URI = os.getenv("MONGO_URI")

# Initialize the MongoDB client
client = AsyncIOMotorClient(MONGO_URI)
db = client["nurture_sync"]
