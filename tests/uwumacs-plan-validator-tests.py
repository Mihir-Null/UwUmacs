"""Acceptance evidence must be usable, not merely syntactically present."""
import copy
import importlib.util
from pathlib import Path
import subprocess
import unittest

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("validator", ROOT / "docs/uwumacs/validate-plan.py")
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)

class EvidenceTests(unittest.TestCase):
    def setUp(self):
        self.records = [{"id": "I001", "acceptance_task": "P03"}]
        self.progress = {"I001": {"status": "pending", "commit": None,
            "target_version": None, "tests": [], "limitations": []}}
    def validate(self):
        MODULE.validate_evidence(self.records, self.progress, ROOT)
    def verified(self):
        self.progress["I001"].update(status="verified", commit=subprocess.check_output(
            ["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip(),
            target_version="GNU Emacs 30.1", tests=["uwumacs-real-behavior"])
    def test_pending_and_real_verified(self):
        self.validate()
        self.verified()
        self.validate()
    def test_missing_id(self):
        self.progress.clear()
        with self.assertRaises(AssertionError): self.validate()
    def test_extra_id(self):
        self.progress["I999"] = copy.deepcopy(self.progress["I001"])
        with self.assertRaises(AssertionError): self.validate()
    def test_invalid_task(self):
        self.records[0]["acceptance_task"] = "P99"
        with self.assertRaises(AssertionError): self.validate()
    def test_invalid_status(self):
        self.progress["I001"]["status"] = "passed"
        with self.assertRaises(AssertionError): self.validate()
    def test_fabricated_commit(self):
        self.verified()
        self.progress["I001"]["commit"] = "f" * 40
        with self.assertRaises(AssertionError): self.validate()
    def test_verified_without_tests(self):
        self.verified()
        self.progress["I001"]["tests"] = []
        with self.assertRaises(AssertionError): self.validate()
    def test_verified_without_version(self):
        self.verified()
        self.progress["I001"]["target_version"] = " "
        with self.assertRaises(AssertionError): self.validate()
    def test_limited_without_limitations(self):
        self.progress["I001"]["status"] = "capability-limited"
        with self.assertRaises(AssertionError): self.validate()
    def test_fields_are_exact_and_typed(self):
        self.progress["I001"]["tests"] = "fake-list"
        with self.assertRaises(AssertionError): self.validate()
        self.progress["I001"]["tests"] = []
        self.progress["I001"]["extra"] = True
        with self.assertRaises(AssertionError): self.validate()

if __name__ == "__main__": unittest.main()
