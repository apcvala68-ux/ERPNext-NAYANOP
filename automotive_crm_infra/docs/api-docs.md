# API Documentation

## Overview

This document describes the custom API endpoints for the Automotive CRM application.

## Base URL

```
https://yourdomain.com/api/method/automotive_crm.api
```

## Authentication

All API calls require authentication. Use one of the following methods:

### API Key Authentication

```bash
curl -X GET "https://yourdomain.com/api/method/automotive_crm.api.get_oem_dashboard" \
  -H "Authorization: token api_key:api_secret"
```

### Session Authentication

```bash
curl -X POST "https://yourdomain.com/api/method/login" \
  -d "usr=username&pwd=password"

curl -X GET "https://yourdomain.com/api/method/automotive_crm.api.get_oem_dashboard" \
  -b cookies.txt
```

## API Endpoints

### OEM Dashboard

#### Get OEM Dashboard Data

```http
GET /api/method/automotive_crm.api.oem_dashboard.get_oem_dashboard
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `oem_customer` | string | Yes | OEM Customer name |

**Response:**

```json
{
  "message": {
    "total_deals": 15,
    "open_rfqs": 3,
    "revenue_ytd": 1250000,
    "forecast_accuracy": 87.5
  }
}
```

**Example:**

```bash
curl -X GET "https://yourdomain.com/api/method/automotive_crm.api.oem_dashboard.get_oem_dashboard?oem_customer=OEM-001" \
  -H "Authorization: token api_key:api_secret"
```

---

### RFQ Management

#### Get RFQ Summary

```http
GET /api/method/automotive_crm.api.rfq.get_rfq_summary
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `rfq_name` | string | Yes | RFQ name |

**Response:**

```json
{
  "message": {
    "name": "RFQ-001",
    "oem_customer": "OEM-001",
    "status": "Received",
    "items": [
      {
        "part_number": "BRK-001",
        "quantity": 1000,
        "estimated_cost": 85000
      }
    ],
    "total_estimated": 85000
  }
}
```

---

### Cost Sheet

#### Calculate Cost Sheet

```http
POST /api/method/automotive_crm.api.cost_sheet.calculate_cost_sheet
```

**Request Body:**

```json
{
  "rfq": "RFQ-001",
  "items": [
    {
      "part_master": "BRK-001",
      "quantity": 1000,
      "material_cost": 50000,
      "labor_cost": 20000,
      "overhead_cost": 10000,
      "tooling_cost": 5000,
      "quality_cost": 2000
    }
  ]
}
```

**Response:**

```json
{
  "message": {
    "name": "COST-001",
    "total_cost": 87000,
    "cost_per_unit": 87,
    "margin_suggested": 15,
    "price_suggested": 100.05
  }
}
```

---

### Quotation

#### Create Quotation

```http
POST /api/method/automotive_crm.api.quotation.create_quotation
```

**Request Body:**

```json
{
  "rfq": "RFQ-001",
  "oem_customer": "OEM-001",
  "items": [
    {
      "part_master": "BRK-001",
      "quantity": 1000,
      "unit_price": 95,
      "total": 95000
    }
  ],
  "currency": "INR",
  "payment_terms": "30 days",
  "delivery_terms": "FOB Mumbai"
}
```

**Response:**

```json
{
  "message": {
    "name": "QUO-001",
    "grand_total": 95000,
    "status": "Draft",
    "valid_until": "2026-07-29"
  }
}
```

---

### Quality Complaint

#### Create 8D Report

```http
POST /api/method/automotive_crm.api.quality.create_8d_report
```

**Request Body:**

```json
{
  "complaint": "QC-001",
  "team": [
    {"member": "user1@yourorg.com", "role": "Team Lead"},
    {"member": "user2@yourorg.com", "role": "Engineer"}
  ],
  "root_cause": "Material defect in raw material",
  "corrective_actions": [
    {
      "action": "Implement incoming material inspection",
      "responsible": "user1@yourorg.com",
      "due_date": "2026-07-15"
    }
  ],
  "preventive_actions": [
    {
      "action": "Update supplier quality requirements",
      "responsible": "user2@yourorg.com",
      "due_date": "2026-07-30"
    }
  ]
}
```

**Response:**

```json
{
  "message": {
    "name": "8D-001",
    "status": "In Progress",
    "completion_date": null,
    "effectiveness_score": null
  }
}
```

---

### Sales Forecast

#### Update Forecast

```http
POST /api/method/automotive_crm.api.forecast.update_forecast
```

**Request Body:**

```json
{
  "oem_customer": "OEM-001",
  "part_master": "BRK-001",
  "forecast_month": "2026-07",
  "forecasted_volume": 5000,
  "confidence_level": "High",
  "notes": "Based on historical data and OEM forecast"
}
```

**Response:**

```json
{
  "message": {
    "name": "SF-001",
    "accuracy": 92.5,
    "trend": "increasing"
  }
}
```

---

## Error Handling

### Error Response Format

