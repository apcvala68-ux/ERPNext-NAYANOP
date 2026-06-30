import frappe
from frappe import _


def custom_get_count(doctype, filters=None, debug=False):
    """Custom get_count with better performance for large datasets"""
    if isinstance(filters, str):
        filters = frappe.parse_json(filters)

    count = frappe.db.count(doctype, filters=filters, debug=debug)
    return count
