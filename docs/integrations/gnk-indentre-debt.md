# GNK Entrepreneur Debt -- /gnk/service/indentre/debt/v1

**Category:** tax
**Service:** egov_gnk
**Base URL:** `https://apimgw.egov.uz:8243`

## Overview

This endpoint retrieves tax debt information for individual entrepreneurs (indentrepreneur) from the State Tax Committee (GNK). The TIN is passed directly via request params rather than being auto-mapped from a `$placeholder` variable.

---

## Methods

### `entrepreneur_debt`

| Field         | Value                           |
| ------------- | ------------------------------- |
| HTTP Method   | POST                            |
| Endpoint      | `/gnk/service/indentre/debt/v1` |
| Service       | egov_gnk                        |
| Timeout       | 60000ms                         |
| Requires Auth | Yes                             |

#### Request Body

```json
{
  "tin": null
}
```

#### Placeholder Variables

| Placeholder | Source           | Description                                                                                       |
| ----------- | ---------------- | ------------------------------------------------------------------------------------------------- |
| _(none)_    | _(direct param)_ | TIN is not auto-mapped from a `$placeholder`; it is passed directly via request params at runtime |

> **Note:** Unlike most integration methods, the `tin` field is not mapped from a `$placeholder` variable. The value must be supplied directly through the request parameters when invoking this method.

---

## Postman Examples

### `entrepreneur_debt`

> Получает информацию о задолженности индивидуальных предпринимателей (ИП) по ИНН. Возвращает данные о налоговых задолженностях.

```bash
curl -X POST 'https://apimgw.egov.uz:8243/gnk/service/indentre/debt/v1' \
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
  methodName: "entrepreneur_debt",
  serviceName: "egov_gnk",
  httpMethod: "POST",
  endpoint: "/gnk/service/indentre/debt/v1",
  defaultBody: {
    tin: null
  }
}
```
