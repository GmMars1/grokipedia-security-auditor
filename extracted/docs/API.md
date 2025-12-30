# GrokiPedia Security Auditor - API Documentation

## REST API Endpoints

### Run Audit
```http
POST /api/audit
Content-Type: application/json

{
  "url": "https://example.com",
  "depth": "comprehensive",
  "callback": "https://your-webhook.com"
}
```

### Get Audit Results
```http
GET /api/audit/{audit_id}
Authorization: Bearer {api_key}
```

## Webhooks

### Audit Completion
```json
{
  "event": "audit.completed",
  "audit_id": "audit_123",
  "url": "https://example.com",
  "status": "completed",
  "score": 85,
  "report_url": "https://auditor.com/reports/audit_123"
}
```

## SDKs

### Python
```python
import grokipedia_auditor

client = grokipedia_auditor.Client(api_key="your_api_key")
audit = client.audit("https://example.com")
```
