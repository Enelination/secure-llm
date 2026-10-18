from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI(
    title="SecureLLM AI Gateway",
    version="0.1.0",
)


class ChatRequest(BaseModel):
    prompt: str


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/ready")
def ready():
    return {"status": "ready"}


@app.post("/v1/chat/completions")
def chat(request: ChatRequest):
    return {
        "response": f"Mock LLM response to: {request.prompt}",
        "model": "securellm-mock",
    }