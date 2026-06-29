import frappe
from frappe.model.document import Document


class OEMPlant(Document):
    """OEM Plant DocType controller"""

    def validate(self):
        self.validate_oem_customer()

    def validate_oem_customer(self):
        """Validate OEM customer exists"""
        if self.oem_customer and not frappe.db.exists("OEM Customer", self.oem_customer):
            frappe.throw(frappe._("OEM Customer {0} does not exist").format(self.oem_customer))

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
