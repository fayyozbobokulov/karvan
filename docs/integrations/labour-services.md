# Labour Services -- /labour/service/

**Category:** employment
**Service:** egov_main
**Base URL:** `https://apimgw.egov.uz:8243`

## Overview

This endpoint group provides employment-related data from the Ministry of Employment and Labour Relations. It includes methods for checking unemployment status and retrieving work history records for citizens.

---

## Methods

### `unemployment`

| Field         | Value                             |
| ------------- | --------------------------------- |
| HTTP Method   | POST                              |
| Endpoint      | `/labour/service/unemployment/v1` |
| Service       | egov_main                         |
| Timeout       | 60000ms                           |
| Requires Auth | Yes                               |

#### Request Body

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "execute",
  "params": {
    "body": {
      "pin": "$pinpp"
    }
  }
}
```

> **Note:** This method uses JSON-RPC 2.0 format, unlike most other integration methods which use plain JSON request bodies.

#### Placeholder Variables

| Placeholder | Source                | Description                                  |
| ----------- | --------------------- | -------------------------------------------- |
| `$pinpp`    | search_criteria.pinpp | 14-digit PINFL of the person being looked up |

---

### `work_history`

| Field         | Value                               |
| ------------- | ----------------------------------- |
| HTTP Method   | POST                                |
| Endpoint      | `/labour/service/citizenhistory/v1` |
| Service       | egov_main                           |
| Timeout       | 60000ms                             |
| Requires Auth | Yes                                 |

#### Request Body

```json
{
  "pin": "$pinpp"
}
```

#### Placeholder Variables

| Placeholder | Source                | Description                                  |
| ----------- | --------------------- | -------------------------------------------- |
| `$pinpp`    | search_criteria.pinpp | 14-digit PINFL of the person being looked up |

---

## Postman Examples

### `unemployment`

> Check unemployment benefits information for a person by PINFL.

```bash
curl -X POST 'https://apimgw.egov.uz:8243/labour/service/unemployment/v1' \
  -H 'Authorization: Bearer {{access_token}}' \
  -H 'Content-Type: application/json' \
  -d '{
    "jsonrpc": "2.0",
    "id": 123456,
    "method": "abkm.currently.unemployed",
    "params": {
      "body": {
        "pin": "42507873930044"
      }
    }
  }'
```

| Postman Variable | Example Value    | Description |
| ---------------- | ---------------- | ----------- |
| `pin`            | `42507873930044` | Test PINFL  |

### `work_history`

> Получает информацию о трудовой истории по ПИНФЛ.

```bash
curl -X POST 'https://apimgw.egov.uz:8243/labour/service/citizenhistory/v1' \
  -H 'Authorization: Bearer {{access_token}}' \
  -H 'Content-Type: application/json' \
  -d '{
    "pin": "60308027020015"
  }'
```

| Postman Variable | Example Value    | Description |
| ---------------- | ---------------- | ----------- |
| `pin`            | `60308027020015` | Test PINFL  |

---

## Seed Data Reference

```typescript
// unemployment
{
  methodName: "unemployment",
  serviceName: "egov_main",
  httpMethod: "POST",
  endpoint: "/labour/service/unemployment/v1",
  defaultBody: {
    jsonrpc: "2.0",
    id: 1,
    method: "execute",
    params: {
      body: {
        pin: "$pinpp"
      }
    }
  }
}

// work_history
{
  methodName: "work_history",
  serviceName: "egov_main",
  httpMethod: "POST",
  endpoint: "/labour/service/citizenhistory/v1",
  defaultBody: {
    pin: "$pinpp"
  }
}
```
