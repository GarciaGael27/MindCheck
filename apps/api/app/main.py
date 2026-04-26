from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routers import assessments, checkins, scores

app = FastAPI(
    title="MindCheck API",
    version="0.1.0",
    description="Backend de lógica de negocio para MindCheck — scoring MBI-SS, check-ins y alertas",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(assessments.router, prefix="/api/v1")
app.include_router(checkins.router, prefix="/api/v1")
app.include_router(scores.router, prefix="/api/v1")


@app.get("/health")
def health():
    return {"status": "ok", "service": "mindcheck-api"}
