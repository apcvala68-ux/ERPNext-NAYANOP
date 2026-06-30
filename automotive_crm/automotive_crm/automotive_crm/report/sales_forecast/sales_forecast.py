import frappe
from frappe import _


def execute(filters=None):
    """Sales Forecast Report"""
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
            "fieldname": "part_master",
            "fieldtype": "Link",
            "label": _("Part Master"),
            "options": "Part Master",
            "width": 150,
        },
        {
            "fieldname": "forecast_month",
            "fieldtype": "Data",
            "label": _("Month"),
            "width": 100,
        },
        {
            "fieldname": "forecast_year",
            "fieldtype": "Int",
            "label": _("Year"),
            "width": 60,
        },
        {
            "fieldname": "forecasted_volume",
            "fieldtype": "Int",
            "label": _("Forecasted"),
            "width": 100,
        },
        {
            "fieldname": "actual_volume",
            "fieldtype": "Int",
            "label": _("Actual"),
            "width": 100,
        },
        {
            "fieldname": "accuracy",
            "fieldtype": "Percent",
            "label": _("Accuracy"),
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
            part_master,
            forecast_month,
            forecast_year,
            forecasted_volume,
            actual_volume,
            accuracy
        FROM `tabSales Forecast`
        WHERE docstatus = 1 {conditions}
        ORDER BY oem_customer, forecast_year, forecast_month
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

    if filters.get("forecast_year"):
        conditions.append(f"AND forecast_year = {filters.forecast_year}")

    return " ".join(conditions) if conditions else ""
