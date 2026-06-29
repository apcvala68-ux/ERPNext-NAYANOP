import frappe
from frappe import _


def execute(filters=None):
    """RFQ Summary Report"""
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
            "fieldname": "status",
            "fieldtype": "Data",
            "label": _("Status"),
            "width": 100,
        },
        {
            "fieldname": "count",
            "fieldtype": "Int",
            "label": _("Count"),
            "width": 80,
        },
        {
            "fieldname": "total_estimated",
            "fieldtype": "Currency",
            "label": _("Total Estimated"),
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
            status,
            COUNT(*) as count,
            SUM(estimated_total) as total_estimated
        FROM `tabRFQ`
        WHERE docstatus = 1 {conditions}
        GROUP BY oem_customer, status
        ORDER BY oem_customer, status
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
        conditions.append(f"AND oem_customer = '{filters.oem_customer}'")

    if filters.get("from_date"):
        conditions.append(f"AND rfq_date >= '{filters.from_date}'")

    if filters.get("to_date"):
        conditions.append(f"AND rfq_date <= '{filters.to_date}'")

    return " ".join(conditions) if conditions else ""
