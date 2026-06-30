import frappe
from frappe import _


def after_insert(doc, method):
    """Handle CRM Lead after insert"""
    create_oem_customer_if_needed(doc)


def create_oem_customer_if_needed(doc):
    """Create OEM Customer if lead is from an OEM"""
    if doc.source and "OEM" in doc.source.upper():
        oem = frappe.get_doc(
            {
                "doctype": "OEM Customer",
                "customer_name": doc.company_name or doc.lead_name,
                "email": doc.email_id,
                "phone": doc.phone,
            }
        )
        oem.insert()
        frappe.msgprint(_("OEM Customer {0} created from lead").format(oem.name))
