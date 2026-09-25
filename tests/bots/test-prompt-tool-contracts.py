#!/usr/bin/env python3

import importlib.util
import json
import sys
import tempfile
import unittest
from pathlib import Path


MODULE_PATH = Path(__file__).with_name("audit-prompt-tool-contracts.py")
SPEC = importlib.util.spec_from_file_location("prompt_tool_contracts", MODULE_PATH)
assert SPEC and SPEC.loader
CONTRACTS = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = CONTRACTS
SPEC.loader.exec_module(CONTRACTS)


class PromptToolContractTests(unittest.TestCase):
    def test_exact_filter_is_supported(self):
        self.assertEqual(
            CONTRACTS.finding_rules(
                '`adl_query_records(entity_type="tasks", filters={"status":"open"}, limit=20)`'
            ),
            [],
        )

    def test_unsupported_shapes_are_classified(self):
        cases = {
            "adl_query_records filter: created_at > {last_run_timestamp}": "query_records_range_filter",
            "adl_query_records(entity_type=orders, invoices) in one query": "query_records_multi_entity",
            "adl_query_records filters: sentiment_score IS NULL": "query_records_null_filter",
            'adl_query_records(entity_type="snapshots", order_by="run_at desc")': "query_records_query_option",
            "adl_query_records entity_type=leads, sorted oldest first": "query_records_query_option",
        }
        for line, expected in cases.items():
            with self.subTest(line=line):
                self.assertIn(expected, CONTRACTS.finding_rules(line))

    def test_versioned_marketplace_cases_are_prompt_contract_failures(self):
        cases = [
            {
                "caseVersion": "anomaly-detector-delta@1.0.0",
                "instruction": "Step 3: adl_query_records with filter created_at > {last_run_timestamp}. ONE query for all new records",
                "expectedRules": {"query_records_range_filter"},
            },
            {
                "caseVersion": "business-analyst-cross-domain@1.0.0",
                "instruction": "Query cross-domain findings (adl_query_records filter: created_at > last_run, entity_type: *_findings)",
                "expectedRules": {"query_records_range_filter", "query_records_multi_entity"},
            },
            {
                "caseVersion": "data-validation-null@1.0.0",
                "instruction": "adl_query_records(entity_type=<target_type>) with filters validated_at IS NULL",
                "expectedRules": {"query_records_null_filter"},
            },
            {
                "caseVersion": "rank-tracking-order@1.0.0",
                "instruction": 'adl_query_records(entity_type="seo_rank_snapshot", filters={keyword=<kw>}, limit=1, order_by="run_at desc")',
                "expectedRules": {"query_records_query_option"},
            },
        ]
        self.assertEqual(len({case["caseVersion"] for case in cases}), len(cases))
        for case in cases:
            with self.subTest(case_version=case["caseVersion"]):
                self.assertEqual(
                    set(CONTRACTS.finding_rules(case["instruction"])),
                    case["expectedRules"],
                )

    def test_baseline_fingerprint_changes_with_instruction(self):
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            bot = root / "bots" / "sample"
            bot.mkdir(parents=True)
            prompt = bot / "BOT.md"
            prompt.write_text(
                "adl_query_records filter: created_at > {last_run_timestamp}\n",
                encoding="utf-8",
            )
            original = CONTRACTS.scan(root)
            self.assertEqual(len(original), 1)
            baseline_path = root / "baseline.json"
            CONTRACTS.write_baseline(baseline_path, original)
            baseline = CONTRACTS.load_baseline(baseline_path)
            self.assertIn(original[0].fingerprint, baseline)

            prompt.write_text(
                "adl_query_records filter: updated_at > {last_run_timestamp}\n",
                encoding="utf-8",
            )
            changed = CONTRACTS.scan(root)
            self.assertEqual(len(changed), 1)
            self.assertNotEqual(original[0].fingerprint, changed[0].fingerprint)
            self.assertNotIn(changed[0].fingerprint, baseline)

    def test_invalid_baseline_is_rejected(self):
        with tempfile.TemporaryDirectory() as temp_dir:
            path = Path(temp_dir) / "baseline.json"
            path.write_text(json.dumps({"schemaVersion": 999, "findings": []}), encoding="utf-8")
            with self.assertRaises(ValueError):
                CONTRACTS.load_baseline(path)


if __name__ == "__main__":
    unittest.main()
