import frappe
from frappe import _


def on_update(doc, method):
    """Handle CRM Deal on update"""
    if doc.status == "Won":
        create_quotation_from_deal(doc)


def on_change(doc, method):
    """Handle CRM Deal on change"""
    if doc.has_value_changed("status"):
        update_deal_stage(doc)


def create_quotation_from_deal(doc):
    """Create quotation from won deal"""
    quotation = frappe.get_doc(
        {
            "doctype": "Quotation",
            "oem_customer": doc.oem_customer,
            "party_name": doc.organization,
            "quotation_to": "Customer",
            "items": [
                {
                    "item_code": item.item_code,
                    "qty": item.qty,
                    "rate": item.rate,
                }
                for item in doc.items
            ]
            if doc.items
            else [],
        }
    )
    quotation.insert()
    frappe.msgprint(_("Quotation {0} created from deal").format(quotation.name))


def update_deal_stage(doc):
    """Update deal stage"""
    frappe.get_doc(
        {
            "doctype": "Activity Type",
            "activity_type": f"Deal Stage: {doc.status}",
        }
    ).insert(ignore_if_duplicate=True)
