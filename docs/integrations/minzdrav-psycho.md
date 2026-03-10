# Minzdrav Psycho Dispensary — `/minzdrav/disp/psycho/v1/`

**Category:** medical
**Service:** egov_minzdrav
**Base URL:** `https://apimgw.egov.uz:8243`

## Overview

Psychiatric dispensary check endpoints provided by the Ministry of Health (Minzdrav). These methods verify whether an individual is registered in the psychiatric dispensary system. Lookup can be performed by PINFL, passport details, or birth certificate.

---

## Methods

### `psycho_by_pinfl`

| Field         | Value                               |
| ------------- | ----------------------------------- |
| HTTP Method   | POST                                |
| Endpoint      | `/minzdrav/disp/psycho/v1/by-pinpp` |
| Service       | egov_minzdrav                       |
| Timeout       | 60000ms                             |
| Requires Auth | Yes                                 |

#### Request Body

```json
{
  "pinpp": "$pinpp"
}
```

#### Placeholder Variables

| Placeholder | Source       | Description                                         |
| ----------- | ------------ | --------------------------------------------------- |
| `$pinpp`    | Flow context | Individual's PINFL (personal identification number) |

---

### `psycho_by_passport`

| Field         | Value                                  |
| ------------- | -------------------------------------- |
| HTTP Method   | POST                                   |
| Endpoint      | `/minzdrav/disp/psycho/v1/by-passport` |
| Service       | egov_minzdrav                          |
| Timeout       | 60000ms                                |
| Requires Auth | Yes                                    |

#### Request Body

```json
{
  "serial": "$passport_series",
  "number": "$passport_number"
}
```

#### Placeholder Variables

| Placeholder        | Source       | Description                       |
| ------------------ | ------------ | --------------------------------- |
| `$passport_series` | Flow context | Passport series (e.g., "AA")      |
| `$passport_number` | Flow context | Passport number (e.g., "1234567") |

---

### `psycho_by_cert`

| Field         | Value                              |
| ------------- | ---------------------------------- |
| HTTP Method   | POST                               |
| Endpoint      | `/minzdrav/disp/psycho/v1/by-cert` |
| Service       | egov_minzdrav                      |
| Timeout       | 60000ms                            |
| Requires Auth | Yes                                |

#### Request Body

```json
{
  "serial": "$passport_series",
  "number": "$passport_number",
  "birthDate": "$birth_date"
}
```

#### Placeholder Variables

| Placeholder        | Source       | Description              |
| ------------------ | ------------ | ------------------------ |
| `$passport_series` | Flow context | Birth certificate series |
| `$passport_number` | Flow context | Birth certificate number |
| `$birth_date`      | Flow context | Date of birth            |

---

## Postman Examples

### `psycho_by_pinfl`

> Получает сведения об учёте в психодиспансере по ПИНФЛ.

```bash
curl -X POST 'https://apimgw.egov.uz:8243/minzdrav/disp/psycho/v1/by-pinpp' \
  -H 'Authorization: Bearer {{access_token}}' \
  -H 'Content-Type: application/json' \
  -d '{ "pinpp": "51203781960045" }'
```

| Postman Variable   | Example Value    | Description         |
| ------------------ | ---------------- | ------------------- |
| `{{access_token}}` | —                | OAuth2 Bearer token |
| `pinpp`            | `51203781960045` | Test PINFL          |

### `psycho_by_passport`

> Получает сведения об учёте в психодиспансере по серии и номеру паспорта.

```bash
curl -X POST 'https://apimgw.egov.uz:8243/minzdrav/disp/psycho/v1/by-passport' \
  -H 'Authorization: Bearer {{access_token}}' \
  -H 'Content-Type: application/json' \
  -d '{ "serial": "AA", "number": "1234567" }'
```

| Postman Variable   | Example Value | Description         |
| ------------------ | ------------- | ------------------- |
| `{{access_token}}` | —             | OAuth2 Bearer token |
| `serial`           | `AA`          | Passport series     |
| `number`           | `1234567`     | Passport number     |

### `psycho_by_cert`

> Получает сведения об учёте в психодиспансере по свидетельству о рождении и дате рождения.

```bash
curl -X POST 'https://apimgw.egov.uz:8243/minzdrav/disp/psycho/v1/by-cert' \
  -H 'Authorization: Bearer {{access_token}}' \
  -H 'Content-Type: application/json' \
  -d '{ "serial": "I-TN", "number": "1234567", "birthDate": "2015-10-20" }'
```

| Postman Variable   | Example Value | Description              |
| ------------------ | ------------- | ------------------------ |
| `{{access_token}}` | —             | OAuth2 Bearer token      |
| `serial`           | `I-TN`        | Birth certificate series |
| `number`           | `1234567`     | Birth certificate number |
| `birthDate`        | `2015-10-20`  | Date of birth            |

---

## Seed Data Reference

```typescript
{
  methodName: "psycho_by_pinfl",
  serviceName: "egov_minzdrav",
  httpMethod: "POST",
  endpoint: "/minzdrav/disp/psycho/v1/by-pinpp",
  defaultBody: { pinpp: "$pinpp" }
}
```

```typescript
{
  methodName: "psycho_by_passport",
  serviceName: "egov_minzdrav",
  httpMethod: "POST",
  endpoint: "/minzdrav/disp/psycho/v1/by-passport",
  defaultBody: { serial: "$passport_series", number: "$passport_number" }
}
```

```typescript
{
  methodName: "psycho_by_cert",
  serviceName: "egov_minzdrav",
  httpMethod: "POST",
  endpoint: "/minzdrav/disp/psycho/v1/by-cert",
  defaultBody: { serial: "$passport_series", number: "$passport_number", birthDate: "$birth_date" }
}
```
