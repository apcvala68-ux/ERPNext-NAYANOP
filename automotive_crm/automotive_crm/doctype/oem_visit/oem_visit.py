import frappe
from frappe.model.document import Document


class OEMVisit(Document):
    """OEM Visit DocType controller"""

    def validate(self):
        self.validate_dates()

    def validate_dates(self):
        """Validate visit date is not in future"""
        if self.visit_date and self.visit_date > frappe.utils.today():
            frappe.msgprint(
                frappe._("Warning: Visit date is in the future"),
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
