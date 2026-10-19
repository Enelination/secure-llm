from abc import ABC, abstractmethod


class ModelProvider(ABC):

    @abstractmethod
    def generate(self, prompt: str) -> dict:
        """Generate a model response for the given prompt."""
        raise NotImplementedError