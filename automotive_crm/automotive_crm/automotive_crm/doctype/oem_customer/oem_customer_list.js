import frappe

from frappe import _


def get_list_data():
    """Get list data for OEM Customer"""
    return {
        "fields": [
            "name",
            "oem_code",
            "customer_name",
            "tier",
            "country",
            "certification",
            "email",
        ],
        "filters": {},
        "order_by": "modification desc",
    }
