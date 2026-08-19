"""CoolNet AI - Model Training & ONNX Export Pipeline.

Generates a realistic synthetic training dataset calibrated to published heatwave
and electricity grid demand patterns, trains an ensemble regressor, and exports
both ONNX binary model and feature importance metadata for browser inference.
"""

import json
import math
import os
import sys
import numpy as np


def calculate_heat_index(temp_c: np.ndarray, humidity_pct: np.ndarray) -> np.ndarray:
    """Calculate Heat Index in Celsius using Rothfusz regression equation."""
    # Convert Celsius to Fahrenheit
    T = (temp_c * 9.0 / 5.0) + 32.0
    R = humidity_pct

    # Simple formula
    HI_simple = 0.5 * (T + 61.0 + ((T - 68.0) * 1.2) + (R * 0.094))

    # Full Rothfusz equation
    HI_full = (
        -42.379
        + 2.04901523 * T
        + 10.14333127 * R
        - 0.22475541 * T * R
        - 0.00683783 * (T**2)
        - 0.05481717 * (R**2)
        + 0.00122874 * (T**2) * R
        + 0.00085282 * T * (R**2)
        - 0.00000199 * (T**2) * (R**2)
    )

    # Use full formula where simple formula is >= 80 deg F
    HI_F = np.where(HI_simple >= 80.0, HI_full, HI_simple)

    # Convert back to Celsius
    HI_C = (HI_F - 32.0) * 5.0 / 9.0
    return HI_C


def generate_synthetic_dataset(num_samples: int = 5000, random_seed: int = 42) -> tuple:
    """
    Generate calibrated urban climate, grid stress, and human vulnerability dataset.
    
    Features (7):
    0: temperature (°C)
    1: humidity (%)
    2: heat_index (°C)
    3: electricity_demand_pct (0 - 100%)
    4: outage_probability (0.0 - 1.0)
    5: population_density (people / km²)
    6: vulnerability_index (0.0 - 1.0)
    
    Target:
    compound_risk_score (0.0 - 100.0)
    """
    np.random.seed(random_seed)

    # 1. Ambient Temperature (°C) [28°C to 48°C]
    temperature = np.random.uniform(28.0, 47.5, size=num_samples)

    # 2. Relative Humidity (%) [30% to 88%]
    humidity = np.random.uniform(30.0, 85.0, size=num_samples)

    # 3. Calculated Heat Index (°C)
    heat_index = calculate_heat_index(temperature, humidity)

    # 4. Electricity Demand % (Calibrated: sharp surge above 35°C due to air conditioning load)
    base_demand = np.random.uniform(45.0, 65.0, size=num_samples)
    heat_surge = np.maximum(0.0, temperature - 34.0) * 3.2
    extreme_heat_surge = np.maximum(0.0, temperature - 39.0) ** 1.5 * 2.5
    noise_demand = np.random.normal(0.0, 3.0, size=num_samples)
    electricity_demand = np.clip(base_demand + heat_surge + extreme_heat_surge + noise_demand, 35.0, 99.5)

    # 5. Outage Probability (0.0 to 1.0)
    # Rises exponentially when grid demand exceeds 75% and temperatures exceed 38°C (transformer thermal stress)
    grid_strain = (electricity_demand - 70.0) / 10.0
    thermal_stress = np.maximum(0.0, temperature - 37.0) / 4.0
    logistic_outage = 1.0 / (1.0 + np.exp(-(grid_strain + thermal_stress * 1.5)))
    outage_prob = np.clip(logistic_outage * 0.85 + np.random.uniform(0.01, 0.08, size=num_samples), 0.01, 0.95)

    # 6. Population Density (people per km²) [10,000 to 35,000]
    pop_density = np.random.uniform(10000.0, 34000.0, size=num_samples)

    # 7. Baseline Vulnerability Index (0.35 to 0.95)
    vulnerability = np.random.uniform(0.35, 0.95, size=num_samples)

    # Calculate Ground-Truth Compound Risk Target (0.0 - 100.0)
    # Interacting non-linear disaster risk model
    norm_temp = (temperature - 28.0) / 20.0
    norm_hi = (heat_index - 30.0) / 26.0
    norm_demand = electricity_demand / 100.0
    norm_outage = outage_prob
    norm_density = pop_density / 35000.0
    norm_vuln = vulnerability

    # Compound Interaction: High heat + high grid stress + high vulnerability creates compounded risk
    compound_heat_stress = norm_hi * 0.28 + norm_temp * 0.18
    compound_grid_stress = (norm_demand * 0.18 + norm_outage * 0.16) * (1.0 + np.maximum(0.0, norm_temp - 0.5) * 0.5)
    compound_human_exposure = (norm_density * 0.08 + norm_vuln * 0.12) * (1.0 + compound_heat_stress * 0.3)

    raw_risk = (compound_heat_stress + compound_grid_stress + compound_human_exposure) * 100.0
    noise_risk = np.random.normal(0.0, 1.5, size=num_samples)
    compound_risk = np.clip(raw_risk + noise_risk, 5.0, 99.5)

    X = np.column_stack([
        temperature,
        humidity,
        heat_index,
        electricity_demand,
        outage_prob,
        pop_density,
        vulnerability,
    ]).astype(np.float32)

    y = compound_risk.astype(np.float32)

    feature_names = [
        "temperature",
        "humidity",
        "heat_index",
        "electricity_demand_pct",
        "outage_probability",
        "population_density",
        "vulnerability_index",
    ]

    return X, y, feature_names


