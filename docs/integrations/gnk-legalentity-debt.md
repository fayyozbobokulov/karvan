# GNK Legal Entity Debt -- /gnk/service/legalentity/debt/v1

**Category:** tax
**Service:** egov_gnk
**Base URL:** `https://apimgw.egov.uz:8243`

## Overview

This endpoint retrieves tax debt information for legal entities from the State Tax Committee (GNK). It accepts a TIN (Taxpayer Identification Number) to look up outstanding debt records.

---

## Methods

### `legal_entity_debt`

| Field         | Value                              |
| ------------- | ---------------------------------- |
| HTTP Method   | POST                               |
| Endpoint      | `/gnk/service/legalentity/debt/v1` |
| Service       | egov_gnk                           |
| Timeout       | 60000ms                            |
| Requires Auth | Yes                                |

#### Request Body

```json
{
  "tin": null
}
```

#### Placeholder Variables

| Placeholder | Source           | Description                         |
| ----------- | ---------------- | ----------------------------------- |
| _(none)_    | _(direct param)_ | TIN is provided directly at runtime |

---

## Postman Examples

### `legal_entity_debt`

> Получает информацию о задолженности юридических лиц по ИНН. Возвращает данные о налоговых задолженностях.

```bash
curl -X POST 'https://apimgw.egov.uz:8243/gnk/service/legalentity/debt/v1' \
  -H 'Authorization: Bearer {{access_token}}' \
  -H 'Content-Type: application/json' \
  -d '{
    "tin": "{{tin}}"
  }'
```

| Postman Variable   | Example Value  | Description                          |
| ------------------ | -------------- | ------------------------------------ |
| `{{tin}}`          | `201122919`    | Taxpayer Identification Number (INN) |
| `{{access_token}}` | _(from OAuth)_ | Bearer token for API authorization   |

---

## Seed Data Reference

```typescript
{
  methodName: "legal_entity_debt",
  serviceName: "egov_gnk",
  httpMethod: "POST",
  endpoint: "/gnk/service/legalentity/debt/v1",
  defaultBody: {
    tin: null
  }
}
```
