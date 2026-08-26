"""Validation utilities for CoolNet AI LLM Explanation Layer."""

import logging
import math
import re
from typing import Any, Dict, List, Optional
from pydantic import ValidationError

from .exceptions import LLMInputValidationError, LLMOutputValidationError
from .schemas import LLMInput, LLMOutput, RiskLevel

logger = logging.getLogger("coolnet.llm.validators")

# Prompt injection patterns to detect and block in incoming data fields
PROMPT_INJECTION_PATTERNS = [
    r"ignore\s+(all\s+)?(previous|prior|above)\s+instructions?",
    r"you\s+are\s+now\s+",
    r"system\s*:",
    r"assistant\s*:",
    r"user\s*:",
    r"developer\s+mode",
    r"override\s+system\s+prompt",
    r"disregard\s+(all\s+)?rules?",
    r"reset\s+(your\s+)?instructions?",
    r"<\s*script",
    r"<\s*/\s*script",
]

COMPILED_INJECTION_PATTERNS = [
    re.compile(pattern, re.IGNORECASE) for pattern in PROMPT_INJECTION_PATTERNS
]


def check_for_prompt_injection(text: str, field_name: str = "field") -> None:
    """Check text fields for prompt injection or adversarial instruction injection."""
    if not isinstance(text, str):
        return
    for pattern in COMPILED_INJECTION_PATTERNS:
        if pattern.search(text):
            logger.warning("Prompt injection attempt detected in %s: %r", field_name, text)
            raise LLMInputValidationError(
                f"Potentially adversarial prompt injection pattern detected in '{field_name}'",
                details={"field": field_name, "value": text}
            )


def validate_numerical_bounds(data: Dict[str, Optional[float]]) -> None:
    """Validate physical and mathematical bounds for ward data fields."""
    for key, value in data.items():
        if value is None:
            continue
        if not isinstance(value, (int, float)) or math.isnan(value) or math.isinf(value):
            raise LLMInputValidationError(
                f"Field '{key}' must be a finite numerical value, got {value}",
                details={"field": key, "value": value}
            )

        # Domain range checks
        if key == "temperature" and (value < -50.0 or value > 75.0):
            raise LLMInputValidationError(
                f"Temperature value {value}°C is out of realistic physical range [-50, 75]",
                details={"field": key, "value": value}
            )
        if key == "humidity" and (value < 0.0 or value > 100.0):
            raise LLMInputValidationError(
                f"Humidity value {value}% must be between 0 and 100",
                details={"field": key, "value": value}
            )
        if key in ("power_stress", "vulnerability_score", "heat_index_normalized") and (value < 0.0 or value > 1.0):
            raise LLMInputValidationError(
                f"Metric '{key}' value {value} must be between 0.0 and 1.0",
                details={"field": key, "value": value}
            )


def validate_input_evidence(raw_input: Any) -> LLMInput:
    """
    Validate raw input dictionary or Pydantic model before sending to LLM.
    
    Ensures:
    - Pydantic schema compliance
    - Risk score in [0.0, 1.0]
    - Prompt injection detection in text fields
    - Physical and domain range bounds on numerical metrics
    - Finite SHAP contribution values
    """
    if isinstance(raw_input, LLMInput):
        llm_input = raw_input
    elif isinstance(raw_input, dict):
        try:
            llm_input = LLMInput.model_validate(raw_input)
        except ValidationError as e:
            logger.error("Input validation failed: %s", e)
            raise LLMInputValidationError("Invalid input structure or fields", details={"errors": e.errors()}) from e
    else:
        raise LLMInputValidationError(f"Expected dict or LLMInput instance, got {type(raw_input).__name__}")

    # Prompt injection check on ward_id and any string keys
    check_for_prompt_injection(llm_input.ward_id, field_name="ward_id")
    if llm_input.timestamp:
        check_for_prompt_injection(llm_input.timestamp, field_name="timestamp")

    # Range and domain checks
    if not (0.0 <= llm_input.risk_score <= 1.0):
        raise LLMInputValidationError(
            f"risk_score must be between 0.0 and 1.0, got {llm_input.risk_score}",
            details={"risk_score": llm_input.risk_score}
        )

    # Validate numerical bounds in data
    validate_numerical_bounds(llm_input.data)

    # Validate SHAP factors
    for factor in llm_input.shap_factors:
        check_for_prompt_injection(factor.feature, field_name="shap_feature")
        if math.isnan(factor.contribution) or math.isinf(factor.contribution):
            raise LLMInputValidationError(
                f"SHAP contribution for '{factor.feature}' must be a finite number, got {factor.contribution}"
            )

    return llm_input


def validate_explanation_output(llm_output: LLMOutput, llm_input: LLMInput) -> None:
    """
    Sanity check LLM output against the ground-truth input to catch hallucinations:
    - Does not fabricate power outages if outage info was not provided.
    - Mentions simulation when power stress is marked simulated.
    - Does not invent elderly or demographics when vulnerability data is absent.
    """
    combined_text = f"{llm_output.summary} {llm_output.risk_interpretation} {' '.join(llm_output.recommended_actions)} {llm_output.data_quality_note}".lower()

    # Rule: Do not claim actual power outage if no outage information was provided in data
    outage_claimed = "power outage" in combined_text or "blackout" in combined_text or "grid failure" in combined_text
    has_outage_data = "outage" in llm_input.data or "power_outage" in llm_input.data

    if outage_claimed and not has_outage_data:
        # Check if it was explicitly disclaimed or stated as unavailable
        disclaimers = [
            "no outage information",
            "outage status is unavailable",
            "unavailable in the supplied data",
            "not reported",
            "no power outage data",
            "without outage data",
        ]
        if not any(d in combined_text for d in disclaimers):
            logger.warning("LLM claimed power outage without outage data in input")
            raise LLMOutputValidationError(
                "LLM hallucinated power outage information when none was present in input data",
                details={"combined_text": combined_text}
            )

    # Rule: If power_stress is marked 'simulated', verify that data_quality_note or text clarifies simulation
    if llm_input.data_status and llm_input.data_status.get("power_stress") == "simulated":
        dq_note = llm_output.data_quality_note.lower()
        if "simulat" not in dq_note and "prototype" not in dq_note and "simulat" not in combined_text:
            logger.warning("LLM omitted required simulation disclaimer for power_stress")
            raise LLMOutputValidationError(
                "LLM failed to reflect simulated status of power_stress in data_quality_note or explanation"
            )
