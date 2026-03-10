# MIB Debt Ban (Travel Ban) — `/mib/service/debtban/v2/`

**Category:** Legal
**Service:** egov_mib
**Base URL:** `https://apimgw.egov.uz:8243`

## Overview

Checks travel ban (debt ban) status through the MIB (Ministry of Internal Affairs Bureau of Compulsory Enforcement) service. Four lookup methods are available: by PINPP, by passport, by TIN (Taxpayer Identification Number), or a unified POST endpoint. Used for background checks to determine if a person or entity has active travel restrictions due to unpaid debts.

---

## Methods

### `travel_ban_by_pinfl`

| Field         | Value                           |
| ------------- | ------------------------------- |
| HTTP Method   | GET                             |
| Endpoint      | `/mib/service/debtban/v2/pinfl` |
| Service       | egov_mib                        |
| Timeout       | 60000ms                         |
| Requires Auth | Yes                             |

#### Query Params

```json
{
  "pin": "$pinpp",
  "transaction_id": 1,
  "sender_pinfl": "$sender_pinpp",
  "purpose": "Checking background",
  "consent": "Y"
}
```

#### Placeholder Variables

| Placeholder     | Source                    | Description                                                |
| --------------- | ------------------------- | ---------------------------------------------------------- |
| `$pinpp`        | Flow context / user input | Personal Identification Number of the person being checked |
| `$sender_pinpp` | Flow context / system     | PINPP of the requesting user or system sender              |

#### Response Structure

Default transform. Returns travel ban records for the given PINPP.

#### Error Handling

Standard API error handling. Non-200 responses are treated as failures.

---

### `travel_ban_by_passport`

| Field         | Value                              |
| ------------- | ---------------------------------- |
| HTTP Method   | POST                               |
| Endpoint      | `/mib/service/debtban/v2/passport` |
| Service       | egov_mib                           |
| Timeout       | 60000ms                            |
| Requires Auth | Yes                                |

#### Request Body

```json
{
  "passport_sn": "$passport_series",
  "passport_num": "$passport_number",
  "transaction_id": 1,
  "sender_pinfl": "$sender_pinpp",
  "purpose": "Checking background",
  "consent": "Y"
}
```

#### Placeholder Variables

| Placeholder        | Source                    | Description                                   |
| ------------------ | ------------------------- | --------------------------------------------- |
| `$passport_series` | Flow context / user input | Passport series (e.g., "AA")                  |
| `$passport_number` | Flow context / user input | Passport number (e.g., "1234567")             |
| `$sender_pinpp`    | Flow context / system     | PINPP of the requesting user or system sender |

#### Response Structure

Default transform. Returns travel ban records for the given passport.

#### Error Handling

Standard API error handling. Non-200 responses are treated as failures.

---

### `travel_ban_by_tin`

| Field         | Value                          |
| ------------- | ------------------------------ |
| HTTP Method   | POST                           |
| Endpoint      | `/mib/service/debtban/v2/stir` |
| Service       | egov_mib                       |
| Timeout       | 60000ms                        |
| Requires Auth | Yes                            |

#### Request Body

```json
{
  "inn": "$tin",
  "transaction_id": 1,
  "sender_pinfl": "$sender_pinpp",
  "purpose": "Checking background",
  "consent": "Y"
}
```

#### Placeholder Variables

| Placeholder     | Source                    | Description                                   |
| --------------- | ------------------------- | --------------------------------------------- |
| `$tin`          | Flow context / user input | Taxpayer Identification Number (TIN/INN)      |
| `$sender_pinpp` | Flow context / system     | PINPP of the requesting user or system sender |

#### Response Structure

Default transform. Returns travel ban records for the given TIN.

#### Error Handling

Standard API error handling. Non-200 responses are treated as failures.

---

### `travel_ban_unified` (POST variant)

| Field         | Value                     |
| ------------- | ------------------------- |
| HTTP Method   | POST                      |
| Endpoint      | `/mib/service/debtban/v2` |
| Service       | egov_mib                  |
| Timeout       | 60000ms                   |
| Requires Auth | Yes                       |

> This is a unified POST endpoint found in the Postman collection (folder "27) Сведения о запрете выезда за границу (2-версия)"). Unlike the three GET variants above that use subpath-specific endpoints (`/pinfl`, `/passport`, `/stir`), this endpoint accepts a POST body with a PINFL-based lookup. The request body structure differs from the GET variants.

#### Request Body

```json
{
  "pRequestID": "123",
  "applicantPinpp": "$pinpp"
}
```

#### Placeholder Variables

| Placeholder | Source                    | Description                                                |
| ----------- | ------------------------- | ---------------------------------------------------------- |
| `$pinpp`    | Flow context / user input | Personal Identification Number of the person being checked |

#### Response Structure

Default transform. Returns travel ban records for the given PINFL.

#### Error Handling

