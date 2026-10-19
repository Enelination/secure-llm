from .base import ModelProvider


class MockProvider(ModelProvider):

    def generate(self, prompt: str) -> dict:
        return {
            "response": f"Mock LLM response to: {prompt}",
            "model": "securellm-mock",
            "provider": "mock",
        }