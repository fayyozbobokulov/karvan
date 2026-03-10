# Minzdrav VTEK (Disability Commission) — `/minzdrav/vtek/v4/`

**Category:** medical
**Service:** egov_minzdrav
**Base URL:** `https://apimgw.egov.uz:8243`

## Overview

VTEK (Medical-Labor Expert Commission) endpoints provided by the Ministry of Health (Minzdrav). These methods check an individual's disability status through the VTEK system. Lookup can be performed by passport or birth document.

---

## Methods

### `vtek_by_passport`

| Field         | Value                        |
| ------------- | ---------------------------- |
| HTTP Method   | POST                         |
| Endpoint      | `/minzdrav/vtek/v4/passport` |
| Service       | egov_minzdrav                |
| Timeout       | 60000ms                      |
| Requires Auth | Yes                          |

#### Request Body

```json
{
  "transaction_id": 1,
  "pin": "$pinpp",
  "purpose": "Checking background",
  "consent": "Y",
  "pinfl": "$pinpp",
  "passport": "$passport_series$passport_number"
}
```

#### Placeholder Variables

| Placeholder        | Source       | Description                                         |
| ------------------ | ------------ | --------------------------------------------------- |
| `$pinpp`           | Flow context | Individual's PINFL (personal identification number) |
| `$passport_series` | Flow context | Passport series (e.g., "AA")                        |
| `$passport_number` | Flow context | Passport number (e.g., "1234567")                   |

---

### `vtek_by_birth_doc`

| Field         | Value                        |
| ------------- | ---------------------------- |
| HTTP Method   | POST                         |
| Endpoint      | `/minzdrav/vtek/v4/birthdoc` |
| Service       | egov_minzdrav                |
| Timeout       | 60000ms                      |
| Requires Auth | Yes                          |

#### Request Body

```json
{
  "transaction_id": 1,
  "pin": "$pinpp",
  "purpose": "Checking background",
  "consent": "Y",
  "birth_document": "$passport_series$passport_number",
  "birth_date": "$birth_date"
}
```

#### Placeholder Variables

| Placeholder        | Source       | Description                                         |
| ------------------ | ------------ | --------------------------------------------------- |
| `$pinpp`           | Flow context | Individual's PINFL (personal identification number) |
| `$passport_series` | Flow context | Birth document series                               |
| `$passport_number` | Flow context | Birth document number                               |
| `$birth_date`      | Flow context | Date of birth                                       |

---

## Postman Examples

### `vtek_by_passport`

> Получает сведения об учёте во ВТЭК по паспорту. Возвращает информацию о инвалидности, группе инвалидности.

```bash
curl -X POST 'https://apimgw.egov.uz:8243/minzdrav/vtek/v4/passport' \
  -H 'Authorization: Bearer {{access_token}}' \
  -H 'Content-Type: application/json' \
  -d '{ "transaction_id": "1", "pin": "{{pnfl}}", "purpose": "test", "consent": "true", "pinfl": "30211996490017", "passport": "AB3548007" }'
```

| Postman Variable   | Example Value    | Description              |
| ------------------ | ---------------- | ------------------------ |
| `{{access_token}}` | —                | OAuth2 Bearer token      |
| `{{pnfl}}`         | `30211996490017` | Test PINFL               |
| `passport`         | `AB3548007`      | Passport series + number |

### `vtek_by_birth_doc`

> Получает сведения об учёте во ВТЭК по свидетельству о рождении и дате рождения.

```bash
curl -X POST 'https://apimgw.egov.uz:8243/minzdrav/vtek/v4/birthdoc' \
  -H 'Authorization: Bearer {{access_token}}' \
  -H 'Content-Type: application/json' \
  -d '{ "transaction_id": "1234", "pin": "{{pnfl}}", "purpose": "", "consent": "true", "birth_document": "I-TN-1234567", "birth_date": "2021-03-25" }'
```

| Postman Variable   | Example Value  | Description                       |
| ------------------ | -------------- | --------------------------------- |
| `{{access_token}}` | —              | OAuth2 Bearer token               |
| `{{pnfl}}`         | —              | Test PINFL                        |
| `birth_document`   | `I-TN-1234567` | Birth certificate (series-number) |
| `birth_date`       | `2021-03-25`   | Date of birth                     |

---

## Seed Data Reference

```typescript
{
  methodName: "vtek_by_passport",
  serviceName: "egov_minzdrav",
  httpMethod: "POST",
  endpoint: "/minzdrav/vtek/v4/passport",
  defaultBody: {
    transaction_id: 1,
    pin: "$pinpp",
    purpose: "Checking background",
    consent: "Y",
    pinfl: "$pinpp",
    passport: "$passport_series$passport_number"
  }
}
```

```typescript
{
  methodName: "vtek_by_birth_doc",
  serviceName: "egov_minzdrav",
  httpMethod: "POST",
  endpoint: "/minzdrav/vtek/v4/birthdoc",
  defaultBody: {
    transaction_id: 1,
    pin: "$pinpp",
    purpose: "Checking background",
    consent: "Y",
    birth_document: "$passport_series$passport_number",
    birth_date: "$birth_date"
  }
}
```
