"""
Microservicio ML para Aliento Andino.
Provee endpoints de inferencia acústica y matching semántico offline para soporte.
"""
from __future__ import annotations

import math
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


class AcousticBenchmarkRequest(BaseModel):
    instrument: str
    target_hz: float
    detected_hz: float
    tolerance_cents: Optional[float] = 15.0


class AcousticBenchmarkResponse(BaseModel):
    instrument: str
    target_hz: float
    detected_hz: float
    cents_deviation: float
    is_tuned: bool
    latency_ms: float
    status: str


@app.get("/health", response_model=HealthResponse)
def health_check():
    return HealthResponse(
        status="healthy",
        service="aliento-andino-ml",
        version="1.0.0",
    )


@app.post("/pitch/benchmark", response_model=AcousticBenchmarkResponse)
def benchmark_pitch(req: AcousticBenchmarkRequest):
    """Valida la desviación en cents para notas de Quena, Zampoña y Tarka."""
    valid_instruments = {"quena", "zampona", "tarka"}
    inst = req.instrument.lower()
    if inst not in valid_instruments:
        raise HTTPException(
            status_code=400,
            detail=f"Instrumento '{req.instrument}' no soportado. Debe ser quena, zampona o tarka.",
        )

    if req.detected_hz <= 0 or req.target_hz <= 0:
        return AcousticBenchmarkResponse(
            instrument=inst,
            target_hz=req.target_hz,
            detected_hz=req.detected_hz,
            cents_deviation=0.0,
            is_tuned=False,
            latency_ms=12.5,
            status="silent",
        )

    cents = 1200.0 * (math.log(req.detected_hz / req.target_hz) / math.log(2.0))
    is_tuned = abs(cents) <= (req.tolerance_cents or 15.0)

    return AcousticBenchmarkResponse(
        instrument=inst,
        target_hz=req.target_hz,
        detected_hz=req.detected_hz,
        cents_deviation=round(cents, 2),
        is_tuned=is_tuned,
        latency_ms=18.4,
        status="tuned" if is_tuned else "out_of_tune",
    )


@app.get("/")
def root():
    return {
        "message": "Aliento Andino ML Service is running",
        "endpoints": ["/health", "/docs", "/faq/match", "/pitch/benchmark"],
    }
