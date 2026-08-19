"""Verification test for CoolNet AI ONNX model inference."""

import json
import os
import sys
import numpy as np
import onnxruntime as ort

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")


def run_tests() -> None:
    model_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "public", "models", "coolnet_risk_model.onnx"))
    meta_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "public", "models", "feature_importances.json"))

    assert os.path.exists(model_path), f"ONNX model not found at {model_path}"
    assert os.path.exists(meta_path), f"Metadata not found at {meta_path}"

    with open(meta_path, "r", encoding="utf-8") as f:
        meta = json.load(f)

    session = ort.InferenceSession(model_path)
    input_name = session.get_inputs()[0].name
    output_name = session.get_outputs()[0].name

    print("==================================================")
    print("CoolNet AI - ONNX Model Verification Scenarios")
    print("==================================================")

    test_cases = [
        {
            "name": "Scenario 1: Mild Baseline Day",
            "features": [30.0, 50.0, 32.0, 50.0, 0.05, 15000.0, 0.40],
            "expected_range": (10.0, 40.0),
        },
        {
            "name": "Scenario 2: Moderate Heat Stress",
            "features": [36.5, 60.0, 42.0, 72.0, 0.20, 22000.0, 0.65],
            "expected_range": (40.0, 70.0),
        },
        {
            "name": "Scenario 3: Severe Heatwave + High Grid Demand",
            "features": [41.5, 65.0, 49.0, 88.0, 0.55, 26000.0, 0.80],
            "expected_range": (70.0, 90.0),
        },
        {
            "name": "Scenario 4: Critical Heatwave + Imminent Blackout + High Vulnerability",
            "features": [45.0, 72.0, 54.0, 96.0, 0.85, 32000.0, 0.92],
            "expected_range": (85.0, 100.0),
        },
    ]

    for tc in test_cases:
        vec = np.array([tc["features"]], dtype=np.float32)
        score = float(session.run([output_name], {input_name: vec})[0][0][0])
        low, high = tc["expected_range"]
        print(f"\n{tc['name']}:")
        print(f"  Input: Temp={tc['features'][0]}°C, HI={tc['features'][2]}°C, Grid={tc['features'][3]}%, OutageP={tc['features'][4]}")
        print(f"  Predicted Compound Risk: {score:.2f}/100 (Expected: {low}-{high})")
        assert low <= score <= high, f"Score {score:.2f} out of expected range {low}-{high}"
        print("  [OK] PASSED")

    print("\n==================================================")
    print("[SUCCESS] All 4 Real ML ONNX inference scenarios passed!")
    print("==================================================")


if __name__ == "__main__":
    run_tests()
