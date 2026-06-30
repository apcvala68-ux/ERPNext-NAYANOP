import frappe
from frappe.tests import IntegrationTestCase


class TestRFQToQuotationFlow(IntegrationTestCase):
    def test_full_rfq_to_quotation_flow(self):
        """Test complete RFQ → Cost Sheet → Quotation flow"""

        # 1. Create OEM Customer
        oem = frappe.get_doc(
            {
                "doctype": "OEM Customer",
                "customer_name": "Test OEM Corp",
                "tier": "Tier 1",
            }
        ).insert()

        # 2. Create Part Master
        part = frappe.get_doc(
            {
                "doctype": "Part Master",
                "part_number": "BRK-001",
                "description": "Brake Caliper",
                "category": "Metal",
            }
        ).insert()

        # 3. Create RFQ
        rfq = frappe.get_doc(
            {
                "doctype": "RFQ",
                "oem_customer": oem.name,
                "items": [{"part_master": part.name, "quantity": 1000, "required_date": "2026-12-31"}],
            }
        ).insert()

        self.assertEqual(rfq.status, "Draft")

        # 4. Create Cost Sheet
        cost_sheet = frappe.get_doc(
            {
                "doctype": "Cost Sheet",
                "rfq": rfq.name,
                "material_cost": 50000,
                "labor_cost": 20000,
                "overhead_cost": 10000,
                "tooling_cost": 5000,
                "total_cost": 85000,
            }
        ).insert()

        # 5. Create Quotation
        quotation = frappe.get_doc(
            {
                "doctype": "Quotation",
                "rfq": rfq.name,
                "oem_customer": oem.name,
                "items": [
                    {
                        "part_master": part.name,
                        "quantity": 1000,
                        "unit_price": 95,
                        "total": 95000,
                    }
                ],
                "currency": "INR",
            }
        ).insert()

        # Verify flow
        self.assertEqual(rfq.status, "Quoted")
        self.assertTrue(quotation.name)
