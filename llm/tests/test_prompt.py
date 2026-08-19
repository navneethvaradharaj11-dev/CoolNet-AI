"""Unit tests for system prompt construction and prompt generation."""

import unittest
from llm.prompts import SYSTEM_PROMPT, build_user_prompt
from llm.schemas import LLMInput, RiskLevel, SHAPFactor


class TestPrompt(unittest.TestCase):
    """Test suite for prompt engineering rules and structure."""

    def test_system_prompt_contains_all_rules(self) -> None:
        """Verify the system prompt explicitly contains all mandatory safety & factual rules."""
        required_rules = [
            "CoolNet AI explanation assistant",
            "NEVER calculate, modify, recalculate, reinterpret, or override the risk_score",
            "NEVER create a new risk score",
            "NEVER invent missing weather, power, demographic, or outage data",
            "Use ONLY the supplied input evidence",
            "explicitly state that it is unavailable",
            "Clearly distinguish real, simulated, and estimated data",
            "SHAP contributions explain the ML prediction; do not treat them as causal proof",
            "contributed to the model prediction",
            "Recommendations must be decision-support suggestions",
            "Do NOT provide medical diagnosis",
            "Do NOT make unsupported claims about actual power outages",
            "Never fabricate government policies",
        ]
        for rule in required_rules:
            self.assertIn(
                rule.lower(),
                SYSTEM_PROMPT.lower(),
                f"Missing required constraint in system prompt: {rule}"
            )

    def test_user_prompt_encapsulation(self) -> None:
        """Verify user prompt encapsulates structured evidence inside XML delimiters."""
        evidence = LLMInput(
            ward_id="W099",
            risk_score=0.78,
            risk_level=RiskLevel.HIGH,
            data={"temperature": 41.0, "humidity": 60.0},
            shap_factors=[
                SHAPFactor(feature="temperature", contribution=0.45)
            ],
            data_status={"temperature": "real", "humidity": "real"},
            timestamp="2026-08-19T12:00:00+05:30"
        )
        prompt = build_user_prompt(evidence)

        # Must have <evidence> opening and closing tags
        self.assertIn("<evidence>", prompt)
        self.assertIn("</evidence>", prompt)
        self.assertIn("W099", prompt)
        self.assertIn("0.78", prompt)
        self.assertIn("HIGH", prompt)
        self.assertIn("temperature", prompt)
        self.assertIn("0.45", prompt)


if __name__ == "__main__":
    unittest.main()
