from .base import ModelProvider


class MockProvider(ModelProvider):

    def generate(self, prompt: str) -> dict:
        prompt_tokens = len(prompt.split())
        completion_tokens = 5

        return {
            "response": f"Mock LLM response to: {prompt}",
            "model": "securellm-mock",
            "provider": "mock",
            "usage": {
                "prompt_tokens": prompt_tokens,
                "completion_tokens": completion_tokens,
                "total_tokens": prompt_tokens + completion_tokens,
            },
        }