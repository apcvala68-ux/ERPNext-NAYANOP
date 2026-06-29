import frappe
from frappe.model.document import Document


class EightDReport(Document):
    """8D Report DocType controller"""

    def validate(self):
        self.validate_team()
        self.validate_actions()

    def validate_team(self):
        """Validate team has at least one member"""
        if not self.team:
            frappe.throw(frappe._("At least one team member is required"))

    def validate_actions(self):
        """Validate corrective actions are present"""
        if not self.corrective_actions:
            frappe.msgprint(
                frappe._("Warning: No corrective actions defined"),
                alert=True,
            )

    def before_submit(self):
        """Before submit hook"""
        self.status = "Completed"

    def before_cancel(self):
        """Before cancel hook"""
        self.status = "Open"

    def on_update(self):
        """On update hook"""
        if self.quality_complaint:
            frappe.db.set_value(
                "Quality Complaint", self.quality_complaint, "eight_d_report", self.name
            )

    def on_trash(self):
        """On trash hook"""
        pass
