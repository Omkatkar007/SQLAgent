"""Test suite for SQLAgent.
Tests configuration, database introspection, query validation, and end-to-end question answering.
"""

import unittest
from config import get_config
from database import DatabaseManager, serialize_db_value, make_json_serializable
from sql_agent import SQLAgent
from decimal import Decimal
from datetime import datetime, date


class TestSQLAgent(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        cls.config = get_config()
        cls.db = DatabaseManager(cls.config)
        cls.agent = SQLAgent(cls.config, cls.db)

    def test_database_connection(self):
        ok, err = self.db.test_connection()
        self.assertTrue(ok, f"Database connection failed: {err}")

    def test_schema_introspection(self):
        schema = self.db.get_schema()
        self.assertIn("fintech_customer", schema)
        self.assertIn("fintech_account", schema)
        cols = schema["fintech_customer"]["column_names"]
        self.assertIn("customer_id", cols)
        self.assertIn("first_name", cols)

    def test_json_serialization(self):
        data = {
            "dec": Decimal("1234.50"),
            "dec_int": Decimal("100.00"),
            "dt": datetime(2026, 9, 19, 15, 0, 0),
            "d": date(2026, 9, 19),
            "none_val": None,
            "int_val": 42,
            "str_val": "test"
        }
        converted = make_json_serializable(data)
        self.assertEqual(converted["dec"], 1234.5)
        self.assertEqual(converted["dec_int"], 100)
        self.assertEqual(converted["dt"], "2026-09-19T15:00:00")
        self.assertEqual(converted["d"], "2026-09-19")
        self.assertIsNone(converted["none_val"])
        self.assertEqual(converted["int_val"], 42)

    def test_safety_guardrails(self):
        # Queries that must be rejected
        unsafe_queries = [
            "DROP TABLE fintech_customer",
            "DELETE FROM fintech_account WHERE id=1",
            "UPDATE fintech_customer SET first_name='hacked'",
            "INSERT INTO fintech_user (username) VALUES ('bad')",
            "TRUNCATE TABLE fintech_transaction",
            "ALTER TABLE fintech_account DROP COLUMN balance",
        ]
        for q in unsafe_queries:
            is_valid, _, err = self.agent.clean_and_validate_sql(q, max_rows=10)
            self.assertFalse(is_valid, f"Expected unsafe query to be rejected: {q}")
            self.assertIsNotNone(err)

    def test_limit_enforcement(self):
        query = "SELECT first_name FROM fintech_customer"
        is_valid, cleaned, _ = self.agent.clean_and_validate_sql(query, max_rows=25)
        self.assertTrue(is_valid)
        self.assertTrue(cleaned.endswith("LIMIT 25"))

    def test_end_to_end_customer_count(self):
        result = self.agent.ask("How many customers are there?")
        self.assertEqual(result["status"], "success")
        self.assertEqual(result["row_count"], 1)
        self.assertIsNone(result["error"])
        first_row = result["data"][0]
        # Any count column name (e.g. COUNT(*), total, count)
        count_val = list(first_row.values())[0]
        self.assertGreater(count_val, 0)

    def test_end_to_end_account_types(self):
        result = self.agent.ask("What account types exist?")
        self.assertEqual(result["status"], "success")
        self.assertGreater(result["row_count"], 0)
        self.assertIsNone(result["error"])


if __name__ == "__main__":
    unittest.main()
