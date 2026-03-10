# GNK Self-Employed -- /gnk/service/selfemployed/v1

**Category:** tax
**Service:** egov_gnk
**Base URL:** `https://apimgw.egov.uz:8243`

## Overview

This endpoint checks self-employment registration status via the State Tax Committee (GNK). It uses the citizen's PINFL to look up whether they are registered as self-employed.

---

## Methods

### `self_employed`

| Field         | Value                          |
| ------------- | ------------------------------ |
| HTTP Method   | POST                           |
| Endpoint      | `/gnk/service/selfemployed/v1` |
| Service       | egov_gnk                       |
| Timeout       | 60000ms                        |
| Requires Auth | Yes                            |

#### Request Body

```json
{
  "pinfl": "$pinpp"
}
```

#### Placeholder Variables

| Placeholder | Source                | Description                                  |
| ----------- | --------------------- | -------------------------------------------- |
| `$pinpp`    | search_criteria.pinpp | 14-digit PINFL of the person being looked up |

---

## Postman Examples

### `self_employed`

> Получает информацию о самозанятых лицах по ПИНФЛ. Возвращает данные о регистрации, виде деятельности.

```bash
curl -X POST 'https://apimgw.egov.uz:8243/gnk/service/selfemployed/v1' \
  -H 'Authorization: Bearer {{access_token}}' \
  -H 'Content-Type: application/json' \
  -d '{
    "pinfl": "52103046570025"
  }'
```

| Postman Variable   | Example Value    | Description                                          |
| ------------------ | ---------------- | ---------------------------------------------------- |
| `{{pnfl}}`         | `52103046570025` | Test PINFL (14-digit personal identification number) |
| `{{access_token}}` | _(from OAuth)_   | Bearer token for API authorization                   |

---

## Seed Data Reference

```typescript
{
  methodName: "self_employed",
  serviceName: "egov_gnk",
  httpMethod: "POST",
  endpoint: "/gnk/service/selfemployed/v1",
  defaultBody: {
    pinfl: "$pinpp"
  }
}
```
