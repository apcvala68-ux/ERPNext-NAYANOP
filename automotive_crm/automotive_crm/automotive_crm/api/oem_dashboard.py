import frappe
from frappe import _


@frappe.whitelist()
def get_oem_dashboard(oem_customer: str) -> dict:
    """Get dashboard data for an OEM customer.

    Args:
        oem_customer: Name of the OEM Customer document

    Returns:
        dict with keys: total_deals, open_rfqs, revenue_ytd, forecast_accuracy

    Raises:
        frappe.DoesNotExistError: If OEM customer not found
    """
    if not frappe.db.exists("OEM Customer", oem_customer):
        frappe.throw(_("OEM Customer {0} not found").format(oem_customer))

    return {
        "total_deals": frappe.db.count("CRM Deal", {"oem_customer": oem_customer}),
        "open_rfqs": frappe.db.count(
            "RFQ",
            {"oem_customer": oem_customer, "status": ["in", ["Received", "Analyzing", "Costing"]]},
        ),
        "revenue_ytd": frappe.db.get_value(
            "Quotation",
            {
                "oem_customer": oem_customer,
                "docstatus": 1,
            },
            "sum(grand_total)",
        )
        or 0,
        "forecast_accuracy": calculate_forecast_accuracy(oem_customer),
    }


def calculate_forecast_accuracy(oem_customer: str) -> float:
    """Calculate forecast accuracy for an OEM customer."""
    forecasts = frappe.get_all(
        "Sales Forecast",
        filters={"oem_customer": oem_customer, "docstatus": 1},
        fields=["forecasted_volume", "actual_volume"],
    )

    if not forecasts:
        return 0.0

    total_forecasted = sum(f.forecasted_volume for f in forecasts)
    total_actual = sum(f.actual_volume for f in forecasts)

    if total_forecasted == 0:
        return 0.0

    accuracy = 100 - abs(total_forecasted - total_actual) / total_forecasted * 100
    return round(accuracy, 2)
