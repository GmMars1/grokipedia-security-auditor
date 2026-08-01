from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timedelta
import re
from typing import Iterable, List, Optional, Sequence

OPERATING_START_HOUR = 7
OPERATING_END_HOUR = 18
SUPPORTED_COUNTIES = {"berrien", "van buren", "cass"}
STANDARD_DIAGNOSTIC_FEE = 89
EMERGENCY_DISPATCH_FEE = 149

REPAIR_QUOTE_MESSAGE = (
    "Our certified technician will assess the system on-site and provide an exact "
    "upfront quote before any work begins."
)


@dataclass
class IntakeState:
    full_name: str = ""
    service_address: str = ""
    city: str = ""
    zip_code: str = ""
    callback_phone: str = ""
    equipment_type: str = ""
    symptoms: str = ""


@dataclass
class EmergencyAssessment:
    is_emergency: bool
    emergency_type: Optional[str] = None
    requires_evacuation: bool = False
    escalation_message: Optional[str] = None


def build_greeting() -> str:
    return "Thanks for calling Apex Heating & Cooling! This is Sam. How can I help you today?"


def is_business_hours(now: datetime) -> bool:
    return now.weekday() < 5 and OPERATING_START_HOUR <= now.hour < OPERATING_END_HOUR


def get_dispatch_fee(now: datetime, is_emergency: bool) -> int:
    if is_emergency and not is_business_hours(now):
        return EMERGENCY_DISPATCH_FEE
    return STANDARD_DIAGNOSTIC_FEE


def in_service_area(county: str) -> bool:
    return county.strip().lower() in SUPPORTED_COUNTIES


def detect_emergency(symptoms: str, ambient_temp_f: Optional[float] = None) -> EmergencyAssessment:
    text = symptoms.lower()

    if any(keyword in text for keyword in ("gas smell", "smell gas", "gas leak", "odor of gas")):
        return EmergencyAssessment(
            is_emergency=True,
            emergency_type="gas_smell",
            requires_evacuation=True,
            escalation_message=(
                "Please evacuate immediately and call 911 or your gas utility from outside. "
                "I am escalating this to our on-call emergency technician now."
            ),
        )

    no_heat = any(phrase in text for phrase in ("no heat", "heater not working", "furnace not heating"))
    if no_heat and ambient_temp_f is not None and ambient_temp_f < 40:
        return EmergencyAssessment(
            is_emergency=True,
            emergency_type="no_heat_freezing",
            escalation_message=(
                "This is high priority due to freezing conditions. "
                "I can dispatch our on-call technician right away."
            ),
        )

    major_leak = any(word in text for word in ("flood", "pouring", "major leak", "leaking badly"))
    ac_context = any(word in text for word in ("ac", "air conditioner", "central air", "mini split"))
    if major_leak and ac_context:
        return EmergencyAssessment(
            is_emergency=True,
            emergency_type="major_ac_leak",
            escalation_message="This qualifies for emergency dispatch, and I am escalating to our on-call technician.",
        )

    return EmergencyAssessment(is_emergency=False)


def missing_required_fields(state: IntakeState) -> List[str]:
    ordered = [
        ("full_name", state.full_name),
        ("service_address", state.service_address),
        ("callback_phone", state.callback_phone),
        ("equipment_type", state.equipment_type),
        ("symptoms", state.symptoms),
    ]
    return [name for name, value in ordered if not value.strip()]


def ready_for_availability(state: IntakeState) -> bool:
    return len(missing_required_fields(state)) == 0 and bool(state.zip_code.strip())


def validate_two_hour_windows(windows: Sequence[dict]) -> None:
    for window in windows:
        start = datetime.fromisoformat(window["start"])
        end = datetime.fromisoformat(window["end"])
        if end - start != timedelta(hours=2):
            raise ValueError("Arrival windows must be exactly 2 hours.")


def offer_time_window_choices(windows: Sequence[dict]) -> List[dict]:
    validate_two_hour_windows(windows)
    return list(windows[:2])


def format_window_choices(windows: Sequence[dict]) -> str:
    choices = offer_time_window_choices(windows)
    if not choices:
        return "I don't have an opening to offer yet, but I can keep looking for the next available 2-hour window."

    formatted = []
    for option in choices:
        start = datetime.fromisoformat(option["start"])
        end = datetime.fromisoformat(option["end"])
        formatted.append(
            f"{start.strftime('%A %b %d')} between {start.strftime('%-I:%M %p')} and {end.strftime('%-I:%M %p')}"
        )

    if len(formatted) == 1:
        return f"I have one opening: {formatted[0]}. Does that work for you?"

    return f"I have an opening {formatted[0]}, or {formatted[1]}. Which works better for you?"


def booking_confirmation(date_label: str, time_window_label: str, address: str, phone: str) -> str:
    return (
        f"Great, I've got you scheduled for {date_label}, between {time_window_label} at {address}. "
        f"You'll receive a text confirmation at {phone}, and our technician will call 30 minutes before arrival. "
        "Is there anything else I can assist with today?"
    )


def guardrail_violations(text: str) -> List[str]:
    violations: List[str] = []
    lowered = text.lower()

    repair_estimate_pattern = re.compile(r"\$\s*\d+")
    allowed_fees = {"$89", "$149"}
    quoted_amounts = set(repair_estimate_pattern.findall(text.replace(" ", "")))
    if quoted_amounts and not quoted_amounts.issubset(allowed_fees):
        violations.append("repair_estimate_quote")

    diy_markers = ["open the panel", "touch the wiring", "adjust refrigerant", "turn the gas valve"]
    if any(marker in lowered for marker in diy_markers):
        violations.append("unsafe_diy_advice")

    exact_arrival_pattern = re.compile(r"\b(at|around)\s+\d{1,2}(:\d{2})?\s?(am|pm)\b", re.IGNORECASE)
    if exact_arrival_pattern.search(text):
        violations.append("exact_arrival_time")

    return violations


def enforce_guardrails(text: str) -> str:
    violations = guardrail_violations(text)
    if "repair_estimate_quote" in violations:
        return REPAIR_QUOTE_MESSAGE
    if "unsafe_diy_advice" in violations:
        return "For safety, I can't provide DIY instructions for gas, wiring, or refrigerant systems. I can schedule a technician now."
    if "exact_arrival_time" in violations:
        return "We provide a 2-hour arrival window, and the technician will call about 30 minutes before arrival."
    return text
