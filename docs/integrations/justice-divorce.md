# Justice Divorce — /justice/service/divorce/v1

**Category:** civil_status
**Service:** egov_zags
**Base URL:** `https://apimgw.egov.uz:8243`

## Overview

Provides divorce record lookup from the ZAGS (civil registry) system. Supports querying divorce records by personal identification number (PINFL), certificate details, or personal name information.

---

## Methods

### `divorce_by_pinfl`

| Field         | Value                         |
| ------------- | ----------------------------- |
| HTTP Method   | POST                          |
| Endpoint      | `/justice/service/divorce/v1` |
| Service       | egov_zags                     |
| Timeout       | 60000ms                       |
| Requires Auth | Yes                           |

#### Request Body

```json
{
  "id": 1,
  "pin": "$pinpp"
}
```

#### Placeholder Variables

| Placeholder | Source           | Description                                              |
| ----------- | ---------------- | -------------------------------------------------------- |
| `$pinpp`    | Workflow context | Personal identification number (PINFL) of the individual |

#### Response Structure

Returns divorce record details matching the provided PINFL.

---

### `divorce_by_cert`

| Field         | Value                         |
| ------------- | ----------------------------- |
| HTTP Method   | POST                          |
| Endpoint      | `/justice/service/divorce/v1` |
| Service       | egov_zags                     |
| Timeout       | 60000ms                       |
| Requires Auth | Yes                           |

#### Request Body

```json
{
  "id": 1,
  "cert_series": "$passport_series",
  "cert_number": "$passport_number"
}
```

#### Placeholder Variables

| Placeholder        | Source           | Description                                |
| ------------------ | ---------------- | ------------------------------------------ |
| `$passport_series` | Workflow context | Certificate series (e.g., passport series) |
| `$passport_number` | Workflow context | Certificate number (e.g., passport number) |

#### Response Structure

Returns divorce record details matching the provided certificate series and number.

---

### `divorce_by_name`

| Field         | Value                         |
| ------------- | ----------------------------- |
| HTTP Method   | POST                          |
| Endpoint      | `/justice/service/divorce/v1` |
| Service       | egov_zags                     |
| Timeout       | 60000ms                       |
| Requires Auth | Yes                           |

#### Request Body

```json
{
  "id": 1,
  "surname": null,
  "name": null,
  "patronym": null,
  "birth_year": "$birth_year",
  "type": "2"
}
```

#### Placeholder Variables

| Placeholder   | Source           | Description                     |
| ------------- | ---------------- | ------------------------------- |
| `$birth_year` | Workflow context | Year of birth of the individual |

**Note:** The `surname`, `name`, and `patronym` fields are set to `null` in the default body and should be populated at runtime from the workflow context. The `type` field is set to `"2"` indicating a divorce record search.

#### Response Structure

Returns divorce record details matching the provided name and birth year criteria.

---

## Postman Examples

### `divorce_by_pinfl`

> Получает данные свидетельства о расторжении брака по ПИНФЛ (любого из супругов).

```bash
curl -X POST 'https://apimgw.egov.uz:8243/justice/service/divorce/v1' \
  -H 'Authorization: Bearer {{access_token}}' \
  -H 'Content-Type: application/json' \
  -d '{
  "id": "112312",
  "pin": "31002730280037"
}'
```

| Postman Variable | Example Value    | Description                 |
| ---------------- | ---------------- | --------------------------- |
| `{{pnfl}}`       | `31002730280037` | Test PINFL of either spouse |

---

### `divorce_by_cert`

> Получает данные свидетельства о расторжении брака по серии и номеру свидетельства.

```bash
curl -X POST 'https://apimgw.egov.uz:8243/justice/service/divorce/v1' \
  -H 'Authorization: Bearer {{access_token}}' \
  -H 'Content-Type: application/json' \
  -d '{
  "id": "111",
  "cert_series": "I-TN",
  "cert_number": "1234567"
}'
```

---

### `divorce_by_name`

> Получает данные свидетельства о расторжении брака по ФИО и году рождения.

```bash
curl -X POST 'https://apimgw.egov.uz:8243/justice/service/divorce/v1' \
  -H 'Authorization: Bearer {{access_token}}' \
  -H 'Content-Type: application/json' \
  -d '{
  "id": "111",
  "surname": "ESHMATOV",
  "name": "ALI",
  "patronym": "VALI O'\''GLI",
  "birth_year": "1988",
  "type": "2"
}'
```

---

## Seed Data Reference

```typescript
{
  methodName: "divorce_by_pinfl",
  serviceName: "egov_zags",
  httpMethod: "POST",
  endpoint: "/justice/service/divorce/v1",
  defaultBody: { id: 1, pin: "$pinpp" }
}
```

```typescript
{
  methodName: "divorce_by_cert",
  serviceName: "egov_zags",
  httpMethod: "POST",
  endpoint: "/justice/service/divorce/v1",
  defaultBody: { id: 1, cert_series: "$passport_series", cert_number: "$passport_number" }
}
```

```typescript
{
  methodName: "divorce_by_name",
  serviceName: "egov_zags",
  httpMethod: "POST",
  endpoint: "/justice/service/divorce/v1",
  defaultBody: { id: 1, surname: null, name: null, patronym: null, birth_year: "$birth_year", type: "2" }
}
```
