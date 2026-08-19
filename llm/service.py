"""Core service orchestration for CoolNet AI LLM Explanation Layer."""

import asyncio
import json
import logging
import re
from typing import Any, Dict, Optional, Union

from pydantic import ValidationError

from .client import BaseLLMClient, OpenAICompatibleClient
from .config import LLMConfig
from .exceptions import (
    CoolNetLLMError,
    LLMOutputFormatError,
    LLMOutputValidationError,
)
from .prompts import SYSTEM_PROMPT, build_user_prompt
from .schemas import LLMInput, LLMOutput
from .validators import validate_explanation_output, validate_input_evidence

logger = logging.getLogger("coolnet.llm.service")


def _strip_markdown_json(raw_text: str) -> str:
    """Clean markdown code fences if inadvertently included by the LLM."""
    text = raw_text.strip()
    if text.startswith("```"):
        # Match ```json ... ``` or ``` ... ```
        match = re.search(r"^```(?:json)?\s*\n?(.*?)\n?```$", text, re.DOTALL | re.IGNORECASE)
        if match:
            return match.group(1).strip()
    return text


class LLMExplanationService:
    """
    Main orchestration service for generating risk explanations.
    
    Workflow:
    Structured Input
      ↓
    Validate Input Evidence (Ranges, Enums, Injection Defense)
      ↓
    Construct Controlled System & User Prompts
      ↓
    Call LLM Client (OpenAI-compatible / Mock)
      ↓
    Parse & Validate LLM Output Schema (Pydantic LLMOutput)
      ↓
    Validate Sanity & Anti-Hallucination Constraints
      ↓
    Return Typed LLMOutput
    """

    def __init__(
        self,
        client: Optional[BaseLLMClient] = None,
        config: Optional[LLMConfig] = None,
    ) -> None:
        self.config = config or LLMConfig.from_env()
        self.client = client or OpenAICompatibleClient(config=self.config)

    async def explain(self, raw_input: Union[Dict[str, Any], LLMInput]) -> LLMOutput:
        """
        Asynchronously validate ML prediction evidence and generate structured explanation.
        
        :param raw_input: Dictionary or LLMInput instance with ML prediction and SHAP metrics.
        :return: Validated LLMOutput object.
        """
        logger.info("Starting LLM explanation pipeline...")

        # 1. Validate incoming evidence
        evidence: LLMInput = validate_input_evidence(raw_input)
        logger.debug("Validated input for Ward %s (Risk: %s, Score: %.2f)", evidence.ward_id, evidence.risk_level.value, evidence.risk_score)

        # 2. Build controlled prompts
        system_prompt = SYSTEM_PROMPT
        user_prompt = build_user_prompt(evidence)

        # 3. Call LLM
        raw_response = await self.client.generate_explanation(
            system_prompt=system_prompt,
            user_prompt=user_prompt,
        )

        # 4. Clean and parse JSON
        cleaned_json_str = _strip_markdown_json(raw_response)
        try:
            parsed_dict = json.loads(cleaned_json_str)
        except json.JSONDecodeError as exc:
            logger.error("Failed to parse LLM JSON response: %s\nRaw content: %s", exc, raw_response)
            raise LLMOutputFormatError(
                f"LLM returned invalid non-JSON output: {exc}",
                details={"raw_response": raw_response}
            ) from exc

        # 5. Validate against Pydantic output schema
        try:
            output_model = LLMOutput.model_validate(parsed_dict)
        except ValidationError as exc:
            logger.error("LLM output failed schema validation: %s", exc)
            raise LLMOutputFormatError(
                "LLM output violated required schema structure",
                details={"validation_errors": exc.errors(), "parsed_dict": parsed_dict}
            ) from exc

        # 6. Sanity check for hallucinations and data attribution rules
        validate_explanation_output(output_model, evidence)

        logger.info("Successfully generated explanation for Ward %s", evidence.ward_id)
        return output_model

    def explain_sync(self, raw_input: Union[Dict[str, Any], LLMInput]) -> LLMOutput:
        """Synchronous wrapper for explain()."""
        return asyncio.run(self.explain(raw_input))
