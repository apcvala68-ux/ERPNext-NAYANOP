import frappe
from frappe.model.document import Document


class Quotation(Document):
    """Quotation DocType controller"""

    def validate(self):
        self.validate_items()
        self.calculate_totals()
        self.validate_dates()

    def validate_items(self):
        """Validate items are present"""
        if not self.items:
            frappe.throw(frappe._("At least one item is required"))

    def calculate_totals(self):
        """Calculate totals"""
        self.subtotal = sum(item.amount for item in self.items) if self.items else 0
        self.tax_amount = self.subtotal * (self.tax_rate or 0) / 100
        self.grand_total = self.subtotal + self.tax_amount

    def validate_dates(self):
        """Validate dates"""
        if self.quotation_date and self.valid_until:
            if self.quotation_date > self.valid_until:
                frappe.throw(frappe._("Quotation date cannot be after valid until date"))

    def before_submit(self):
        """Before submit hook"""
        self.status = "Submitted"

    def before_cancel(self):
        """Before cancel hook"""
        self.status = "Cancelled"

    def on_update(self):
        """On update hook"""
        if self.rfq:
            frappe.db.set_value("RFQ", self.rfq, "quotation", self.name)

    def on_trash(self):
        """On trash hook"""
        pass