```json
{
  "exc_type": "ValidationError",
  "exc_message": ["OEM Customer OEM-999 does not exist"],
  "exc": ["Traceback..."]
}
```

### Common Error Codes

| HTTP Status | Error Type | Description |
|-------------|------------|-------------|
| 400 | ValidationError | Invalid input data |
| 401 | AuthenticationError | Invalid or missing credentials |
| 403 | PermissionError | Insufficient permissions |
| 404 | DoesNotExistError | Resource not found |
| 500 | ServerError | Internal server error |

### Error Handling Example

```bash
curl -X GET "https://yourdomain.com/api/method/automotive_crm.api.oem_dashboard.get_oem_dashboard?oem_customer=OEM-999" \
  -H "Authorization: token api_key:api_secret"
```

**Response:**

```json
{
  "exc_type": "DoesNotExistError",
  "exc_message": ["OEM Customer OEM-999 does not exist"]
}
```

---

## Rate Limiting

API requests are rate limited to:

- **Authenticated users:** 100 requests per minute
- **API keys:** 60 requests per minute
- **Unauthenticated:** 10 requests per minute

Rate limit headers are included in responses:

```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1624987200
```

---

## Pagination

List endpoints support pagination:

```http
GET /api/method/frappe.client.get_list?doctype=OEM Customer&limit_page_length=20&start=0
```

**Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `limit_page_length` | int | 20 | Items per page |
| `start` | int | 0 | Offset |
| `order_by` | string | creation desc | Sort order |

---

## Filtering

Use Frappe's filter syntax:

```http
GET /api/method/frappe.client.get_list?doctype=RFQ&filters=[["status","=","Received"]]
```

### Filter Operators

| Operator | Description | Example |
|----------|-------------|---------|
| `=` | Equals | `["status","=","Received"]` |
| `!=` | Not equals | `["status","!=","Won"]` |
| `>` | Greater than | `["amount",">",10000]` |
| `<` | Less than | `["amount","<",10000]` |
| `like` | Contains | `["name","like","%BRK%"]` |
| `in` | In list | `["status","in",["Received","Analyzing"]]` |

---

## Webhooks

### Setting Up Webhooks

```bash
curl -X POST "https://yourdomain.com/api/method/frappe.client.insert" \
  -H "Authorization: token api_key:api_secret" \
  -d '{
    "doctype": "Webhook",
    "webhook_name": "RFQ Received",
    "webhook_doctype": "RFQ",
    "webhook_docevent": "on_insert",
    "webhook_url": "https://your-webhook-endpoint.com/rfq-received",
    "webhook_headers": [
      {"key": "Content-Type", "value": "application/json"}
    ]
  }'
```

### Webhook Payload Example

```json
{
  "event": "on_insert",
  "doctype": "RFQ",
  "doc": {
    "name": "RFQ-001",
    "oem_customer": "OEM-001",
    "status": "Received",
    "items": [...]
  },
  "timestamp": "2026-06-29T10:30:00Z"
}
```

---

## SDK Examples

### Python

```python
import requests

# Configuration
BASE_URL = "https://yourdomain.com/api/method"
API_KEY = "your_api_key"
API_SECRET = "your_api_secret"

# Get OEM Dashboard
response = requests.get(
    f"{BASE_URL}/automotive_crm.api.oem_dashboard.get_oem_dashboard",
    params={"oem_customer": "OEM-001"},
    auth=(API_KEY, API_SECRET)
)
print(response.json())
```

### JavaScript

```javascript
// Configuration
const BASE_URL = "https://yourdomain.com/api/method";
const API_KEY = "your_api_key";
const API_SECRET = "your_api_secret";

// Get OEM Dashboard
fetch(`${BASE_URL}/automotive_crm.api.oem_dashboard.get_oem_dashboard?oem_customer=OEM-001`, {
  headers: {
    "Authorization": `token ${API_KEY}:${API_SECRET}`
  }
})
.then(response => response.json())
.then(data => console.log(data));
```

### cURL

```bash
# Get OEM Dashboard
curl -X GET "https://yourdomain.com/api/method/automotive_crm.api.oem_dashboard.get_oem_dashboard?oem_customer=OEM-001" \
  -H "Authorization: token api_key:api_secret"

# Create RFQ
curl -X POST "https://yourdomain.com/api/method/automotive_crm.api.rfq.create_rfq" \
  -H "Authorization: token api_key:api_secret" \
  -H "Content-Type: application/json" \
  -d '{
    "oem_customer": "OEM-001",
    "items": [
      {
        "part_number": "BRK-001",
        "quantity": 1000,
        "required_date": "2026-12-31"
      }
    ]
  }'
```

---

## Versioning

API versioning is handled through URL path:

```
/api/v1/method/automotive_crm.api.get_oem_dashboard
```

Current version: **v1**

---

## Changelog

### v1.0.0 (2026-06-29)

- Initial API release
- OEM Dashboard endpoints
- RFQ management endpoints
- Cost sheet endpoints
- Quotation endpoints
- Quality complaint endpoints
- Sales forecast endpoints
