# IHMA Poverty Registry -- /ihma/get-reestr-family/v1

**Category:** social
**Service:** egov_main
**Base URL:** `https://apimgw.egov.uz:8243`

## Overview

This endpoint retrieves poverty registry (iron daftar) data from IHMA (Ijtimoiy Himoya Markazi Agentligi -- Social Protection Agency). It checks whether a citizen and their family are registered in the national poverty registry based on their PINFL.

---

## Methods

### `poverty_registry`

| Field         | Value                        |
| ------------- | ---------------------------- |
| HTTP Method   | POST                         |
| Endpoint      | `/ihma/get-reestr-family/v1` |
| Service       | egov_main                    |
| Timeout       | 60000ms                      |
| Requires Auth | Yes                          |

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

### `poverty_registry`

> Check if person is registered in poverty registry. Returns family information.

```bash
curl -X POST 'https://apimgw.egov.uz:8243/ihma/get-reestr-family/v1' \
  -H 'Authorization: Bearer {{access_token}}' \
  -H 'Content-Type: application/json' \
  -d '{
    "pinfl": "31212577120016"
  }'
```

| Postman Variable | Example Value    | Description |
| ---------------- | ---------------- | ----------- |
| `pinfl`          | `31212577120016` | Test PINFL  |

---

## Seed Data Reference

```typescript
{
  methodName: "poverty_registry",
  serviceName: "egov_main",
  httpMethod: "POST",
  endpoint: "/ihma/get-reestr-family/v1",
  defaultBody: {
    pinfl: "$pinpp"
  }
}
```
