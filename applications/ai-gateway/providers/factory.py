import os

from .base import ModelProvider
from .mock import MockProvider
from .vllm import VLLMProvider


def create_provider() -> ModelProvider:
    provider_name = os.getenv("MODEL_PROVIDER", "mock").lower()

    providers = {
        "mock": MockProvider,
        "vllm": VLLMProvider,
    }

    provider_class = providers.get(provider_name)

    if provider_class is None:
        raise ValueError(
            f"Unsupported MODEL_PROVIDER: {provider_name}"
        )

    return provider_class()