import frappe
from frappe.model.document import Document


class PriceListPart(Document):
    """Price List Part DocType controller"""

    def validate(self):
        self.validate_dates()
        self.validate_price()

    def validate_dates(self):
        """Validate dates"""
        if self.valid_from and self.valid_until:
            if self.valid_from > self.valid_until:
                frappe.throw(frappe._("Valid from date cannot be after valid until date"))

    def validate_price(self):
        """Validate price is positive"""
        if self.price and self.price < 0:
            frappe.throw(frappe._("Price cannot be negative"))

    def before_save(self):
        """Before save hook"""
        pass

    def after_insert(self):
        """After insert hook"""
        pass

    def on_update(self):
        """On update hook"""
        pass

    def on_trash(self):
        """On trash hook"""
        pass
