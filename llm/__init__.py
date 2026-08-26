"""CoolNet AI - LLM-powered Explanation Layer.

This module provides a secure, factual explanation service downstream of
predictive ML models (XGBoost/LightGBM + SHAP) for compound heatwave,
power stress, and vulnerability assessment.
"""

from .client import BaseLLMClient, MockLLMClient, OpenAICompatibleClient
from .config import LLMConfig
from .exceptions import (
    CoolNetLLMError,
    LLMAPIError,
    LLMAuthenticationError,
    LLMInputValidationError,
    LLMOutputFormatError,
    LLMOutputValidationError,
    LLMRateLimitError,
    LLMTimeoutError,
    LLMValidationError,
)
from .schemas import (
    DataStatusType,
    KeyFactor,
    LLMInput,
    LLMOutput,
    RiskLevel,
    SHAPFactor,
)
from .service import LLMExplanationService
from .validators import validate_explanation_output, validate_input_evidence

__all__ = [
    "LLMExplanationService",
    "LLMConfig",
    "BaseLLMClient",
    "OpenAICompatibleClient",
    "MockLLMClient",
    "LLMInput",
    "LLMOutput",
    "SHAPFactor",
    "KeyFactor",
    "RiskLevel",
    "DataStatusType",
    "CoolNetLLMError",
    "LLMValidationError",
    "LLMInputValidationError",
    "LLMOutputFormatError",
    "LLMOutputValidationError",
    "LLMAPIError",
    "LLMAuthenticationError",
    "LLMRateLimitError",
    "LLMTimeoutError",
    "validate_input_evidence",
    "validate_explanation_output",
]
