from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from routes.user_routes import router as user_router
from routes.food_logs_routes import router as food_logs_router
from routes.exercise_logs_routes import router as exercise_logs_router
from routes.medicines_routes import router as medicines_router
from routes.water_logs_routes import router as water_logs_router
from routes.reports_routes import router as reports_router
from routes.community_routes import router as community_routes
from routes.health_routes import router as health_routes
from routes.profile_routes import router as profile_routes


app = FastAPI()

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Change this to specific origins in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Including routers with correct prefix
app.include_router(user_router, prefix="/api/users", tags=["Users"])
app.include_router(food_logs_router, prefix="/api/food_logs", tags=["Food Logs"])
app.include_router(exercise_logs_router, prefix="/api/exercise_logs", tags=["Exercise Logs"])
app.include_router(medicines_router, prefix="/api/medicines", tags=["Medicines"])
app.include_router(water_logs_router, prefix="/api/water_logs", tags=["Water Logs"])
app.include_router(reports_router, prefix="/api/reports", tags=["Reports"])
app.include_router(community_routes, prefix="/api/community", tags=["Community"])
app.include_router(health_routes, prefix="/api/health", tags=["Health Data"])
app.include_router(profile_routes, prefix="/api/profile", tags=["Profile Data"])

@app.get("/")
async def read_root():
    return {"message": "Welcome to the NS API!"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000, reload=True)  # Allow access from real devices
