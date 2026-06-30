import frappe
from frappe.model.document import Document


class Tooling(Document):
    """Tooling DocType controller"""

    def validate(self):
        self.validate_shot_count()
        self.validate_warranty()

    def validate_shot_count(self):
        """Validate shot count doesn't exceed max"""
        if self.max_shot_count and self.current_shot_count:
            if self.current_shot_count > self.max_shot_count:
                frappe.throw(frappe._("Current shot count exceeds maximum shot count"))

    def validate_warranty(self):
        """Validate warranty expiry"""
        if self.warranty_expiry and self.warranty_expiry < frappe.utils.today():
            frappe.msgprint(
                frappe._("Warning: Tooling warranty has expired!"),
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
