import frappe
from frappe import _


def execute(filters=None):
    """OEM Performance Report"""
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
            "fieldname": "total_rfqs",
            "fieldtype": "Int",
            "label": _("Total RFQs"),
            "width": 80,
        },
        {
            "fieldname": "won_rfqs",
            "fieldtype": "Int",
            "label": _("Won RFQs"),
            "width": 80,
        },
        {
            "fieldname": "win_rate",
            "fieldtype": "Percent",
            "label": _("Win Rate"),
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
            COUNT(*) as total_rfqs,
            SUM(CASE WHEN status = 'Won' THEN 1 ELSE 0 END) as won_rfqs,
            ROUND(SUM(CASE WHEN status = 'Won' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) as win_rate,
            COALESCE(SUM(CASE WHEN status = 'Won' THEN estimated_total ELSE 0 END), 0) as revenue
        FROM `tabRFQ`
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
        conditions.append(f"AND rfq_date >= '{filters.from_date}'")

    if filters.get("to_date"):
        conditions.append(f"AND rfq_date <= '{filters.to_date}'")

    return " ".join(conditions) if conditions else ""
