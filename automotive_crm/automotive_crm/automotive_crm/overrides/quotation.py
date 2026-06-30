import frappe
from frappe import _


class Quotation:
    """Override Quotation DocType"""

    def validate(self):
        self.validate_oem_customer()
        self.calculate_totals()

    def validate_oem_customer(self):
        """Validate OEM customer is set"""
        if self.oem_customer and not frappe.db.exists("OEM Customer", self.oem_customer):
            frappe.throw(_("OEM Customer {0} does not exist").format(self.oem_customer))

    def calculate_totals(self):
        """Calculate quotation totals"""
        self.total_amount = sum(item.amount for item in self.items) if self.items else 0
        self.grand_total = self.total_amount + (self.tax_amount or 0)
