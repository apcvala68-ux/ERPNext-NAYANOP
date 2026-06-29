import frappe
from frappe import _


def execute(filters=None):
    """Revenue by OEM Report"""
    columns = get_columns()
    data = get_data(filters)
    return columns, data


def get_columns():
    """Define report columns"""
    return [
        {
            "fieldname": "oem_customer",
            "fieldtype": "Link",
            "label": _("OEM Customer"),
            "options": "OEM Customer",
            "width": 200,
        },
        {
            "fieldname": "total_quotations",
            "fieldtype": "Int",
            "label": _("Total Quotations"),
            "width": 100,
        },
        {
            "fieldname": "accepted",
            "fieldtype": "Int",
            "label": _("Accepted"),
            "width": 80,
        },
        {
            "fieldname": "rejected",
            "fieldtype": "Int",
            "label": _("Rejected"),
            "width": 80,
        },
        {
            "fieldname": "revenue",
            "fieldtype": "Currency",
            "label": _("Revenue"),
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
            oem_customer,
            COUNT(*) as total_quotations,
            SUM(CASE WHEN status = 'Accepted' THEN 1 ELSE 0 END) as accepted,
            SUM(CASE WHEN status = 'Rejected' THEN 1 ELSE 0 END) as rejected,
            SUM(CASE WHEN status = 'Accepted' THEN grand_total ELSE 0 END) as revenue
        FROM `tabQuotation`
        WHERE docstatus = 1 {conditions}
        GROUP BY oem_customer
        ORDER BY revenue DESC
        """.format(
            conditions=conditions
        ),
        as_dict=True,
    )

    return data


def get_conditions(filters):
    """Build SQL conditions from filters"""
    conditions = []

    if filters.get("from_date"):
        conditions.append(f"AND quotation_date >= '{filters.from_date}'")

    if filters.get("to_date"):
        conditions.append(f"AND quotation_date <= '{filters.to_date}'")

    return " ".join(conditions) if conditions else ""
