# YHXBB Car Info -- /yhxbb/service/carinfo/v1

**Category:** transport
**Service:** egov_main
**Base URL:** `https://apimgw.egov.uz:8243`

## Overview

This endpoint provides vehicle information retrieval from the YHXBB (road police) system. It supports lookups by PINFL, license plate number, TIN, or technical passport details. All methods share the same base endpoint and include standard request identification fields.

---

## Methods

### `vehicle_by_pinfl`

| Field         | Value                       |
| ------------- | --------------------------- |
| HTTP Method   | POST                        |
| Endpoint      | `/yhxbb/service/carinfo/v1` |
| Service       | egov_main                   |
| Timeout       | 60000ms                     |
| Requires Auth | Yes                         |

#### Request Body

```json
{
  "pRequestID": 1,
  "requestInn": null,
  "requestPinfl": null,
  "pPinpp": "$pinpp"
}
```

#### Placeholder Variables

| Placeholder | Source                | Description                         |
| ----------- | --------------------- | ----------------------------------- |
| `$pinpp`    | search_criteria.pinpp | 14-digit PINFL of the vehicle owner |

---

### `vehicle_by_plate`

| Field         | Value                       |
| ------------- | --------------------------- |
| HTTP Method   | POST                        |
| Endpoint      | `/yhxbb/service/carinfo/v1` |
| Service       | egov_main                   |
| Timeout       | 60000ms                     |
| Requires Auth | Yes                         |

#### Request Body

```json
{
  "pRequestID": 1,
  "requestInn": null,
  "requestPinfl": null,
  "pPlateNumber": "$plate_number"
}
```

#### Placeholder Variables

| Placeholder     | Source                       | Description                  |
| --------------- | ---------------------------- | ---------------------------- |
| `$plate_number` | search_criteria.plate_number | Vehicle license plate number |

---

### `vehicle_by_tin`

| Field         | Value                       |
| ------------- | --------------------------- |
| HTTP Method   | POST                        |
| Endpoint      | `/yhxbb/service/carinfo/v1` |
| Service       | egov_main                   |
| Timeout       | 60000ms                     |
| Requires Auth | Yes                         |

#### Request Body

```json
{
  "pRequestID": 1,
  "requestInn": null,
  "requestPinfl": null,
  "pTin": "$tin"
}
```

#### Placeholder Variables

| Placeholder | Source              | Description                                         |
| ----------- | ------------------- | --------------------------------------------------- |
| `$tin`      | search_criteria.tin | Taxpayer Identification Number of the vehicle owner |

#### Custom Error Handling

This method includes custom error detection logic. The following conditions are treated as `NOT_FOUND`:

- Error code `VEHICLE_NOT_REGISTERED`
- Error code `NO_DATA_FOUND`
- Response returns an empty array

---

### `vehicle_by_tech_passport`

| Field         | Value                       |
| ------------- | --------------------------- |
| HTTP Method   | POST                        |
| Endpoint      | `/yhxbb/service/carinfo/v1` |
| Service       | egov_main                   |
| Timeout       | 60000ms                     |
| Requires Auth | Yes                         |

#### Request Body

```json
{
  "pRequestID": 1,
  "requestInn": null,
  "requestPinfl": null,
  "pTexpassportSery": "$passport_series",
  "pTexpassportNumber": "$passport_number",
  "pPlateNumber": "$plate_number"
}
```

#### Placeholder Variables

| Placeholder        | Source                          | Description                  |
| ------------------ | ------------------------------- | ---------------------------- |
| `$passport_series` | search_criteria.passport_series | Technical passport series    |
| `$passport_number` | search_criteria.passport_number | Technical passport number    |
| `$plate_number`    | search_criteria.plate_number    | Vehicle license plate number |

---

## Postman Examples

### `vehicle_by_pinfl`

> Получение информации о транспортных средствах физического лица по ПИНФЛ.

