import frappe
from frappe import _


def daily():
    """Daily scheduled tasks"""
    check_pending_rfqs()
    update_forecast_accuracy()


def weekly():
    """Weekly scheduled tasks"""
    generate_oem_reports()
    check_tooling_utilization()


def monthly():
    """Monthly scheduled tasks"""
    generate_monthly_forecast()
    cleanup_old_activities()


def check_pending_rfqs():
    """Check for pending RFQs and send reminders"""
    pending_rfqs = frappe.get_all(
        "RFQ",
        filters={"status": ["in", ["Received", "Analyzing"]], "expected_date": ["<", frappe.utils.nowdate()]},
        fields=["name", "oem_customer", "expected_date"],
    )

    for rfq in pending_rfqs:
        frappe.sendmail(
            recipients=[frappe.db.get_value("Sales User", {"user": frappe.session.user}, "email")],
            subject=_("Pending RFQ: {0}").format(rfq.name),
            message=_("RFQ {0} for {1} is pending since {2}").format(
                rfq.name, rfq.oem_customer, rfq.expected_date
            ),
        )


def update_forecast_accuracy():
    """Update forecast accuracy for all OEM customers"""
    oem_customers = frappe.get_all("OEM Customer", fields=["name"])

    for oem in oem_customers:
        accuracy = calculate_forecast_accuracy(oem.name)
        frappe.db.set_value("OEM Customer", oem.name, "forecast_accuracy", accuracy, update_modified=False)


def generate_oem_reports():
    """Generate weekly OEM reports"""
    pass


def check_tooling_utilization():
    """Check tooling utilization rates"""
    pass


def generate_monthly_forecast():
    """Generate monthly sales forecast"""
    pass


def cleanup_old_activities():
    """Cleanup old activities older than 90 days"""
    cutoff_date = frappe.utils.add_days(frappe.utils.nowdate(), -90)
    frappe.db.delete("Activity Log", {"creation": ["<", cutoff_date]})


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
