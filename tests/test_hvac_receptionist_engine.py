from datetime import datetime
import sys
from pathlib import Path
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "src"))

from hvac_receptionist_engine import (  # noqa: E402
    IntakeState,
    build_greeting,
    detect_emergency,
    enforce_guardrails,
    get_dispatch_fee,
    guardrail_violations,
    in_service_area,
    offer_time_window_choices,
    ready_for_availability,
)


class TestHVACReceptionistEngine(unittest.TestCase):
    def test_greeting(self):
        self.assertIn("Apex Heating & Cooling", build_greeting())

    def test_detects_gas_smell_emergency(self):
        result = detect_emergency("I smell gas near the furnace")
        self.assertTrue(result.is_emergency)
        self.assertEqual(result.emergency_type, "gas_smell")
        self.assertTrue(result.requires_evacuation)

    def test_detects_no_heat_freezing_emergency(self):
        result = detect_emergency("We have no heat today", ambient_temp_f=22)
        self.assertTrue(result.is_emergency)
        self.assertEqual(result.emergency_type, "no_heat_freezing")

    def test_detects_major_ac_leak_emergency(self):
        result = detect_emergency("Our AC is pouring water into the hallway")
        self.assertTrue(result.is_emergency)
        self.assertEqual(result.emergency_type, "major_ac_leak")

    def test_non_emergency_when_conditions_not_met(self):
        result = detect_emergency("Need annual tune-up for our heat pump", ambient_temp_f=75)
        self.assertFalse(result.is_emergency)

    def test_service_area_check(self):
        self.assertTrue(in_service_area("Berrien"))
        self.assertFalse(in_service_area("Ottawa"))

    def test_ready_for_availability_requires_full_intake(self):
        incomplete = IntakeState(full_name="Alex", zip_code="49022")
        self.assertFalse(ready_for_availability(incomplete))

        complete = IntakeState(
            full_name="Alex Doe",
            service_address="12 Lake St",
            city="Benton Harbor",
            zip_code="49022",
            callback_phone="269-555-0100",
            equipment_type="furnace",
            symptoms="No heat from vents",
        )
        self.assertTrue(ready_for_availability(complete))

    def test_only_two_windows_are_offered(self):
        windows = [
            {"start": "2026-08-03T08:00:00", "end": "2026-08-03T10:00:00"},
            {"start": "2026-08-03T13:00:00", "end": "2026-08-03T15:00:00"},
            {"start": "2026-08-03T16:00:00", "end": "2026-08-03T18:00:00"},
        ]
        offered = offer_time_window_choices(windows)
        self.assertEqual(len(offered), 2)

    def test_non_two_hour_windows_are_rejected(self):
        windows = [{"start": "2026-08-03T08:00:00", "end": "2026-08-03T09:00:00"}]
        with self.assertRaises(ValueError):
            offer_time_window_choices(windows)

    def test_after_hours_emergency_fee(self):
        saturday = datetime(2026, 8, 1, 21, 0)
        monday = datetime(2026, 8, 3, 10, 0)
        self.assertEqual(get_dispatch_fee(saturday, is_emergency=True), 149)
        self.assertEqual(get_dispatch_fee(monday, is_emergency=True), 89)

    def test_guardrail_violations(self):
        violations = guardrail_violations("Your repair should be around $900 and we'll arrive at 9:15 AM.")
        self.assertIn("repair_estimate_quote", violations)
        self.assertIn("exact_arrival_time", violations)

    def test_guardrail_enforcement(self):
        response = enforce_guardrails("Open the panel and touch the wiring to reset it.")
        self.assertIn("can't provide DIY", response)


if __name__ == "__main__":
    unittest.main()
