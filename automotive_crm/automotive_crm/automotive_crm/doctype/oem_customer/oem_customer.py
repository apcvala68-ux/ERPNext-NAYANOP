import frappe
from frappe.model.document import Document


class OEMCustomer(Document):
    """OEM Customer DocType controller"""

    def validate(self):
        self.validate_certification()
        self.calculate_statistics()

    def validate_certification(self):
        """Validate certification expiry"""
        if self.certification_expiry and self.certification_expiry < frappe.utils.today():
            frappe.msgprint(
                frappe._("Warning: Certification has expired!"),
                alert=True,
            )

    def calculate_statistics(self):
        """Calculate statistics for this OEM customer"""
        self.total_deals = frappe.db.count("CRM Deal", {"oem_customer": self.name})
        self.total_rfqs = frappe.db.count("RFQ", {"oem_customer": self.name})
        self.total_quotations = frappe.db.count("Quotation", {"oem_customer": self.name})

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
