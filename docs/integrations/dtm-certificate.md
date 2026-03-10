# DTM Certificate -- /dtm/service/certificate/v1

**Category:** education
**Service:** egov_main
**Base URL:** `https://apimgw.egov.uz:8243`

## Overview

This endpoint retrieves GCT (General Competence Test) certificate data from the DTM (Davlat Test Markazi -- State Testing Center). Unlike most integration methods, this uses a GET request with query parameters rather than a POST request with a JSON body.

---

## Methods

### `gct_certificate`

| Field         | Value                         |
| ------------- | ----------------------------- |
| HTTP Method   | GET                           |
| Endpoint      | `/dtm/service/certificate/v1` |
| Service       | egov_main                     |
| Timeout       | 60000ms                       |
| Requires Auth | Yes                           |

#### Query Parameters

```json
{
  "PNFL": "$pinpp"
}
```

#### Placeholder Variables

| Placeholder | Source                | Description                                  |
| ----------- | --------------------- | -------------------------------------------- |
| `$pinpp`    | search_criteria.pinpp | 14-digit PINFL of the person being looked up |

---

## Postman Examples

### `gct_certificate`

> Получает информацию о сертификатах, выданных ГЦТ (Государственный Центр Тестирования) по ПИНФЛ.

```bash
curl -X GET 'https://apimgw.egov.uz:8243/dtm/service/certificate/v1?PNFL=51111026300066' \
  -H 'Authorization: Bearer {{access_token}}'
```

| Postman Variable | Example Value    | Description |
| ---------------- | ---------------- | ----------- |
| `PNFL`           | `51111026300066` | Test PINFL  |

---

## Seed Data Reference

```typescript
{
  methodName: "gct_certificate",
  serviceName: "egov_main",
  httpMethod: "GET",
  endpoint: "/dtm/service/certificate/v1",
  defaultBody: {
    PNFL: "$pinpp"
  }
}
```
