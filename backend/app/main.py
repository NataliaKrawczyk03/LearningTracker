from fastapi import FastAPI

from app.routers import health

app = FastAPI(title="LearningTracker API", version="1.0.0")

app.include_router(health.router)
