"""Pydantic schemas for CoolNet AI LLM Explanation Layer."""

from enum import Enum
from typing import Any, Dict, List, Optional
from pydantic import BaseModel, ConfigDict, Field, field_validator


class RiskLevel(str, Enum):
    """Standardized compound risk level categories."""
    LOW = "LOW"
    MODERATE = "MODERATE"
    HIGH = "HIGH"
    CRITICAL = "CRITICAL"


class DataStatusType(str, Enum):
    """Categorization for data provenance / status."""
    REAL = "real"
    SIMULATED = "simulated"
    ESTIMATED = "estimated"
    UNAVAILABLE = "unavailable"


class SHAPFactor(BaseModel):
    """Individual SHAP feature attribution from the upstream ML model."""
    feature: str = Field(..., min_length=1, description="Name of the feature")
    contribution: float = Field(..., description="SHAP numerical contribution value")

    model_config = ConfigDict(extra="forbid")


class KeyFactor(BaseModel):
    """Human-readable explanation of an individual SHAP feature factor."""
    factor: str = Field(..., min_length=1, description="Readable factor name")
    contribution: float = Field(..., description="Attributed numerical contribution")
    explanation: str = Field(..., min_length=1, description="Concise interpretation of the contribution")

    model_config = ConfigDict(extra="forbid")


class LLMInput(BaseModel):
    """Input evidence payload sent to the LLM explanation service."""
    ward_id: str = Field(..., min_length=1, max_length=50, description="Ward or administrative zone identifier")
    risk_score: float = Field(..., ge=0.0, le=1.0, description="External compound risk score in [0.0, 1.0]")
    risk_level: RiskLevel = Field(..., description="Categorical risk level (LOW, MODERATE, HIGH, CRITICAL)")
    data: Dict[str, Optional[float]] = Field(
        default_factory=dict,
        description="Observed ward metrics (e.g. temperature, humidity, power_stress, etc.)"
    )
    shap_factors: List[SHAPFactor] = Field(
        default_factory=list,
        description="List of SHAP feature contributions explaining the model prediction"
    )
    data_status: Optional[Dict[str, str]] = Field(
        default=None,
        description="Provenance of each data field (e.g. 'real', 'simulated', 'estimated', 'unavailable')"
    )
    timestamp: Optional[str] = Field(
        default=None,
        description="ISO timestamp of the prediction run"
    )

    @field_validator("ward_id")
    @classmethod
    def sanitize_ward_id(cls, v: str) -> str:
        v_clean = v.strip()
        if not v_clean:
            raise ValueError("ward_id cannot be empty or whitespace only")
        return v_clean

    model_config = ConfigDict(extra="forbid")


class LLMOutput(BaseModel):
    """Strict output schema expected from the LLM explanation service."""
    summary: str = Field(..., min_length=1, description="Short explanation of the current risk")
    risk_interpretation: str = Field(..., min_length=1, description="Human-readable interpretation of risk drivers")
    key_factors: List[KeyFactor] = Field(..., description="Key contributing factors to the model prediction")
    recommended_actions: List[str] = Field(..., description="Decision-support response suggestions")
    data_quality_note: str = Field(..., min_length=1, description="Explicit note on data provenance and reliability")
    limitations: List[str] = Field(..., description="List of methodological and data limitations")

    model_config = ConfigDict(extra="forbid")
