"""
Microservicio ML para Aliento Andino.
Provee endpoints de inferencia acústica y matching semántico offline para soporte.
"""
from __future__ import annotations

import os
from typing import List, Optional
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI(
    title="Aliento Andino ML Service",
    description="Servicio de inferencia acústica, modelos de acordes y matching semántico",
    version="1.0.0",
)


class HealthResponse(BaseModel):
    status: str
    service: str
    version: str


class FAQQuery(BaseModel):
    query: str
    top_k: Optional[int] = 3


class FAQMatch(BaseModel):
    id: str
    score: float
    question: str
    answer: str


@app.get("/health", response_model=HealthResponse)
def health_check():
    return HealthResponse(
        status="healthy",
        service="aliento-andino-ml",
        version="1.0.0",
    )


@app.get("/")
def root():
    return {
        "message": "Aliento Andino ML Service is running",
        "endpoints": ["/health", "/docs", "/faq/match"],
    }
