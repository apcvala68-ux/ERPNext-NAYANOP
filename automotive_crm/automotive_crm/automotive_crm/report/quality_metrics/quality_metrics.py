import frappe
from frappe import _


def execute(filters=None):
    """Quality Metrics Report"""
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
            "fieldname": "total_complaints",
            "fieldtype": "Int",
            "label": _("Total Complaints"),
            "width": 100,
        },
        {
            "fieldname": "critical",
            "fieldtype": "Int",
            "label": _("Critical"),
            "width": 80,
        },
        {
            "fieldname": "major",
            "fieldtype": "Int",
            "label": _("Major"),
            "width": 80,
        },
        {
            "fieldname": "minor",
            "fieldtype": "Int",
            "label": _("Minor"),
            "width": 80,
        },
        {
            "fieldname": "open_count",
            "fieldtype": "Int",
            "label": _("Open"),
            "width": 80,
        },
        {
            "fieldname": "resolved",
            "fieldtype": "Int",
            "label": _("Resolved"),
            "width": 80,
        },
    ]


def get_data(filters):
    """Get report data"""
    conditions = get_conditions(filters)

    data = frappe.db.sql(
        """
        SELECT
            oem_customer,
            COUNT(*) as total_complaints,
            SUM(CASE WHEN severity = 'Critical' THEN 1 ELSE 0 END) as critical,
            SUM(CASE WHEN severity = 'Major' THEN 1 ELSE 0 END) as major,
            SUM(CASE WHEN severity = 'Minor' THEN 1 ELSE 0 END) as minor,
            SUM(CASE WHEN status IN ('Open', 'In Progress') THEN 1 ELSE 0 END) as open_count,
            SUM(CASE WHEN status IN ('Resolved', 'Closed') THEN 1 ELSE 0 END) as resolved
        FROM `tabQuality Complaint`
        WHERE docstatus = 1 {conditions}
        GROUP BY oem_customer
        ORDER BY total_complaints DESC
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
        conditions.append(f"AND complaint_date >= '{filters.from_date}'")

    if filters.get("to_date"):
        conditions.append(f"AND complaint_date <= '{filters.to_date}'")

    return " ".join(conditions) if conditions else ""
