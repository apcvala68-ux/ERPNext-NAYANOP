import frappe
from frappe import _


def execute(filters=None):
    """Cost Analysis Report"""
    columns = get_columns()
    data = get_data(filters)
    return columns, data


def get_columns():
    """Define report columns"""
    return [
        {
            "fieldname": "rfq",
            "fieldtype": "Link",
            "label": _("RFQ"),
            "options": "RFQ",
            "width": 120,
        },
        {
            "fieldname": "oem_customer",
            "fieldtype": "Link",
            "label": _("OEM Customer"),
            "options": "OEM Customer",
            "width": 200,
        },
        {
            "fieldname": "material_cost",
            "fieldtype": "Currency",
            "label": _("Material Cost"),
            "options": "INR",
            "width": 120,
        },
        {
            "fieldname": "labor_cost",
            "fieldtype": "Currency",
            "label": _("Labor Cost"),
            "options": "INR",
            "width": 120,
        },
        {
            "fieldname": "overhead_cost",
            "fieldtype": "Currency",
            "label": _("Overhead Cost"),
            "options": "INR",
            "width": 120,
        },
        {
            "fieldname": "total_cost",
            "fieldtype": "Currency",
            "label": _("Total Cost"),
            "options": "INR",
            "width": 120,
        },
    ]


def get_data(filters):
    """Get report data"""
    conditions = get_conditions(filters)

    data = frappe.db.sql(
        """
        SELECT
            cs.rfq,
            r.oem_customer,
            cs.material_cost,
            cs.labor_cost,
            cs.overhead_cost,
            cs.total_cost
        FROM `tabCost Sheet` cs
        JOIN `tabRFQ` r ON cs.rfq = r.name
        WHERE cs.docstatus = 1 {conditions}
        ORDER BY cs.creation DESC
        """.format(
            conditions=conditions
        ),
        as_dict=True,
    )

    return data


def get_conditions(filters):
    """Build SQL conditions from filters"""
    conditions = []

    if filters.get("oem_customer"):
        conditions.append(f"AND r.oem_customer = '{filters.oem_customer}'")

    if filters.get("from_date"):
        conditions.append(f"AND cs.creation >= '{filters.from_date}'")

    if filters.get("to_date"):
        conditions.append(f"AND cs.creation <= '{filters.to_date}'")

    return " ".join(conditions) if conditions else ""
