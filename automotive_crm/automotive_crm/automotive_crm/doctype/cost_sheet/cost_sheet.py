import frappe
from frappe.model.document import Document


class CostSheet(Document):
    """Cost Sheet DocType controller"""

    def validate(self):
        self.calculate_totals()
        self.validate_costs()

    def calculate_totals(self):
        """Calculate total cost and selling price"""
        self.total_cost = (
            (self.material_cost or 0)
            + (self.labor_cost or 0)
            + (self.overhead_cost or 0)
            + (self.tooling_cost or 0)
            + (self.quality_cost or 0)
            + (self.packaging_cost or 0)
            + (self.logistics_cost or 0)
        )

        # Calculate cost per unit from RFQ
        if self.rfq:
            rfq = frappe.get_doc("RFQ", self.rfq)
            total_quantity = sum(item.quantity for item in rfq.items) if rfq.items else 0
            if total_quantity > 0:
                self.cost_per_unit = self.total_cost / total_quantity

        # Calculate selling price with margin
        if self.margin_percentage:
            self.selling_price = self.total_cost * (1 + self.margin_percentage / 100)
        else:
            self.selling_price = self.total_cost

    def validate_costs(self):
        """Validate costs are positive"""
        costs = [
            self.material_cost,
            self.labor_cost,
            self.overhead_cost,
            self.tooling_cost,
            self.quality_cost,
            self.packaging_cost,
            self.logistics_cost,
        ]

        for cost in costs:
            if cost and cost < 0:
                frappe.throw(frappe._("Costs cannot be negative"))

    def before_submit(self):
        """Before submit hook"""
        pass

    def on_update(self):
        """On update hook"""
        if self.rfq:
            frappe.db.set_value("RFQ", self.rfq, "cost_sheet", self.name)

    def on_trash(self):
        """On trash hook"""
        pass
