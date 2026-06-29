import frappe
from frappe.tests import IntegrationTestCase


class TestRFQ(IntegrationTestCase):
    def setUp(self):
        self.oem = frappe.get_doc(
            {
                "doctype": "OEM Customer",
                "customer_name": "Test OEM for RFQ",
                "tier": "Tier 1",
            }
        )
        self.oem.insert()

    def test_rfq_creation(self):
        """Test RFQ can be created"""
        rfq = frappe.get_doc(
            {
                "doctype": "RFQ",
                "oem_customer": self.oem.name,
                "items": [
                    {
                        "part_number": "BRK-001",
                        "description": "Brake Caliper",
                        "quantity": 1000,
                        "required_date": "2026-12-31",
                    }
                ],
            }
        )
        rfq.insert()

        self.assertTrue(rfq.name)
        self.assertEqual(rfq.status, "Draft")

    def test_rfq_workflow(self):
        """Test RFQ workflow transitions"""
        rfq = frappe.get_doc(
            {
                "doctype": "RFQ",
                "oem_customer": self.oem.name,
                "items": [
                    {
                        "part_number": "BRK-002",
                        "description": "Brake Pad",
                        "quantity": 5000,
                        "required_date": "2026-12-31",
                    }
                ],
            }
        )
        rfq.insert()

        rfq.submit()
        self.assertEqual(rfq.docstatus, 1)
