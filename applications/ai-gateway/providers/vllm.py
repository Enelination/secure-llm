import os

import httpx

from .base import ModelProvider


class VLLMProvider(ModelProvider):

    def __init__(self):
        self.endpoint = os.getenv(
            "MODEL_ENDPOINT",
            "http://localhost:8000",
        )
        self.model_name = os.getenv(
            "MODEL_NAME",
            "default",
        )

    def generate(self, prompt: str) -> dict:
        response = httpx.post(
            f"{self.endpoint}/v1/chat/completions",
            json={
                "model": self.model_name,
                "messages": [
                    {
                        "role": "user",
                        "content": prompt,
                    }
                ],
            },
            timeout=60.0,
        )

        response.raise_for_status()

        data = response.json()

        return {
            "response": data["choices"][0]["message"]["content"],
            "model": data.get("model", self.model_name),
            "provider": "vllm",
        }