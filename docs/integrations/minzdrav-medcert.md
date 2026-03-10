# Minzdrav Medical Certificate — `/minzdrav/medicalcertificate/v1`

**Category:** medical
**Service:** egov_minzdrav
**Base URL:** `https://apimgw.egov.uz:8243`

## Overview

Medical certificate retrieval endpoint provided by the Ministry of Health (Minzdrav). This method fetches medical certificate data (type 083) for an individual identified by their PINFL.

---

## Methods

### `medical_certificate`

| Field         | Value                             |
| ------------- | --------------------------------- |
| HTTP Method   | GET                               |
| Endpoint      | `/minzdrav/medicalcertificate/v1` |
| Service       | egov_minzdrav                     |
| Timeout       | 60000ms                           |
| Requires Auth | Yes                               |

#### Query Params

```json
{
  "type": "083",
  "subject_nnuzb": "$pinpp"
}
```

#### Placeholder Variables

| Placeholder | Source       | Description                                         |
| ----------- | ------------ | --------------------------------------------------- |
| `$pinpp`    | Flow context | Individual's PINFL (personal identification number) |

---

## Postman Examples

### `medical_certificate`

> Получает медицинские справки (в том числе форму 083 - справка для водителей) по ПИНФЛ. Тип справки указывается в параметре type.

```bash
curl -X GET 'https://apimgw.egov.uz:8243/minzdrav/medicalcertificate/v1?type=53245-7&subject-nnuzb=40908952410026' \
  -H 'Authorization: Bearer {{access_token}}'
```

| Postman Variable   | Example Value    | Description           |
| ------------------ | ---------------- | --------------------- |
| `{{access_token}}` | —                | OAuth2 Bearer token   |
| `type`             | `53245-7`        | Certificate type code |
| `subject-nnuzb`    | `40908952410026` | Patient PINFL         |

---

## Seed Data Reference

```typescript
{
  methodName: "medical_certificate",
  serviceName: "egov_minzdrav",
  httpMethod: "GET",
  endpoint: "/minzdrav/medicalcertificate/v1",
  defaultBody: { type: "083", subject_nnuzb: "$pinpp" }
}
```