```bash
curl -X POST 'https://apimgw.egov.uz:8243/yhxbb/service/carinfo/v1' \
  -H 'Authorization: Bearer {{access_token}}' \
  -H 'Content-Type: application/json' \
  -d '{
    "pRequestID": "123",
    "requestInn": "201122919",
    "requestPinfl": "52103046570025",
    "pPinpp": "{{pnfl}}"
  }'
```

### `vehicle_by_tin`

> Сервис получения списка транспортных средств юридического лица по ИНН.

```bash
curl -X POST 'https://apimgw.egov.uz:8243/yhxbb/service/carinfo/v1' \
  -H 'Authorization: Bearer {{access_token}}' \
  -H 'Content-Type: application/json' \
  -d '{
    "pRequestID": "123",
    "requestInn": "{{pinfl}}",
    "requestPinfl": "",
    "pTin": "{{tin}}"
  }'
```

### `vehicle_by_plate`

> Получает информацию об автотранспортном средстве по государственному номеру.

```bash
curl -X POST 'https://apimgw.egov.uz:8243/yhxbb/service/carinfo/v1' \
  -H 'Authorization: Bearer {{access_token}}' \
  -H 'Content-Type: application/json' \
  -d '{
    "pRequestID": "123456",
    "requestInn": "{{tin}}",
    "requestPinfl": "{{pnfl}}",
    "pPlateNumber": "10A123AB"
  }'
```

### `vehicle_by_tech_passport`

> Получает информацию об автотранспортном средстве по серии и номеру технического паспорта.

```bash
curl -X POST 'https://apimgw.egov.uz:8243/yhxbb/service/carinfo/v1' \
  -H 'Authorization: Bearer {{access_token}}' \
  -H 'Content-Type: application/json' \
  -d '{
    "pRequestID": "123456",
    "requestInn": "{{tin}}",
    "requestPinfl": "{{pnfl}}",
    "pTexpassportSery": "A",
    "pTexpassportNumber": "1234567",
    "pPlateNumber": ""
  }'
```

| Postman Variable   | Example Value    | Description                                          |
| ------------------ | ---------------- | ---------------------------------------------------- |
| `{{pnfl}}`         | `52103046570025` | Test PINFL (14-digit personal identification number) |
| `{{tin}}`          | `201122919`      | Taxpayer Identification Number (INN)                 |
| `{{pinfl}}`        | `52103046570025` | Alias for PINFL used in requestInn field             |
| `{{access_token}}` | _(from OAuth)_   | Bearer token for API authorization                   |

---

## Seed Data Reference

```typescript
// vehicle_by_pinfl
{
  methodName: "vehicle_by_pinfl",
  serviceName: "egov_main",
  httpMethod: "POST",
  endpoint: "/yhxbb/service/carinfo/v1",
  defaultBody: {
    pRequestID: 1,
    requestInn: null,
    requestPinfl: null,
    pPinpp: "$pinpp"
  }
}

// vehicle_by_plate
{
  methodName: "vehicle_by_plate",
  serviceName: "egov_main",
  httpMethod: "POST",
  endpoint: "/yhxbb/service/carinfo/v1",
  defaultBody: {
    pRequestID: 1,
    requestInn: null,
    requestPinfl: null,
    pPlateNumber: "$plate_number"
  }
}

// vehicle_by_tin
{
  methodName: "vehicle_by_tin",
  serviceName: "egov_main",
  httpMethod: "POST",
  endpoint: "/yhxbb/service/carinfo/v1",
  defaultBody: {
    pRequestID: 1,
    requestInn: null,
    requestPinfl: null,
    pTin: "$tin"
  }
}

// vehicle_by_tech_passport
{
  methodName: "vehicle_by_tech_passport",
  serviceName: "egov_main",
  httpMethod: "POST",
  endpoint: "/yhxbb/service/carinfo/v1",
  defaultBody: {
    pRequestID: 1,
    requestInn: null,
    requestPinfl: null,
    pTexpassportSery: "$passport_series",
    pTexpassportNumber: "$passport_number",
    pPlateNumber: "$plate_number"
  }
}
```
