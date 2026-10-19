import os

from fastapi import FastAPI
from pydantic import BaseModel

from providers.mock import MockProvider
from providers.vllm import VLLMProvider


app = FastAPI(
    title="SecureLLM AI Gateway",
    version="0.3.0",
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


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/ready")
def ready():
    return {
        "status": "ready",
        "provider": MODEL_PROVIDER,
    }


@app.post("/v1/chat/completions")
def chat(request: ChatRequest):
    return model_provider.generate(request.prompt)