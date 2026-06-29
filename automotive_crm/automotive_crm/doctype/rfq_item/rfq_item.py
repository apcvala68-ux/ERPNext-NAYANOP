import frappe
from frappe.model.document import Document


class RFQItem(Document):
    """RFQ Item DocType controller"""

    def validate(self):
        self.fetch_part_details()

    def fetch_part_details(self):
        """Fetch part details from Part Master"""
        if self.part_master:
            part = frappe.get_doc("Part Master", self.part_master)
            self.part_number = part.part_number
            self.description = part.description

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
