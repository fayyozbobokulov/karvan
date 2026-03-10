# MVD Person Probation — `/mvd/services/person/v1/`

**Category:** Legal
**Service:** egov_mvd
**Base URL:** `https://apimgw.egov.uz:8243`

## Overview

Two-step probation check for a person via MVD services. The first method submits a probation request using personal identification data, and the second method retrieves the probation response using the request ID and date returned from the first call.

---

## Methods

### `person_probation_request`

| Field         | Value                             |
| ------------- | --------------------------------- |
| HTTP Method   | POST                              |
| Endpoint      | `/mvd/services/person/v1/request` |
| Service       | egov_mvd                          |
| Timeout       | 60000ms                           |
| Requires Auth | Yes                               |

#### Request Body

```json
{
  "Pinpp": "$pinpp",
  "pSurname": null,
  "pName": null,
  "pPatronym": null,
  "pBirthdate": "$birth_date",
  "passportSerial": "$passport_series",
  "passportNumber": "$passport_number",
  "pId": 1,
  "pDivision": null,
  "pDate": null
}
```

#### Placeholder Variables

| Placeholder        | Source                    | Description                                       |
| ------------------ | ------------------------- | ------------------------------------------------- |
| `$pinpp`           | Flow context / user input | Personal Identification Number of Physical Person |
| `$birth_date`      | Flow context / user input | Date of birth, formatted as DD.MM.YYYY            |
| `$passport_series` | Flow context / user input | Passport series (e.g., "AA")                      |
| `$passport_number` | Flow context / user input | Passport number (e.g., "1234567")                 |

#### Response Structure

Returns a probation request ID (`pId`) and date (`pDate`) used to retrieve the probation response in the subsequent call.

#### Error Handling

Standard API error handling. Non-200 responses are treated as failures.

---

### `person_probation_response`

| Field         | Value                              |
| ------------- | ---------------------------------- |
| HTTP Method   | POST                               |
| Endpoint      | `/mvd/services/person/v1/response` |
| Service       | egov_mvd                           |
| Timeout       | 60000ms                            |
| Requires Auth | Yes                                |

#### Request Body

```json
{
  "pId": "$pId",
  "pDate": "$pDate"
}
```

#### Placeholder Variables

| Placeholder | Source                                       | Description                                         |
| ----------- | -------------------------------------------- | --------------------------------------------------- |
| `$pId`      | Parent response (`person_probation_request`) | Probation request ID returned from the request step |
| `$pDate`    | Parent response (`person_probation_request`) | Date value returned from the request step           |

#### Response Structure

Default transform. Returns the full probation check result for the person.

#### Error Handling

Standard API error handling. Non-200 responses are treated as failures.

---

## Parent-Child Dependencies

`person_probation_response` depends on `person_probation_request`.

The chaining works as follows:

1. `person_probation_request` is called first with the person's identification data.
2. The response provides `pId` and `pDate` values.
3. These values are passed as `parent_id` context into `person_probation_response`.
4. `person_probation_response` uses the `pId` and `pDate` from the parent response to retrieve the probation result.

## Postman Examples

### `person_probation_request`

> Отправляет запрос для проверки лица на профилактическом и пробационном учете. Возвращает pId.

```bash
curl -X POST 'https://apimgw.egov.uz:8243/mvd/services/person/v1/request' \
  -H 'Authorization: Bearer {{access_token}}' \
  -H 'Content-Type: application/json' \
  -d '{
  "Pinpp": "31002730280037",
  "pSurname": "BOBOKULOV",
  "pName": "FAYYOZJON",
  "pPatronym": "ALIQUL O'\''GLI",
  "pBirthdate": "01.01.2000",
  "passportSerial": "",
  "passportNumber": "",
  "pId": 12326
}'
```

| Postman Variable | Example Value    | Description                                                  |
| ---------------- | ---------------- | ------------------------------------------------------------ |
| `{{pnfl}}`       | `31002730280037` | Test PINFL (used as `Pinpp`)                                 |
| `pId`            | `12326`          | Request identifier; returned and reused in the response step |

### `person_probation_response`

> Получает результат проверки лица на профилактическом и пробационном учете по pId.

```bash
curl -X POST 'https://apimgw.egov.uz:8243/mvd/services/person/v1/response' \
  -H 'Authorization: Bearer {{access_token}}' \
  -H 'Content-Type: application/json' \
  -d '{
  "pId": 12326,
  "pDate": "01.01.2026"
}'
```

| Postman Variable | Example Value | Description                                                     |
| ---------------- | ------------- | --------------------------------------------------------------- |
| `pId`            | `12326`       | Probation request ID (from `person_probation_request` response) |
| `pDate`          | `01.01.2026`  | Date for the probation check                                    |

---

## Seed Data Reference

```typescript
// Step 1: Request
{
  methodName: "person_probation_request",
  serviceName: "egov_mvd",
  httpMethod: "POST",
  endpoint: "/mvd/services/person/v1/request",
  defaultBody: {
    Pinpp: "$pinpp",
    pSurname: null,
    pName: null,
    pPatronym: null,
    pBirthdate: "$birth_date",
    passportSerial: "$passport_series",
    passportNumber: "$passport_number",
    pId: 1,
    pDivision: null,
    pDate: null
  }
}

// Step 2: Response (parent_id -> person_probation_request)
{
  methodName: "person_probation_response",
  serviceName: "egov_mvd",
  httpMethod: "POST",
  endpoint: "/mvd/services/person/v1/response",
  defaultBody: {
    pId: "$pId",
    pDate: "$pDate"
  }
}
```
