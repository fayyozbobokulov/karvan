# DTM Nostrification -- /service/dtm/nostrifikatsiya/v1/api

**Category:** education
**Service:** egov_main
**Base URL:** `https://apimgw.egov.uz:8243`

## Overview

This endpoint retrieves nostrification (foreign diploma recognition) data from the DTM (Davlat Test Markazi -- State Testing Center). It verifies whether a foreign education diploma has been officially recognized in Uzbekistan. This method uses a GET request with passport details as query parameters.

---

## Methods

### `nostrification`

| Field         | Value                                 |
| ------------- | ------------------------------------- |
| HTTP Method   | GET                                   |
| Endpoint      | `/service/dtm/nostrifikatsiya/v1/api` |
| Service       | egov_main                             |
| Timeout       | 60000ms                               |
| Requires Auth | Yes                                   |

#### Query Parameters

```json
{
  "imie": "$passport_number",
  "ps": "$passport_series"
}
```

#### Placeholder Variables

| Placeholder        | Source                          | Description                                   |
| ------------------ | ------------------------------- | --------------------------------------------- |
| `$passport_number` | search_criteria.passport_number | Passport number of the person being looked up |
| `$passport_series` | search_criteria.passport_series | Passport series of the person being looked up |

---

## Postman Examples

### `nostrification`

> Получает информацию о международных дипломах, прошедших нострификацию, по ПИНФЛ и паспорту.

```bash
curl -X GET 'https://apimgw.egov.uz:8243/service/dtm/nostrifikatsiya/v1/api?imie=30711961000026&ps=AB5591779' \
  -H 'Authorization: Bearer {{access_token}}'
```

| Postman Variable | Example Value    | Description                   |
| ---------------- | ---------------- | ----------------------------- |
| `imie`           | `30711961000026` | Test PINFL                    |
| `ps`             | `AB5591779`      | Test passport series + number |

---

## Seed Data Reference

```typescript
{
  methodName: "nostrification",
  serviceName: "egov_main",
  httpMethod: "GET",
  endpoint: "/service/dtm/nostrifikatsiya/v1/api",
  defaultBody: {
    imie: "$passport_number",
    ps: "$passport_series"
  }
}
```
