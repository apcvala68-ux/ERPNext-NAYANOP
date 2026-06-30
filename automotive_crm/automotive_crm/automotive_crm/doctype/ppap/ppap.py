import frappe
from frappe.model.document import Document


class PPAP(Document):
    """PPAP DocType controller"""

    def validate(self):
        self.validate_documents()

    def validate_documents(self):
        """Validate required PPAP documents are attached"""
        required_docs = [
            ("design_record", "Design Record"),
            ("process_flow", "Process Flow Diagram"),
            ("control_plan", "Control Plan"),
        ]

        for fieldname, label in required_docs:
            if not getattr(self, fieldname, None):
                frappe.msgprint(
                    frappe._("Warning: {0} is not attached").format(label),
                    alert=True,
                )

    def before_submit(self):
        """Before submit hook"""
        self.status = "Submitted"

    def before_cancel(self):
        """Before cancel hook"""
        self.status = "Cancelled"

    def on_update(self):
        """On update hook"""
        pass

    def on_trash(self):
        """On trash hook"""
        pass
