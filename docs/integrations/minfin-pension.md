# MinFin Pension Services -- /minfin/services/

**Category:** finance
**Service:** egov_main
**Base URL:** `https://apimgw.egov.uz:8243`

## Overview

This endpoint group provides pension-related data from the Ministry of Finance (MinFin). It includes methods for checking pension eligibility, retrieving pension size, and getting pension assignment and amount details.

---

## Methods

### `pension_check`

| Field         | Value                                 |
| ------------- | ------------------------------------- |
| HTTP Method   | POST                                  |
| Endpoint      | `/minfin/services/pensiyamajmuasi/v1` |
| Service       | egov_main                             |
| Timeout       | 60000ms                               |
| Requires Auth | Yes                                   |

#### Request Body

```json
{
  "ws_id": 1,
  "sender_pin": "$sender_pinpp",
  "purpose": "Checking background",
  "consent": "Y",
  "pinpp": "$pinpp",
  "document": "$passport_series$passport_number"
}
```

#### Placeholder Variables

| Placeholder        | Source                          | Description                                                     |
| ------------------ | ------------------------------- | --------------------------------------------------------------- |
| `$sender_pinpp`    | search_criteria.sender_pinpp    | PINFL of the requesting sender                                  |
| `$pinpp`           | search_criteria.pinpp           | 14-digit PINFL of the person being looked up                    |
| `$passport_series` | search_criteria.passport_series | Passport series (concatenated with number for `document` field) |
| `$passport_number` | search_criteria.passport_number | Passport number (concatenated with series for `document` field) |

---

### `pension_size`

| Field         | Value                              |
| ------------- | ---------------------------------- |
| HTTP Method   | POST                               |
| Endpoint      | `/minfin/services/pension/v1/size` |
| Service       | egov_main                          |
| Timeout       | 60000ms                            |
| Requires Auth | Yes                                |

#### Request Body

```json
{
  "pin": "$pinpp",
  "lang": "1",
  "type": "1"
}
```

#### Placeholder Variables

| Placeholder | Source                | Description                                  |
| ----------- | --------------------- | -------------------------------------------- |
| `$pinpp`    | search_criteria.pinpp | 14-digit PINFL of the person being looked up |

#### Custom Transform

The response fields are renamed for consistency:

| Original Field   | Transformed Field |
| ---------------- | ----------------- |
| `pension_amount` | `pensionAmount`   |
| `pension_type`   | `pensionType`     |
| `assign_date`    | `assignDate`      |

---

### `pension_assign_and_amount`

| Field         | Value                                         |
| ------------- | --------------------------------------------- |
| HTTP Method   | POST                                          |
| Endpoint      | `/minfin/services/pension/v1/assignAndAmount` |
| Service       | egov_main                                     |
| Timeout       | 60000ms                                       |
| Requires Auth | Yes                                           |

#### Request Body

```json
{
  "pin": "$pinpp",
  "lang": "1",
  "type": "1"
}
```

#### Placeholder Variables

| Placeholder | Source                | Description                                  |
| ----------- | --------------------- | -------------------------------------------- |
| `$pinpp`    | search_criteria.pinpp | 14-digit PINFL of the person being looked up |

---

## Postman Examples

### `pension_check`

> Check if person is a pension/social benefit recipient.

```bash
curl -X POST 'https://apimgw.egov.uz:8243/minfin/services/pensiyamajmuasi/v1' \
  -H 'Authorization: Bearer {{access_token}}' \
  -H 'Content-Type: application/json' \
  -d '{
    "ws_id": 123,
    "sender_pin": "{{pnfl}}",
    "purpose": "test",
    "consent": "ha",
    "pinpp": "{{pnfl}}",
    "document": "AC*****"
  }'
```

| Postman Variable | Example Value    | Description              |
| ---------------- | ---------------- | ------------------------ |
| `{{pnfl}}`       | `31002730280037` | Test PINFL               |
| `document`       | `AC*****`        | Passport series + number |

### `pension_size`

> Get detailed pension information including size, payment history.

```bash
curl -X POST 'https://apimgw.egov.uz:8243/minfin/services/pension/v1/size' \
  -H 'Authorization: Bearer {{access_token}}' \
  -H 'Content-Type: application/json' \
  -d '{
    "pin": "{{pnfl}}",
    "lang": "1",
    "type": "1",
    "dateBegin": "dd.mm.yyyy",
    "dateEnd": "dd.mm.yyyy"
  }'
```

| Postman Variable | Example Value    | Description                    |
| ---------------- | ---------------- | ------------------------------ |
| `{{pnfl}}`       | `31002730280037` | Test PINFL                     |
| `dateBegin`      | `dd.mm.yyyy`     | Start date for payment history |
| `dateEnd`        | `dd.mm.yyyy`     | End date for payment history   |

### `pension_assign_and_amount`

> Get combined pension assignment and amount information.

```bash
curl -X POST 'https://apimgw.egov.uz:8243/minfin/services/pension/v1/assignAndAmount' \
  -H 'Authorization: Bearer {{access_token}}' \
  -H 'Content-Type: application/json' \
  -d '{
    "pin": "32012561330028",
    "lang": "1",
    "type": "1"
  }'
```

| Postman Variable | Example Value    | Description |
| ---------------- | ---------------- | ----------- |
| `pin`            | `32012561330028` | Test PINFL  |

---

## Seed Data Reference

```typescript
// pension_check
{
  methodName: "pension_check",
  serviceName: "egov_main",
  httpMethod: "POST",
  endpoint: "/minfin/services/pensiyamajmuasi/v1",
  defaultBody: {
    ws_id: 1,
    sender_pin: "$sender_pinpp",
    purpose: "Checking background",
    consent: "Y",
    pinpp: "$pinpp",
    document: "$passport_series$passport_number"
  }
}

// pension_size
{
  methodName: "pension_size",
  serviceName: "egov_main",
  httpMethod: "POST",
  endpoint: "/minfin/services/pension/v1/size",
  defaultBody: {
    pin: "$pinpp",
    lang: "1",
    type: "1"
  }
}

// pension_assign_and_amount
{
  methodName: "pension_assign_and_amount",
  serviceName: "egov_main",
  httpMethod: "POST",
  endpoint: "/minfin/services/pension/v1/assignAndAmount",
  defaultBody: {
    pin: "$pinpp",
    lang: "1",
    type: "1"
  }
}
```
