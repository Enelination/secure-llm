import os
import time

from fastapi import FastAPI, Request
from fastapi.responses import Response
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
from pydantic import BaseModel

from providers.mock import MockProvider
from providers.vllm import VLLMProvider


app = FastAPI(
    title="SecureLLM AI Gateway",
    version="0.4.0",
)


class ChatRequest(BaseModel):
    prompt: str


MODEL_PROVIDER = os.getenv("MODEL_PROVIDER", "mock")

providers = {
    "mock": MockProvider(),
    "vllm": VLLMProvider(),
}

if MODEL_PROVIDER not in providers:
    raise RuntimeError(
        f"Unsupported MODEL_PROVIDER: {MODEL_PROVIDER}"
    )

model_provider = providers[MODEL_PROVIDER]


# HTTP metrics
HTTP_REQUESTS_TOTAL = Counter(
    "http_requests_total",
    "Total number of HTTP requests",
    ["method", "path", "status"],
)

HTTP_REQUEST_DURATION = Histogram(
    "http_request_duration_seconds",
    "HTTP request duration in seconds",
    ["method", "path"],
)


# LLM metrics
LLM_REQUESTS_TOTAL = Counter(
    "llm_requests_total",
    "Total number of LLM inference requests",
    ["provider"],
)

LLM_REQUEST_DURATION = Histogram(
    "llm_request_duration_seconds",
    "LLM inference duration in seconds",
    ["provider"],
)

LLM_ERRORS_TOTAL = Counter(
    "llm_errors_total",
    "Total number of LLM inference errors",
    ["provider"],
)


@app.middleware("http")
async def metrics_middleware(request: Request, call_next):
    start = time.perf_counter()

    response = await call_next(request)

    duration = time.perf_counter() - start

    HTTP_REQUESTS_TOTAL.labels(
        method=request.method,
        path=request.url.path,
        status=str(response.status_code),
    ).inc()

    HTTP_REQUEST_DURATION.labels(
        method=request.method,
        path=request.url.path,
    ).observe(duration)

    return response


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/ready")
def ready():
    return {
        "status": "ready",
        "provider": MODEL_PROVIDER,
    }


@app.get("/metrics")
def metrics():
    return Response(
        generate_latest(),
        media_type=CONTENT_TYPE_LATEST,
    )


@app.post("/v1/chat/completions")
def chat(request: ChatRequest):
    start = time.perf_counter()

    LLM_REQUESTS_TOTAL.labels(
        provider=MODEL_PROVIDER,
    ).inc()

    try:
        response = model_provider.generate(request.prompt)

        LLM_REQUEST_DURATION.labels(
            provider=MODEL_PROVIDER,
        ).observe(time.perf_counter() - start)

        return response

    except Exception:
        LLM_ERRORS_TOTAL.labels(
            provider=MODEL_PROVIDER,
        ).inc()

        LLM_REQUEST_DURATION.labels(
            provider=MODEL_PROVIDER,
        ).observe(time.perf_counter() - start)

        raise