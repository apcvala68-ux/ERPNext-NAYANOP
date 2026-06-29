import frappe
from frappe import _


def jinja_methods():
    """Jinja methods for templates"""
    return {
        "get_oem_name": get_oem_name,
        "format_currency_inr": format_currency_inr,
    }


def get_oem_name(oem_customer: str) -> str:
    """Get OEM customer name"""
    return frappe.db.get_value("OEM Customer", oem_customer, "customer_name") or oem_customer


def format_currency_inr(amount: float) -> str:
    """Format currency in INR"""
    return frappe.utils.fmt_money(amount, currency="INR")
