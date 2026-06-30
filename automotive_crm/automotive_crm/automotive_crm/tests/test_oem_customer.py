import frappe
from frappe.tests import IntegrationTestCase


class TestOEMCustomer(IntegrationTestCase):
    def setUp(self):
        self.oem = frappe.get_doc(
            {
                "doctype": "OEM Customer",
                "customer_name": "Test Automotive OEM",
                "tier": "Tier 1",
                "certification": "ISO 9001",
                "country": "India",
            }
        )

    def test_oem_creation(self):
        """Test OEM customer can be created"""
        self.oem.insert()
        self.assertTrue(self.oem.name)
        self.assertEqual(self.oem.tier, "Tier 1")

    def test_oem_validation(self):
        """Test mandatory field validation"""
        oem = frappe.get_doc({"doctype": "OEM Customer"})
        self.assertRaises(frappe.ValidationError, oem.insert)

    def test_oem_with_plants(self):
        """Test OEM with multiple plants"""
        self.oem.insert()

        plant = frappe.get_doc(
            {
                "doctype": "OEM Plant",
                "oem_customer": self.oem.name,
                "plant_code": "P001",
                "plant_name": "Main Plant",
                "address": "Mumbai, India",
            }
        )
        plant.insert()

        self.assertEqual(plant.oem_customer, self.oem.name)
