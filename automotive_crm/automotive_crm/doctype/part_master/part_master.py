import frappe
from frappe.model.document import Document


class PartMaster(Document):
    """Part Master DocType controller"""

    def validate(self):
        self.validate_dimensions()
        self.validate_tooling()

    def validate_dimensions(self):
        """Validate dimensions are provided if any"""
        dimensions = [self.dimension_length, self.dimension_width, self.dimension_height]
        if any(dimensions) and not all(dimensions):
            frappe.throw(frappe._("Please provide all dimensions (Length, Width, Height)"))

    def validate_tooling(self):
        """Validate tooling is linked if required"""
        if self.tooling_required and not self.tooling:
            frappe.throw(frappe._("Tooling is required for this part"))

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
