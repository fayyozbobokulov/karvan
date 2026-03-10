# SSV Medkarta Service — `/ssv/medkarta/v1/ServiceRequest`

**Category:** medical
**Service:** egov_minzdrav
**Base URL:** `https://apimgw.egov.uz:8243`

## Overview

Medical card (medkarta) service request endpoint provided via the SSV (Social Security) gateway. This method retrieves medical card information for a patient, requiring sender authentication and patient consent.

---

## Methods

### `medkarta_service`

| Field         | Value                             |
| ------------- | --------------------------------- |
| HTTP Method   | GET                               |
| Endpoint      | `/ssv/medkarta/v1/ServiceRequest` |
| Service       | egov_minzdrav                     |
| Timeout       | 60000ms                           |
| Requires Auth | Yes                               |

#### Query Params

```json
{
  "request_id": 1,
  "sender_pin": "$sender_pinpp",
  "consent": "Y",
  "purpose": "Checking background",
  "patient_nnuzb": "$pinpp"
}
```

#### Placeholder Variables

| Placeholder     | Source       | Description                                      |
| --------------- | ------------ | ------------------------------------------------ |
| `$sender_pinpp` | Flow context | PINFL of the requesting sender (authorized user) |
| `$pinpp`        | Flow context | Patient's PINFL (personal identification number) |

---

## Postman Examples

### `medkarta_service`

> Получает информацию о медицинских услугах (диагностические тесты, процедуры, операции, направления) по ПИНФЛ.

```bash
curl -X GET 'https://apimgw.egov.uz:8243/ssv/medkarta/v1/ServiceRequest?request_id=18d8055c-ca2b-11ed-aed9-1b35d747be9b&sender_pin={{sender_pinpp}}&consent=true&purpose=test&patient_nnuzb=40908952410026' \
  -H 'Authorization: Bearer {{access_token}}'
```

| Postman Variable   | Example Value                          | Description                      |
| ------------------ | -------------------------------------- | -------------------------------- |
| `{{access_token}}` | —                                      | OAuth2 Bearer token              |
| `{{sender_pinpp}}` | —                                      | Sender's PINFL (authorized user) |
| `request_id`       | `18d8055c-ca2b-11ed-aed9-1b35d747be9b` | Unique request identifier        |
| `patient_nnuzb`    | `40908952410026`                       | Patient PINFL                    |

---

## Seed Data Reference

```typescript
{
  methodName: "medkarta_service",
  serviceName: "egov_minzdrav",
  httpMethod: "GET",
  endpoint: "/ssv/medkarta/v1/ServiceRequest",
  defaultBody: {
    request_id: 1,
    sender_pin: "$sender_pinpp",
    consent: "Y",
    purpose: "Checking background",
    patient_nnuzb: "$pinpp"
  }
}
```
