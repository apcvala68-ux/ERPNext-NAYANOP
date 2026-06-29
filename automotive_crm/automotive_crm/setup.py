import frappe
from frappe import _


def after_install():
    """Setup after app installation"""
    create_custom_fields()
    create_property_setters()
    create_initial_data()


def after_migrate():
    """Setup after migration"""
    create_custom_fields()


def create_custom_fields():
    """Create custom fields for automotive CRM"""
    custom_fields = [
        {
            "dt": "CRM Deal",
            "fieldname": "oem_customer",
            "fieldtype": "Link",
            "label": "OEM Customer",
            "options": "OEM Customer",
            "insert_after": "organization",
        },
        {
            "dt": "CRM Deal",
            "fieldname": "part_category",
            "fieldtype": "Select",
            "label": "Part Category",
            "options": "Metal\nRubber\nPlastic\nElectrical",
            "insert_after": "oem_customer",
        },
        {
            "dt": "CRM Deal",
            "fieldname": "estimated_annual_volume",
            "fieldtype": "Int",
            "label": "Estimated Annual Volume",
            "insert_after": "part_category",
        },
        {
            "dt": "CRM Deal",
            "fieldname": "certification_required",
            "fieldtype": "Check",
            "label": "Certification Required",
            "insert_after": "estimated_annual_volume",
        },
    ]

    for field in custom_fields:
        if not frappe.db.exists("Custom Field", {"dt": field["dt"], "fieldname": field["fieldname"]}):
            frappe.get_doc({"doctype": "Custom Field", **field}).insert()


def create_property_setters():
    """Create property setters for automotive CRM"""
    property_setters = [
        {
            "dt": "CRM Deal",
            "property": "autoname",
            "value": "naming_series:",
            "property_type": "Data",
        },
    ]

    for setter in property_setters:
        if not frappe.db.exists("Property Setter", {"dt": setter["dt"], "property": setter["property"]}):
            frappe.get_doc({"doctype": "Property Setter", **setter}).insert()


def create_initial_data():
    """Create initial data for automotive CRM"""
    pass
