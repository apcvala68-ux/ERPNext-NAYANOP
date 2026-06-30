from frappe import _

app_name = "automotive_crm"
app_title = "Automotive CRM"
app_publisher = "Your Organization"
app_description = "Enterprise-grade CRM for automotive parts manufacturers"
app_email = "admin@yourorg.com"
app_license = "proprietary"

# Including assets
app_include_css = "/assets/automotive_crm/css/automotive_crm.css"
app_include_js = "/assets/automotive_crm/js/automotive_crm.js"

# DocType Events
doc_events = {
    "CRM Deal": {
        "on_update": "automotive_crm.automotive_crm.api.deal_events.on_update",
        "on_change": "automotive_crm.automotive_crm.api.deal_events.on_change",
    },
    "CRM Lead": {
        "after_insert": "automotive_crm.automotive_crm.api.lead_events.after_insert",
    },
}

# Scheduled Tasks
scheduler_events = {
    "daily": [
        "automotive_crm.automotive_crm.tasks.daily",
    ],
    "weekly": [
        "automotive_crm.automotive_crm.tasks.weekly",
    ],
    "monthly": [
        "automotive_crm.automotive_crm.tasks.monthly",
    ],
}

# Website Route Rules
website_route_rules = [
    {
        "from_route": "/oem-dashboard/<path:oem_customer>",
        "to_route": "oem-dashboard",
        "defaults": {"doctype": "OEM Customer"},
    },
]

# Installation
after_install = "automotive_crm.automotive_crm.setup.after_install"
after_migrate = "automotive_crm.automotive_crm.setup.after_migrate"

# Override whitelisted methods
override_whitelisted_methods = {
    "frappe.client.get_count": "automotive_crm.automotive_crm.api.custom_methods.custom_get_count",
}

# Fixtures for Custom Fields
fixtures = [
    {
        "dt": "Custom Field",
        "filters": [["module", "=", "Automotive CRM"]],
    },
    {
        "dt": "Property Setter",
        "filters": [["module", "=", "Automotive CRM"]],
    },
]

# Jinja methods
jinja = {
    "methods": [
        "automotive_crm.automotive_crm.utils.jinja_methods",
    ],
}

# App theme
app_theme = "blue"

# User permission
user_permission = {
    "OEM Customer": {
        "role": ["Sales Manager", "Sales User"],
        "applicable_for": "Company",
    },
}

# Has Whitelisted Methods
has_whitelisted_methods = True

# Override DocType class
override_doctype_class = {
    "Quotation": "automotive_crm.automotive_crm.overrides.quotation.Quotation",
}

# Desktop
desktop = {
    "module_name": "Automotive CRM",
    "color": "#0089FF",
    "icon": "octicon octicon-package",
    "type": "module",
    "label": "Automotive CRM",
}

# Testing
test_suite = "automotive_crm.automotive_crm.tests"
