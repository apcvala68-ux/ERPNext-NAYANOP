frappe.listview_settings["OEM Customer"] = {
    get_indicator: function (doc) {
        if (doc.certification && doc.certification_expiry) {
            let expiry = frappe.datetime.str_to_obj(doc.certification_expiry);
            let today = frappe.datetime.str_to_obj(frappe.datetime.get_today());
            let days_diff = frappe.datetime.get_diff(
                frappe.datetime.obj_to_str(expiry),
                frappe.datetime.get_today()
            );

            if (days_diff < 0) {
                return [__("Expired"), "red", "certification_expiry,=," + doc.certification_expiry];
            } else if (days_diff < 30) {
                return [__("Expiring Soon"), "orange", "certification_expiry,=," + doc.certification_expiry];
            }
        }
        return [doc.tier, "green", "tier,=," + doc.tier];
    },
};
