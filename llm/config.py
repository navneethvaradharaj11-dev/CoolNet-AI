"""Configuration management for CoolNet AI LLM Explanation Layer."""

from dataclasses import dataclass, field
import os
from typing import Optional


@dataclass(frozen=True)
class LLMConfig:
    """Configuration settings for LLM clients and services."""

    api_key: Optional[str] = field(
        default_factory=lambda: os.getenv("LLM_API_KEY", "")
    )
    model: str = field(
        default_factory=lambda: os.getenv("LLM_MODEL", "gpt-4o-mini")
    )
    base_url: str = field(
        default_factory=lambda: os.getenv("LLM_BASE_URL", "https://api.openai.com/v1")
    )
    timeout: float = field(
        default_factory=lambda: float(os.getenv("LLM_TIMEOUT", "30.0"))
    )
    temperature: float = field(
        default_factory=lambda: float(os.getenv("LLM_TEMPERATURE", "0.1"))
    )
    max_retries: int = field(
        default_factory=lambda: int(os.getenv("LLM_MAX_RETRIES", "3"))
    )

    @classmethod
    def from_env(cls) -> "LLMConfig":
        """Load configuration directly from environment variables."""
        return cls(
            api_key=os.getenv("LLM_API_KEY", ""),
            model=os.getenv("LLM_MODEL", "gpt-4o-mini"),
            base_url=os.getenv("LLM_BASE_URL", "https://api.openai.com/v1"),
            timeout=float(os.getenv("LLM_TIMEOUT", "30.0")),
            temperature=float(os.getenv("LLM_TEMPERATURE", "0.1")),
            max_retries=int(os.getenv("LLM_MAX_RETRIES", "3")),
        )
