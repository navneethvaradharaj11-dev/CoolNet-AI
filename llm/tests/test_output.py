"""Unit tests for LLM output parsing, schema enforcement, and hallucination tests."""

import json
import unittest
from llm.client import MockLLMClient
from llm.exceptions import (
    LLMOutputFormatError,
    LLMOutputValidationError,
)
from llm.schemas import LLMInput, LLMOutput, RiskLevel, SHAPFactor
from llm.service import LLMExplanationService, _strip_markdown_json
from llm.validators import validate_explanation_output


class TestOutput(unittest.TestCase):
    """Test suite for output handling, JSON schema parsing, and hallucination prevention."""

    def setUp(self) -> None:
        self.standard_input = {
            "ward_id": "W023",
            "risk_score": 0.93,
            "risk_level": "CRITICAL",
            "data": {
                "temperature": 43.2,
                "humidity": 68.0,
                "heat_index": 51.4,
                "power_stress": 0.82,
                "vulnerability_score": 0.91,
            },
            "shap_factors": [
                {"feature": "temperature", "contribution": 0.31},
                {"feature": "power_stress", "contribution": 0.27},
                {"feature": "vulnerability_score", "contribution": 0.19},
            ],
            "data_status": {
                "temperature": "real",
                "humidity": "real",
                "power_stress": "simulated",
                "vulnerability_score": "estimated",
            },
            "timestamp": "2026-08-19T11:30:00+05:30",
        }

    def test_full_pipeline_mock_service(self) -> None:
        """Verify the complete explanation pipeline with MockLLMClient returns valid LLMOutput."""
        service = LLMExplanationService(client=MockLLMClient())
        result = service.explain_sync(self.standard_input)

        self.assertIsInstance(result, LLMOutput)
        self.assertTrue(len(result.summary) > 0)
        self.assertTrue(len(result.risk_interpretation) > 0)
        self.assertEqual(len(result.key_factors), 3)
        self.assertTrue(len(result.recommended_actions) > 0)
        self.assertIn("simulated", result.data_quality_note.lower())
        self.assertTrue(len(result.limitations) > 0)

    def test_strips_markdown_code_fences(self) -> None:
        """Markdown code blocks around JSON should be cleanly stripped."""
        raw_with_fences = '```json\n{"summary": "Test", "risk_interpretation": "Test", "key_factors": [], "recommended_actions": [], "data_quality_note": "Test", "limitations": []}\n```'
        cleaned = _strip_markdown_json(raw_with_fences)
        parsed = json.loads(cleaned)
        self.assertEqual(parsed["summary"], "Test")

    def test_rejects_malformed_json_from_llm(self) -> None:
        """Non-JSON responses from LLM must raise LLMOutputFormatError."""
        mock_client = MockLLMClient()
        async def mock_generate(system_prompt: str, user_prompt: str) -> str:
            return "This is not JSON text."
        mock_client.generate_explanation = mock_generate  # type: ignore

        service = LLMExplanationService(client=mock_client)
        with self.assertRaises(LLMOutputFormatError):
            service.explain_sync(self.standard_input)

    def test_rejects_missing_required_schema_field(self) -> None:
        """LLM response missing required fields must raise LLMOutputFormatError."""
        incomplete_response = {
            "summary": "Ward risk explanation",
            # missing risk_interpretation, key_factors, recommended_actions, data_quality_note, limitations
        }
        mock_client = MockLLMClient(override_response=incomplete_response)
        service = LLMExplanationService(client=mock_client)

        with self.assertRaises(LLMOutputFormatError):
            service.explain_sync(self.standard_input)

    def test_hallucination_power_outage_detected_and_rejected(self) -> None:
        """
        HALLUCINATION TEST 1:
        If no outage data was provided in input, and the LLM claims an actual power outage/blackout,
        it must be detected and rejected by the validator.
        """
        input_data = {
            "ward_id": "W001",
            "risk_score": 0.87,
            "risk_level": "HIGH",
            "data": {
                "temperature": 42.5,
                "humidity": 65.0,
            },
            "shap_factors": [
                {"feature": "temperature", "contribution": 0.35}
            ],
            "data_status": {
                "temperature": "real",
                "humidity": "real",
            }
        }
        evidence = LLMInput.model_validate(input_data)

        # Output falsely claiming power outage without disclaimer
        hallucinating_output = LLMOutput(
            summary="Ward W001 has high compound risk due to an ongoing power outage.",
            risk_interpretation="The ward is experiencing a power outage and grid blackout.",
            key_factors=[
                {
                    "factor": "Temperature",
                    "contribution": 0.35,
                    "explanation": "High temperature contributed to prediction."
                }
            ],
            recommended_actions=["Deploy backup generators to restore power blackout."],
            data_quality_note="Temperature is based on real sensor data.",
            limitations=["Model depends on input quality."]
        )

        with self.assertRaises(LLMOutputValidationError):
            validate_explanation_output(hallucinating_output, evidence)

    def test_hallucination_power_outage_disclaimed_passes(self) -> None:
        """
        HALLUCINATION TEST 1 (PASSING):
        When outage is correctly described as unavailable in data, validation passes.
        """
        input_data = {
            "ward_id": "W001",
            "risk_score": 0.87,
            "risk_level": "HIGH",
            "data": {
                "temperature": 42.5,
                "humidity": 65.0,
            },
            "shap_factors": [
                {"feature": "temperature", "contribution": 0.35}
            ],
        }
        evidence = LLMInput.model_validate(input_data)

        compliant_output = LLMOutput(
            summary="Ward W001 shows high compound risk driven primarily by elevated temperature.",
            risk_interpretation="The ML model prediction was dominated by heat conditions. Power outage status is unavailable in the supplied data.",
            key_factors=[
                {
                    "factor": "Temperature",
                    "contribution": 0.35,
                    "explanation": "Temperature was the primary contributor to the model prediction."
                }
            ],
            recommended_actions=["Prioritize cooling-center readiness."],
            data_quality_note="Temperature and humidity are real measurements. No outage information was provided.",
            limitations=["Power grid stress and demographic metrics were unavailable."]
        )

        # Should not raise
        validate_explanation_output(compliant_output, evidence)

    def test_hallucination_simulated_power_stress_enforcement(self) -> None:
        """
        HALLUCINATION TEST 2:
        When power_stress is marked 'simulated', the LLM output MUST acknowledge simulation.
        If it describes it as measured real-time grid data without mentioning simulation, it is rejected.
        """
        input_data = {
            "ward_id": "W023",
            "risk_score": 0.93,
            "risk_level": "CRITICAL",
            "data": {
                "temperature": 43.2,
                "power_stress": 0.82,
            },
            "shap_factors": [
                {"feature": "power_stress", "contribution": 0.30}
            ],
            "data_status": {
                "temperature": "real",
                "power_stress": "simulated",
            }
        }
        evidence = LLMInput.model_validate(input_data)

        # Non-compliant output omitting simulation acknowledgment
        bad_output = LLMOutput(
            summary="Critical risk in Ward W023 due to high grid stress.",
            risk_interpretation="Real-time measured grid stress contributed to the model prediction.",
            key_factors=[
                {
                    "factor": "Power Stress",
                    "contribution": 0.30,
                    "explanation": "Power stress contributed to prediction."
                }
            ],
            recommended_actions=["Dispatch utility teams."],
            data_quality_note="All data verified from live real-time sensors.",
            limitations=["None."]
        )

        with self.assertRaises(LLMOutputValidationError):
            validate_explanation_output(bad_output, evidence)

    def test_missing_vulnerability_data_handled(self) -> None:
        """
        HALLUCINATION TEST 3:
        When vulnerability data is absent from input, the service should explicitly note
        it is unavailable and not fabricate demographic claims.
        """
        input_without_vulnerability = {
            "ward_id": "W005",
            "risk_score": 0.82,
            "risk_level": "HIGH",
            "data": {
                "temperature": 41.5,
                "humidity": 70.0,
            },
            "shap_factors": [
                {"feature": "temperature", "contribution": 0.40}
            ],
            "data_status": {
                "temperature": "real",
                "humidity": "real",
            }
        }
        service = LLMExplanationService(client=MockLLMClient())
        result = service.explain_sync(input_without_vulnerability)

        self.assertIsInstance(result, LLMOutput)
        self.assertIn("vulnerability", result.data_quality_note.lower())
        self.assertIn("unavailable", result.data_quality_note.lower())


if __name__ == "__main__":
    unittest.main()
