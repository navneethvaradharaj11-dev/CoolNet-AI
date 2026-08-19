"""Domain-specific exceptions for CoolNet AI LLM Explanation Layer."""


class CoolNetLLMError(Exception):
    """Base exception for all CoolNet LLM explanation layer errors."""

    def __init__(self, message: str, details: dict | None = None) -> None:
        super().__init__(message)
        self.message = message
        self.details = details or {}


class LLMValidationError(CoolNetLLMError):
    """Raised when incoming ML evidence fails validation before reaching the LLM."""
    pass


class LLMInputValidationError(LLMValidationError):
    """Raised when structured input data format, ranges, or types are invalid."""
    pass


class LLMOutputFormatError(CoolNetLLMError):
    """Raised when the LLM returns invalid JSON or fails the required schema structure."""
    pass


class LLMOutputValidationError(CoolNetLLMError):
    """Raised when the LLM output violates factual consistency or constraints."""
    pass


class LLMAPIError(CoolNetLLMError):
    """Raised when the external LLM provider returns an HTTP or API error."""
    pass


class LLMAuthenticationError(LLMAPIError):
    """Raised when the LLM API key is invalid or unauthorized."""
    pass


class LLMRateLimitError(LLMAPIError):
    """Raised when the LLM API rate limit or quota is exceeded."""
    pass


class LLMTimeoutError(LLMAPIError):
    """Raised when the LLM request times out."""
    pass