def train_and_export() -> None:
    """Train Gradient Boosting Regressor and export ONNX model and metadata."""
    print("==================================================")
    print("CoolNet AI - Training Real Compound Risk ML Model")
    print("==================================================")

    from sklearn.ensemble import GradientBoostingRegressor
    from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
    from sklearn.model_selection import train_test_split
    from skl2onnx import convert_sklearn
    from skl2onnx.common.data_types import FloatTensorType
    import onnxruntime as ort

    # 1. Generate calibrated dataset
    print("[1/5] Generating calibrated synthetic meteorological & grid dataset (5,000 samples)...")
    X, y, feature_names = generate_synthetic_dataset(num_samples=5000)

    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    # 2. Train Regressor
    print("[2/5] Training GradientBoostingRegressor (100 estimators, max_depth=4)...")
    model = GradientBoostingRegressor(
        n_estimators=100,
        learning_rate=0.1,
        max_depth=4,
        random_state=42,
        loss="squared_error",
    )
    model.fit(X_train, y_train)

    # 3. Evaluate Performance
    y_pred = model.predict(X_test)
    r2 = r2_score(y_test, y_pred)
    mae = mean_absolute_error(y_test, y_pred)
    rmse = math.sqrt(mean_squared_error(y_test, y_pred))

    print(f"[3/5] Model Performance Metrics on Held-Out Test Set:")
    print(f"      - R² Score: {r2:.4f}")
    print(f"      - Mean Absolute Error (MAE): {mae:.2f} points (on 0-100 scale)")
    print(f"      - Root Mean Squared Error (RMSE): {rmse:.2f} points")

    # 4. Feature Importances
    importances = model.feature_importances_
    feature_importance_dict = {
        name: float(round(imp, 4)) for name, imp in zip(feature_names, importances)
    }
    print(f"[4/5] Model Feature Importances:")
    for name, imp in sorted(feature_importance_dict.items(), key=lambda x: x[1], reverse=True):
        print(f"      - {name:25s}: {imp * 100:.2f}%")

    # 5. Export to ONNX
    output_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "public", "models"))
    os.makedirs(output_dir, exist_ok=True)

    onnx_file_path = os.path.join(output_dir, "coolnet_risk_model.onnx")
    meta_file_path = os.path.join(output_dir, "feature_importances.json")

    print(f"[5/5] Exporting ONNX model to: {onnx_file_path}")
    initial_type = [("float_input", FloatTensorType([None, len(feature_names)]))]
    onnx_model = convert_sklearn(model, initial_types=initial_type, target_opset=12)

    with open(onnx_file_path, "wb") as f:
        f.write(onnx_model.SerializeToString())

    # Save feature importances and metadata
    metadata = {
        "model_type": "GradientBoostingRegressor",
        "target": "compound_risk_score (0-100)",
        "r2_score": float(round(r2, 4)),
        "mae": float(round(mae, 2)),
        "rmse": float(round(rmse, 2)),
        "feature_order": feature_names,
        "feature_importances": feature_importance_dict,
        "export_timestamp": "2026-08-19",
    }

    with open(meta_file_path, "w", encoding="utf-8") as f:
        json.dump(metadata, f, indent=2)

    # 6. Verify with onnxruntime
    print("\n[VERIFICATION] Verifying ONNX model inference using onnxruntime...")
    session = ort.InferenceSession(onnx_file_path)
    input_name = session.get_inputs()[0].name
    output_name = session.get_outputs()[0].name

    test_sample = np.array([[42.5, 68.0, 52.0, 92.0, 0.65, 26000.0, 0.85]], dtype=np.float32)
    ort_pred = session.run([output_name], {input_name: test_sample})[0][0][0]
    sklearn_pred = model.predict(test_sample)[0]

    print(f"      - Sklearn Prediction: {sklearn_pred:.2f}")
    print(f"      - ONNX Prediction:    {ort_pred:.2f}")
    assert abs(sklearn_pred - ort_pred) < 0.05, "ONNX and Sklearn predictions mismatch!"
    print("      [OK] ONNX Model Verification Passed Perfectly!")
    print(f"\n[SUCCESS] Model & Feature Importances successfully exported to public/models/!")


if __name__ == "__main__":
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")
    train_and_export()
