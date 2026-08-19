"""LLM API clients for CoolNet AI LLM Explanation Layer."""

import asyncio
import json
import logging
import re
from typing import Any, Dict, Optional, Protocol

import httpx

from .config import LLMConfig
from .exceptions import (
    LLMAPIError,
    LLMAuthenticationError,
    LLMRateLimitError,
    LLMTimeoutError,
)

logger = logging.getLogger("coolnet.llm.client")


class BaseLLMClient(Protocol):
    """Protocol defining the interface for an LLM explanation client."""

    async def generate_explanation(self, system_prompt: str, user_prompt: str) -> str:
        """Asynchronously call the LLM and return raw JSON string."""
        ...


class OpenAICompatibleClient:
    """Async client for OpenAI and OpenAI-compatible endpoints (Groq, Ollama, OpenRouter, vLLM, LiteLLM)."""

    def __init__(self, config: Optional[LLMConfig] = None) -> None:
        self.config = config or LLMConfig.from_env()
        self.client: Optional[httpx.AsyncClient] = None

    async def _get_client(self) -> httpx.AsyncClient:
        if self.client is None or self.client.is_closed:
            self.client = httpx.AsyncClient(timeout=self.config.timeout)
        return self.client

    async def close(self) -> None:
        """Close the underlying HTTP client session."""
        if self.client and not self.client.is_closed:
            await self.client.aclose()

    async def generate_explanation(self, system_prompt: str, user_prompt: str) -> str:
        """
        Send a chat completion request to the OpenAI-compatible endpoint.
        
        Uses JSON mode and exponential backoff retry.
        """
        if not self.config.api_key:
            raise LLMAuthenticationError(
                "LLM API key is not configured. Set LLM_API_KEY environment variable or pass a valid key in LLMConfig."
            )

        client = await self._get_client()
        url = f"{self.config.base_url.rstrip('/')}/chat/completions"
        headers = {
            "Authorization": f"Bearer {self.config.api_key}",
            "Content-Type": "application/json",
        }

        payload: Dict[str, Any] = {
            "model": self.config.model,
            "messages": [
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt},
            ],
            "temperature": self.config.temperature,
            "response_format": {"type": "json_object"},
        }

        last_exception: Optional[Exception] = None
        for attempt in range(1, self.config.max_retries + 1):
            try:
                logger.debug("Dispatching LLM request to %s (attempt %d/%d)", url, attempt, self.config.max_retries)
                response = await client.post(url, headers=headers, json=payload)
                response.raise_for_status()

                response_data = response.json()
                content = response_data["choices"][0]["message"]["content"]
                if not content:
                    raise LLMAPIError("Received empty completion from LLM API")
                return content

            except httpx.TimeoutException as exc:
                logger.warning("LLM API request timed out on attempt %d: %s", attempt, exc)
                last_exception = LLMTimeoutError(f"LLM API request timed out after {self.config.timeout}s")
            except httpx.HTTPStatusError as exc:
                status_code = exc.response.status_code
                error_body = exc.response.text
                logger.warning("LLM API returned HTTP %d on attempt %d: %s", status_code, attempt, error_body)

                if status_code in (401, 403):
                    raise LLMAuthenticationError(f"Authentication failed (HTTP {status_code}): {error_body}") from exc
                if status_code == 429:
                    last_exception = LLMRateLimitError(f"Rate limit exceeded (HTTP 429): {error_body}")
                else:
                    last_exception = LLMAPIError(f"LLM API error (HTTP {status_code}): {error_body}")

            except Exception as exc:
                logger.exception("Unexpected error communicating with LLM API on attempt %d", attempt)
                last_exception = LLMAPIError(f"Unexpected connection error: {str(exc)}")

            if attempt < self.config.max_retries:
                backoff_delay = 1.5 ** attempt
                logger.info("Retrying LLM call in %.1f seconds...", backoff_delay)
                await asyncio.sleep(backoff_delay)

        raise last_exception or LLMAPIError("Failed to communicate with LLM API after retries")


class MockLLMClient:
    """
    Deterministic mock client for testing and offline development.
    Adheres strictly to all 15 rules, data-status flags, and anti-hallucination constraints.
    """

    def __init__(self, override_response: Optional[Dict[str, Any]] = None) -> None:
        self.override_response = override_response

    async def generate_explanation(self, system_prompt: str, user_prompt: str) -> str:
        """Simulate LLM response by parsing evidence from the prompt or returning rule-conforming mock."""
        if self.override_response is not None:
            return json.dumps(self.override_response)

        # Extract evidence JSON from <evidence> tags
        match = re.search(r"<evidence>\s*(\{.*?\})\s*</evidence>", user_prompt, re.DOTALL)
        if not match:
            # Fallback default response
            return json.dumps({
                "summary": "Ward risk is elevated based on compound model prediction.",
                "risk_interpretation": "The upstream model evaluated weather and grid indicators.",
                "key_factors": [
                    {
                        "factor": "Temperature",
                        "contribution": 0.30,
                        "explanation": "Temperature contributed positively to the model prediction."
                    }
                ],
                "recommended_actions": ["Monitor local cooling infrastructure."],
                "data_quality_note": "Based on supplied input data.",
                "limitations": ["Prediction reflects available features only."]
            })

        evidence = json.loads(match.group(1))
        ward_id = evidence.get("ward_id", "Unknown")
        risk_score = evidence.get("risk_score", 0.0)
        risk_level = evidence.get("risk_level", "MODERATE")
        data = evidence.get("data", {})
        shap_factors = evidence.get("shap_factors", [])
        data_status = evidence.get("data_status", {})

        # Generate key factors from SHAP factors
        key_factors = []
        for factor in shap_factors:
            feat_name = factor.get("feature", "unknown_feature")
            contrib = factor.get("contribution", 0.0)
            feat_title = feat_name.replace("_", " ").title()
            key_factors.append({
                "factor": feat_title,
                "contribution": contrib,
                "explanation": f"{feat_title} was a notable contributor to the model prediction."
            })

        # Generate contextual recommendations without making guaranteed medical/policy claims
        actions = []
        if risk_level in ("HIGH", "CRITICAL"):
            actions.append("Prioritize cooling-center readiness and outreach.")
            actions.append("Coordinate with utility operators for peak load management.")
        else:
            actions.append("Maintain baseline heatwave and power grid surveillance.")

        # Handle data status and missing data
        data_notes = []
        if data_status.get("power_stress") == "simulated":
            data_notes.append("Power stress is based on simulated prototype data.")
        elif "power_stress" not in data:
            data_notes.append("Power grid stress data was unavailable in the input.")

        if "vulnerability_score" not in data:
            data_notes.append("Detailed demographic vulnerability data was unavailable in the input.")

        if not data_notes:
            data_notes.append("All reported metrics are based on verified input streams.")

        quality_note = " ".join(data_notes)

        return json.dumps({
            "summary": f"Ward {ward_id} has a {risk_level} compound risk score of {risk_score:.2f} as predicted by the ML model.",
            "risk_interpretation": f"The ML model's compound assessment for Ward {ward_id} was primarily driven by the provided environmental and grid indicators.",
            "key_factors": key_factors or [
                {
                    "factor": "Baseline Model Indicators",
                    "contribution": 0.0,
                    "explanation": "No individual SHAP factors were provided."
                }
            ],
            "recommended_actions": actions,
            "data_quality_note": quality_note,
            "limitations": [
                "The prediction depends on the quality and availability of the supplied input data.",
                "SHAP values reflect model feature contributions rather than physical causality."
            ]
        })
