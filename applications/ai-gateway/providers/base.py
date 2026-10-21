from abc import ABC, abstractmethod


class ModelProvider(ABC):

    @abstractmethod
    def generate(self, prompt: str) -> dict:
        """Generate a model response for the given prompt."""
        raise NotImplementedError

    def healthy(self) -> bool:
        """Return whether the upstream model provider is reachable."""
        return True

    @property
    def name(self) -> str:
        """Return the model identifier exposed in labels."""
        return "unknown"