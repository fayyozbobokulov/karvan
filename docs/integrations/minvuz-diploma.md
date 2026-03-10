# MinVUZ Diploma -- /minvuz/services/diploma/v2

**Category:** education
**Service:** egov_main
**Base URL:** `https://apimgw.egov.uz:8243`

## Overview

This endpoint retrieves higher education diploma information from the Ministry of Higher Education (MinVUZ). It looks up diploma records by the citizen's PINFL. This method has special error handling: a `NOT_FOUND` response triggers a workflow that creates an `integration_found=false` record rather than failing outright.

---

## Methods

### `diploma`

| Field         | Value                         |
| ------------- | ----------------------------- |
| HTTP Method   | POST                          |
| Endpoint      | `/minvuz/services/diploma/v2` |
| Service       | egov_main                     |
| Timeout       | 60000ms                       |
| Requires Auth | Yes                           |

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

#### Custom Error Handling

The `shouldTriggerWorkflow` function returns `true` for `NOT_FOUND` errors. When a diploma is not found, instead of treating it as a failure, the system creates an integration record with `integration_found=false`. This allows downstream workflow logic to distinguish between "no diploma exists" and "the service failed."

---

## Postman Examples

### `diploma`

> Получает информацию о выданных дипломах по ПИНФЛ. Возвращает данные об образовании, специальности, учебном заведении.

```bash
curl -X POST 'https://apimgw.egov.uz:8243/minvuz/services/diploma/v2' \
  -H 'Authorization: Bearer {{access_token}}' \
  -H 'Content-Type: application/json' \
  -d '{
    "pinfl": "52103046570025"
  }'
```

| Postman Variable | Example Value    | Description |
| ---------------- | ---------------- | ----------- |
| `pinfl`          | `52103046570025` | Test PINFL  |

---

## Seed Data Reference

```typescript
{
  methodName: "diploma",
  serviceName: "egov_main",
  httpMethod: "POST",
  endpoint: "/minvuz/services/diploma/v2",
  defaultBody: {
    pinfl: "$pinpp"
  }
}
```
