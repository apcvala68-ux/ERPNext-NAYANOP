import frappe
from frappe import _


def execute(filters=None):
    """Tooling Utilization Report"""
    columns = get_columns()
    data = get_data(filters)
    return columns, data


def get_columns():
    """Define report columns"""
    return [
        {
            "fieldname": "tooling_code",
            "fieldtype": "Data",
            "label": _("Tooling Code"),
            "width": 120,
        },
        {
            "fieldname": "tooling_name",
            "fieldtype": "Data",
            "label": _("Tooling Name"),
            "width": 200,
        },
        {
            "fieldname": "tooling_type",
            "fieldtype": "Data",
            "label": _("Type"),
            "width": 100,
        },
        {
            "fieldname": "status",
            "fieldtype": "Data",
            "label": _("Status"),
            "width": 100,
        },
        {
            "fieldname": "current_shot_count",
            "fieldtype": "Int",
            "label": _("Current Shots"),
            "width": 100,
        },
        {
            "fieldname": "max_shot_count",
            "fieldtype": "Int",
            "label": _("Max Shots"),
            "width": 100,
        },
        {
            "fieldname": "utilization",
            "fieldtype": "Percent",
            "label": _("Utilization"),
            "width": 80,
        },
    ]


def get_data(filters):
    """Get report data"""
    conditions = get_conditions(filters)

    data = frappe.db.sql(
        """
        SELECT
            tooling_code,
            tooling_name,
            tooling_type,
            status,
            current_shot_count,
            max_shot_count,
            CASE
                WHEN max_shot_count > 0
                THEN ROUND(current_shot_count / max_shot_count * 100, 2)
                ELSE 0
            END as utilization
        FROM `tabTooling`
        WHERE 1=1 {conditions}
        ORDER BY utilization DESC
        """.format(
            conditions=conditions
        ),
        as_dict=True,
    )

    return data


def get_conditions(filters):
    """Build SQL conditions from filters"""
    conditions = []

    if filters.get("tooling_type"):
        conditions.append(f"AND tooling_type = '{filters.tooling_type}'")

    if filters.get("status"):
        conditions.append(f"AND status = '{filters.status}'")

    return " ".join(conditions) if conditions else ""
