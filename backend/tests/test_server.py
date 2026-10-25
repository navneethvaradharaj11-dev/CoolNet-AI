"""Unit tests for CoolNet AI Backend API."""

import unittest
from fastapi.testclient import TestClient

from backend.server import app


class TestBackendAPI(unittest.TestCase):
    def setUp(self):
        self.client = TestClient(app)

    def test_health_endpoint(self):
        resp = self.client.get("/health")
        self.assertEqual(resp.status_code, 200)
        data = resp.json()
        self.assertEqual(data["status"], "healthy")
        self.assertTrue(data["model_loaded"])

    def test_predict_endpoint_valid_sample(self):
        payload = {
            "ward_id": "ward-01",
            "temperature": 41.5,
            "humidity": 65.0,
            "heat_index": 49.0,
            "electricity_demand": 88.0,
            "outage_probability": 0.55,
            "population_density": 26000.0,
            "vulnerability_index": 0.80,
        }
        resp = self.client.post("/api/predict", json=payload)
        self.assertEqual(resp.status_code, 200)
        data = resp.json()
        self.assertEqual(data["ward_id"], "ward-01")
        self.assertTrue(data["is_model_inference"])
        self.assertIn("CRITICAL", ["CRITICAL", "HIGH", "MODERATE", "LOW"])
        self.assertGreaterEqual(data["compound_risk_score"], 0.0)
        self.assertLessEqual(data["compound_risk_score"], 100.0)
        self.assertGreater(len(data["feature_contributions"]), 0)

    def test_predict_endpoint_rejects_out_of_bounds(self):
        payload = {
            "ward_id": "ward-01",
            "temperature": 95.0,  # Out of bounds (>60)
            "humidity": 65.0,
            "heat_index": 49.0,
            "electricity_demand": 88.0,
            "outage_probability": 0.55,
            "population_density": 26000.0,
            "vulnerability_index": 0.80,
        }
        resp = self.client.post("/api/predict", json=payload)
        self.assertEqual(resp.status_code, 422)

    def test_explain_endpoint_structured_output(self):
        payload = {
            "ward_id": "ward-01",
            "risk_score": 75.0,
            "risk_level": "CRITICAL",
            "data": {
                "temperature": 41.5,
                "heat_index": 49.0,
                "electricity_demand": 88.0,
            },
            "shap_factors": [
                {"feature": "heat_index", "contribution": 18.5},
                {"feature": "electricity_demand", "contribution": 14.2},
            ],
        }
        resp = self.client.post("/api/explain", json=payload)
        self.assertEqual(resp.status_code, 200)
        data = resp.json()
        self.assertIn("summary", data)
        self.assertIn("risk_interpretation", data)
        self.assertIn("key_factors", data)
        self.assertIn("recommended_actions", data)
        self.assertIn("limitations", data)
        self.assertIn("data_quality_note", data)


    def test_predict_model_missing_fails_safely(self):
        from unittest.mock import patch
        payload = {
            "ward_id": "ward-01",
            "temperature": 41.5,
            "humidity": 65.0,
            "heat_index": 49.0,
            "electricity_demand": 88.0,
            "outage_probability": 0.55,
            "population_density": 26000.0,
            "vulnerability_index": 0.80,
        }
        with patch("backend.server.session", None):
            resp = self.client.post("/api/predict", json=payload)
            self.assertEqual(resp.status_code, 503)
            data = resp.json()
            self.assertIn("detail", data)


    def test_cors_preflight_allows_vercel_preview(self):
        headers = {
            "Origin": "https://coolnet-ai-phase1-git-redesign-command-center-v2.vercel.app",
            "Access-Control-Request-Method": "POST",
            "Access-Control-Request-Headers": "Content-Type",
        }
        resp = self.client.options("/api/predict", headers=headers)
        self.assertEqual(resp.status_code, 200)
        self.assertEqual(
            resp.headers.get("access-control-allow-origin"),
            "https://coolnet-ai-phase1-git-redesign-command-center-v2.vercel.app",
        )

    def test_cors_preflight_rejects_untrusted_vercel_origin(self):
        headers = {
            "Origin": "https://malicious-site.vercel.app",
            "Access-Control-Request-Method": "POST",
            "Access-Control-Request-Headers": "Content-Type",
        }
        resp = self.client.options("/api/predict", headers=headers)
        self.assertNotEqual(
            resp.headers.get("access-control-allow-origin"),
            "https://malicious-site.vercel.app",
        )


if __name__ == "__main__":
    unittest.main()


