import frappe
from frappe.model.document import Document


class RFQ(Document):
    """RFQ DocType controller"""

    def validate(self):
        self.validate_items()
        self.calculate_totals()
        self.validate_dates()

    def validate_items(self):
        """Validate items are present"""
        if not self.items:
            frappe.throw(frappe._("At least one item is required"))

    def calculate_totals(self):
        """Calculate total items and estimated total"""
        self.total_items = len(self.items) if self.items else 0
        self.estimated_total = sum(item.estimated_cost for item in self.items) if self.items else 0

    def validate_dates(self):
        """Validate RFQ date is not after expected date"""
        if self.rfq_date and self.expected_date:
            if self.rfq_date > self.expected_date:
                frappe.throw(frappe._("RFQ date cannot be after expected date"))

    def before_submit(self):
        """Before submit hook"""
        self.status = "Received"

    def before_cancel(self):
        """Before cancel hook"""
        self.status = "Cancelled"

    def on_update(self):
        """On update hook"""
        pass

    def on_trash(self):
        """On trash hook"""
        pass
