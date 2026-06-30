import frappe
from frappe import _


def custom_get_count(doctype, filters=None, limit_page_length=0, debug=False):
    """Custom get_count with better performance for large datasets"""
    if isinstance(filters, str):
        filters = frappe.parse_json(filters)

    count = frappe.db.count(doctype, filters=filters, debug=debug)
    return count


def oem_customer_permission(doc, user=None, permission_type=None):
    """Allow Sales Manager and Sales User to access OEM Customer"""
    if user is None:
        user = frappe.session.user
    roles = frappe.get_roles(user)
    if "Sales Manager" in roles or "Sales User" in roles:
        return True
    return False
