import frappe
from frappe.model.document import Document


class QualityComplaint(Document):
    """Quality Complaint DocType controller"""

    def validate(self):
        self.validate_severity()

    def validate_severity(self):
        """Validate critical complaints have 8D report"""
        if self.severity == "Critical" and not self.eight_d_report:
            frappe.msgprint(
                frappe._("Warning: Critical complaints should have an 8D Report"),
                alert=True,
            )

    def before_submit(self):
        """Before submit hook"""
        self.status = "Open"

    def before_cancel(self):
        """Before cancel hook"""
        self.status = "Closed"

    def on_update(self):
        """On update hook"""
        pass

    def on_trash(self):
        """On trash hook"""
        pass
