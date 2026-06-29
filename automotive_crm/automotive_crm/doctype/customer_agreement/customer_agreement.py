import frappe
from frappe.model.document import Document


class CustomerAgreement(Document):
    """Customer Agreement DocType controller"""

    def validate(self):
        self.validate_dates()
        self.validate_status()

    def validate_dates(self):
        """Validate dates"""
        if self.start_date and self.end_date:
            if self.start_date > self.end_date:
                frappe.throw(frappe._("Start date cannot be after end date"))

    def validate_status(self):
        """Validate status based on dates"""
        if self.end_date and self.end_date < frappe.utils.today():
            if self.status == "Active":
                frappe.msgprint(
                    frappe._("Warning: Agreement has expired"),
                    alert=True,
                )

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
