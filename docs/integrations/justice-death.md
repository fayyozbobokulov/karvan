# Justice Death — /justice/service/death/v1

**Category:** civil_status
**Service:** egov_zags
**Base URL:** `https://apimgw.egov.uz:8243`

## Overview

Provides death record lookup from the ZAGS (civil registry) system. Supports querying death records by personal identification number (PINFL), certificate details, or personal name information.

---

## Methods

### `death_by_pinfl`

| Field         | Value                       |
| ------------- | --------------------------- |
| HTTP Method   | POST                        |
| Endpoint      | `/justice/service/death/v1` |
| Service       | egov_zags                   |
| Timeout       | 60000ms                     |
| Requires Auth | Yes                         |

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

Returns death record details matching the provided PINFL.

---

### `death_by_cert`

| Field         | Value                       |
| ------------- | --------------------------- |
| HTTP Method   | POST                        |
| Endpoint      | `/justice/service/death/v1` |
| Service       | egov_zags                   |
| Timeout       | 60000ms                     |
| Requires Auth | Yes                         |

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

Returns death record details matching the provided certificate series and number.

---

### `death_by_name`

| Field         | Value                       |
| ------------- | --------------------------- |
| HTTP Method   | POST                        |
| Endpoint      | `/justice/service/death/v1` |
| Service       | egov_zags                   |
| Timeout       | 60000ms                     |
| Requires Auth | Yes                         |

#### Request Body

```json
{
  "id": 1,
  "surname": null,
  "name": null,
  "patronym": null,
  "birth_year": "$birth_year"
}
```

#### Placeholder Variables

| Placeholder   | Source           | Description                     |
| ------------- | ---------------- | ------------------------------- |
| `$birth_year` | Workflow context | Year of birth of the individual |

**Note:** The `surname`, `name`, and `patronym` fields are set to `null` in the default body and should be populated at runtime from the workflow context. Unlike birth, marriage, and divorce lookups, the death record search does not include a `type` field.

#### Response Structure

Returns death record details matching the provided name and birth year criteria.

---

## Postman Examples

### `death_by_pinfl`

> Получает данные свидетельства о смерти по ПИНФЛ усопшего.

```bash
curl -X POST 'https://apimgw.egov.uz:8243/justice/service/death/v1' \
  -H 'Authorization: Bearer {{access_token}}' \
  -H 'Content-Type: application/json' \
  -d '{
  "id": "111",
  "pin": "32008590190041"
}'
```

---

### `death_by_cert`

> Получает данные свидетельства о смерти по серии и номеру свидетельства.

```bash
curl -X POST 'https://apimgw.egov.uz:8243/justice/service/death/v1' \
  -H 'Authorization: Bearer {{access_token}}' \
  -H 'Content-Type: application/json' \
  -d '{
  "id": "111",
  "cert_series": "I-TN",
  "cert_number": "1234567"
}'
```

---

### `death_by_name`

> Получает данные свидетельства о смерти по ФИО и году рождения усопшего.

```bash
curl -X POST 'https://apimgw.egov.uz:8243/justice/service/death/v1' \
  -H 'Authorization: Bearer {{access_token}}' \
  -H 'Content-Type: application/json' \
  -d '{
  "id": "111",
  "surname": "ESHMATOV",
  "name": "ALI",
  "patronym": "VALI O'\''GLI",
  "birth_year": "1918"
}'
```

---

## Seed Data Reference

```typescript
{
  methodName: "death_by_pinfl",
  serviceName: "egov_zags",
  httpMethod: "POST",
  endpoint: "/justice/service/death/v1",
  defaultBody: { id: 1, pin: "$pinpp" }
}
```

```typescript
{
  methodName: "death_by_cert",
  serviceName: "egov_zags",
  httpMethod: "POST",
  endpoint: "/justice/service/death/v1",
  defaultBody: { id: 1, cert_series: "$passport_series", cert_number: "$passport_number" }
}
```

```typescript
{
  methodName: "death_by_name",
  serviceName: "egov_zags",
  httpMethod: "POST",
  endpoint: "/justice/service/death/v1",
  defaultBody: { id: 1, surname: null, name: null, patronym: null, birth_year: "$birth_year" }
}
```