Standard API error handling. Non-200 responses are treated as failures.

---

## Parent-Child Dependencies

None. All four methods are independent lookup variants for the same debt ban check, differing by identifier type (PINPP, passport, TIN) or request format (GET with query params vs POST with body).

## Postman Examples

> **Note:** The Postman collection uses GET for all three debtban endpoints (by PINFL, by passport, by TIN), although the current documentation above lists `travel_ban_by_passport` and `travel_ban_by_tin` as POST. The actual API may accept GET with query parameters for all variants. Verify the correct HTTP method with the API provider.

### `travel_ban_by_pinfl`

> Получает информацию о запрете выезда за границу по ПИНФЛ.

```bash
curl -X GET 'https://apimgw.egov.uz:8243/mib/service/debtban/v2/pinfl?pin=31002730280037&transaction_id=1&sender_pinfl=31002730280037&purpose=test&consent=Yes' \
  -H 'Authorization: Bearer {{access_token}}'
```

| Postman Variable   | Example Value    | Description                                  |
| ------------------ | ---------------- | -------------------------------------------- |
| `{{access_token}}` | _(OAuth2 token)_ | Bearer token obtained from the auth endpoint |
| `{{pnfl}}`         | `31002730280037` | PINFL of the person being checked            |
| `{{sender_pinpp}}` | `31002730280037` | PINFL of the requesting user (sender)        |

### `travel_ban_by_passport`

> Получает информацию о запрете выезда за границу по паспорту.

```bash
curl -X GET 'https://apimgw.egov.uz:8243/mib/service/debtban/v2/passport?passport_sn=FA&passport_num=0698358&transaction_id=1&sender_pinfl=31002730280037&purpose=test&consent=Yes' \
  -H 'Authorization: Bearer {{access_token}}'
```

| Postman Variable   | Example Value    | Description                                  |
| ------------------ | ---------------- | -------------------------------------------- |
| `{{access_token}}` | _(OAuth2 token)_ | Bearer token obtained from the auth endpoint |
| `{{pnfl}}`         | `31002730280037` | PINFL used as `sender_pinfl`                 |

### `travel_ban_by_tin`

> Получает информацию о запрете выезда за границу по ИНН.

```bash
curl -X GET 'https://apimgw.egov.uz:8243/mib/service/debtban/v2/stir?inn=123456789&transaction_id=1&sender_pinfl=31002730280037&purpose=test&consent=Yes' \
  -H 'Authorization: Bearer {{access_token}}'
```

| Postman Variable   | Example Value    | Description                                  |
| ------------------ | ---------------- | -------------------------------------------- |
| `{{access_token}}` | _(OAuth2 token)_ | Bearer token obtained from the auth endpoint |
| `{{tin}}`          | `123456789`      | Taxpayer Identification Number (INN)         |
| `{{pnfl}}`         | `31002730280037` | PINFL used as `sender_pinfl`                 |

### `travel_ban_unified` (POST variant)

> Сведения о запрете выезда за границу (2-версия) — unified POST endpoint.

```bash
curl -X POST 'https://apimgw.egov.uz:8243/mib/service/debtban/v2' \
  -H 'Authorization: Bearer {{access_token}}' \
  -H 'Content-Type: application/json' \
  -d '{
  "pRequestID": "123",
  "applicantPinpp": "31002730280037"
}'
```

| Postman Variable   | Example Value    | Description                                  |
| ------------------ | ---------------- | -------------------------------------------- |
| `{{access_token}}` | _(OAuth2 token)_ | Bearer token obtained from the auth endpoint |
| `{{pnfl}}`         | `31002730280037` | PINFL of the person being checked            |

---

## Seed Data Reference

```typescript
// By PINPP
{
  methodName: "travel_ban_by_pinfl",
  serviceName: "egov_mib",
  httpMethod: "GET",
  endpoint: "/mib/service/debtban/v2/pinfl",
  defaultBody: {
    pin: "$pinpp",
    transaction_id: 1,
    sender_pinfl: "$sender_pinpp",
    purpose: "Checking background",
    consent: "Y"
  }
}

// By Passport
{
  methodName: "travel_ban_by_passport",
  serviceName: "egov_mib",
  httpMethod: "POST",
  endpoint: "/mib/service/debtban/v2/passport",
  defaultBody: {
    passport_sn: "$passport_series",
    passport_num: "$passport_number",
    transaction_id: 1,
    sender_pinfl: "$sender_pinpp",
    purpose: "Checking background",
    consent: "Y"
  }
}

// By TIN
{
  methodName: "travel_ban_by_tin",
  serviceName: "egov_mib",
  httpMethod: "POST",
  endpoint: "/mib/service/debtban/v2/stir",
  defaultBody: {
    inn: "$tin",
    transaction_id: 1,
    sender_pinfl: "$sender_pinpp",
    purpose: "Checking background",
    consent: "Y"
  }
}
```
