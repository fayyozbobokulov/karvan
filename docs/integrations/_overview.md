# eGov Integration API Reference

All 68 integration methods from the Uzbekistan eGov API gateway, organized by endpoint.

## Base Configuration

| Setting            | Value                                                                                                                    |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------ |
| Base URL           | `https://apimgw.egov.uz:8243` (env: `EGOV_API_BASE_URL`)                                                                 |
| Auth               | OAuth2 Bearer token (auto-acquired via `EGOV_CONSUMER_KEY` / `EGOV_CONSUMER_SECRET` / `EGOV_USERNAME` / `EGOV_PASSWORD`) |
| Default Timeout    | 60000ms                                                                                                                  |
| Content-Type       | `application/json`                                                                                                       |
| Placeholder Syntax | `$variable_name` in `default_body` gets replaced with values from `search_criteria`                                      |

## Authentication

| File                           | Endpoint                                 | Description                             |
| ------------------------------ | ---------------------------------------- | --------------------------------------- |
| [auth-token.md](auth-token.md) | `https://iskm.egov.uz:9444/oauth2/token` | OAuth2 password grant token acquisition |

All API calls require a Bearer token. See [auth-token.md](auth-token.md) for the full authentication flow, environment variables, and token caching strategy.

## Services

| Service Name    | Description                                                                   |
| --------------- | ----------------------------------------------------------------------------- |
| `egov_main`     | Main eGov gateway (passport, convictions, migration, vehicles, pension, etc.) |
| `egov_mvd`      | Ministry of Internal Affairs (address, probation, emamuriy)                   |
| `egov_mib`      | Bureau of Enforcement (alimony, travel bans)                                  |
| `egov_zags`     | Civil Registry (birth, marriage, divorce, death)                              |
| `egov_minzdrav` | Ministry of Health (narko, psycho, vtek, medkarta)                            |
| `egov_gnk`      | Tax Committee (debts, self-employed, YATT)                                    |
| `egov_kadastr`  | Cadastre Agency (property)                                                    |

---

## Category: Passport (4 methods, 3 endpoints)

| File                                         | Endpoint                | Methods                                       |
| -------------------------------------------- | ----------------------- | --------------------------------------------- |
| [gcp-docrest.md](gcp-docrest.md)             | `/gcp/docrest/v1`       | `passport_by_pinfl_document`, `passport_data` |
| [gcp-rest.md](gcp-rest.md)                   | `/gcp/rest/v1`          | `passport_by_pinfl_birthdate`                 |
| [gcp-birthdaterest.md](gcp-birthdaterest.md) | `/gcp/birthdaterest/v1` | `passport_by_document_birthdate`              |

## Category: Address (1 method, 1 endpoint)

| File                                       | Endpoint                            | Methods        |
| ------------------------------------------ | ----------------------------------- | -------------- |
| [mvd-address-info.md](mvd-address-info.md) | `/mvd/services/address/info/pin/v1` | `address_info` |

## Category: Legal (11 methods, 8 endpoints)

| File                                               | Endpoint                                         | Methods                                                                                    |
| -------------------------------------------------- | ------------------------------------------------ | ------------------------------------------------------------------------------------------ |
| [mvd-emamuriy.md](mvd-emamuriy.md)                 | `/mvd/services/emamuriy/v1/by-pinpp`             | `emamuriy`                                                                                 |
| [mvd-person-probation.md](mvd-person-probation.md) | `/mvd/services/person/v1/*`                      | `person_probation_request`, `person_probation_response`                                    |
| [convictions.md](convictions.md)                   | `/convictions/search/v2`, `/conviction/check/v2` | `conviction_search`, `conviction_check`                                                    |
| [mib-alimony.md](mib-alimony.md)                   | `/mib/service/aliment/v2/pinfl`                  | `alimony`                                                                                  |
| [mib-debtban.md](mib-debtban.md)                   | `/mib/service/debtban/v2/*`                      | `travel_ban_by_pinfl`, `travel_ban_by_passport`, `travel_ban_by_tin`, `travel_ban_unified` |
| [justice-migration.md](justice-migration.md)       | `/justice/service/migrant/v1`                    | `migration_info`                                                                           |

## Category: Civil Status (13 methods, 5 endpoints)

| File                                             | Endpoint                       | Methods                                                     |
| ------------------------------------------------ | ------------------------------ | ----------------------------------------------------------- |
| [justice-birth.md](justice-birth.md)             | `/justice/service/birth/v1`    | `birth_by_pinfl`, `birth_by_cert`, `birth_by_name`          |
| [justice-marriage.md](justice-marriage.md)       | `/justice/service/marriage/v1` | `marriage_by_pinfl`, `marriage_by_cert`, `marriage_by_name` |
| [justice-divorce.md](justice-divorce.md)         | `/justice/service/divorce/v1`  | `divorce_by_pinfl`, `divorce_by_cert`, `divorce_by_name`    |
| [justice-death.md](justice-death.md)             | `/justice/service/death/v1`    | `death_by_pinfl`, `death_by_cert`, `death_by_name`          |
| [adliya-family-check.md](adliya-family-check.md) | `/adliya/family-chek/v1`       | `family_check`                                              |

## Category: Medical (10 methods, 5 endpoints)

| File                                       | Endpoint                          | Methods                                                   |
| ------------------------------------------ | --------------------------------- | --------------------------------------------------------- |
| [minzdrav-narko.md](minzdrav-narko.md)     | `/minzdrav/disp/narko/v1/*`       | `narko_by_pinfl`, `narko_by_passport`, `narko_by_cert`    |
| [minzdrav-psycho.md](minzdrav-psycho.md)   | `/minzdrav/disp/psycho/v1/*`      | `psycho_by_pinfl`, `psycho_by_passport`, `psycho_by_cert` |
| [minzdrav-vtek.md](minzdrav-vtek.md)       | `/minzdrav/vtek/v4/*`             | `vtek_by_passport`, `vtek_by_birth_doc`                   |
| [minzdrav-medcert.md](minzdrav-medcert.md) | `/minzdrav/medicalcertificate/v1` | `medical_certificate`                                     |
| [ssv-medkarta.md](ssv-medkarta.md)         | `/ssv/medkarta/v1/ServiceRequest` | `medkarta_service`                                        |

## Category: Tax (5 methods, 4 endpoints)

| File                                               | Endpoint                           | Methods                                        |
| -------------------------------------------------- | ---------------------------------- | ---------------------------------------------- |
| [gnk-indentre-debt.md](gnk-indentre-debt.md)       | `/gnk/service/indentre/debt/v1`    | `entrepreneur_debt`                            |
| [gnk-legalentity-debt.md](gnk-legalentity-debt.md) | `/gnk/service/legalentity/debt/v1` | `legal_entity_debt`                            |
| [gnk-selfemployed.md](gnk-selfemployed.md)         | `/gnk/service/selfemployed/v1`     | `self_employed`                                |
| [gnk-yatt.md](gnk-yatt.md)                         | `/gnk/service/yatt/v1/*`           | `yatt_entrepreneur_data`, `yatt_founders_data` |

## Category: Transport (5 methods, 2 endpoints)

| File                                             | Endpoint                           | Methods                                                                              |
| ------------------------------------------------ | ---------------------------------- | ------------------------------------------------------------------------------------ |
| [yhxbb-carinfo.md](yhxbb-carinfo.md)             | `/yhxbb/service/carinfo/v1`        | `vehicle_by_pinfl`, `vehicle_by_plate`, `vehicle_by_tin`, `vehicle_by_tech_passport` |
| [yhxbb-driverlicense.md](yhxbb-driverlicense.md) | `/yhxbb/driverlicense/by-pinfl/v1` | `driver_license`                                                                     |

## Category: Property (3 methods, 1 endpoint)

| File                                   | Endpoint             | Methods                                                         |
| -------------------------------------- | -------------------- | --------------------------------------------------------------- |
| [kadastr-cadnum.md](kadastr-cadnum.md) | `/kadastr/cadnum/v3` | `property_by_pinfl`, `property_by_tin`, `property_by_cadastral` |

## Category: Finance (3 methods, 3 endpoints)

| File                                   | Endpoint             | Methods                                                      |
| -------------------------------------- | -------------------- | ------------------------------------------------------------ |
| [minfin-pension.md](minfin-pension.md) | `/minfin/services/*` | `pension_check`, `pension_size`, `pension_assign_and_amount` |

## Category: Employment (2 methods, 2 endpoints)

| File                                     | Endpoint            | Methods                        |
| ---------------------------------------- | ------------------- | ------------------------------ |
| [labour-services.md](labour-services.md) | `/labour/service/*` | `unemployment`, `work_history` |

## Category: Social (1 method, 1 endpoint)

| File                                                 | Endpoint                     | Methods            |
| ---------------------------------------------------- | ---------------------------- | ------------------ |
| [ihma-poverty-registry.md](ihma-poverty-registry.md) | `/ihma/get-reestr-family/v1` | `poverty_registry` |

## Category: Education (3 methods, 3 endpoints)

| File                                           | Endpoint                              | Methods           |
| ---------------------------------------------- | ------------------------------------- | ----------------- |
| [minvuz-diploma.md](minvuz-diploma.md)         | `/minvuz/services/diploma/v2`         | `diploma`         |
| [dtm-certificate.md](dtm-certificate.md)       | `/dtm/service/certificate/v1`         | `gct_certificate` |
| [dtm-nostrification.md](dtm-nostrification.md) | `/service/dtm/nostrifikatsiya/v1/api` | `nostrification`  |

---

## Parent-Child Dependencies

Some integrations depend on the result of a parent integration:

| Parent Method              | Child Method                | Data Passed                         |
| -------------------------- | --------------------------- | ----------------------------------- |
| `person_probation_request` | `person_probation_response` | `pId`, `pDate` from parent response |
| `conviction_search`        | `conviction_check`          | `id_query` from parent response     |

These are configured via the `parentId` and `responseMapping` fields in `integrationSettings`.

---

## Placeholder Variables Reference

| Placeholder                        | Source Field                       | Description                           |
| ---------------------------------- | ---------------------------------- | ------------------------------------- |
| `$pinpp`                           | `search_criteria.pinpp`            | 14-digit Personal ID (PINFL)          |
| `$sender_pinpp`                    | `search_criteria.sender_pinpp`     | Sender's PINFL                        |
| `$passport_series`                 | `search_criteria.passport_serial`  | 2-letter passport series (e.g., "AA") |
| `$passport_number`                 | `search_criteria.passport_number`  | 7-digit passport number               |
| `$passport_series$passport_number` | concatenated                       | Full passport (e.g., "AA1234567")     |
| `$birth_date`                      | `search_criteria.birth_date`       | Birth date (format varies by API)     |
| `$birth_year`                      | `search_criteria.birth_year`       | Birth year (4 digits)                 |
| `$tin`                             | `search_criteria.tin`              | 9-digit Tax ID (TIN/STIR)             |
| `$sender_tin`                      | `search_criteria.sender_tin`       | Sender's TIN                          |
| `$plate_number`                    | `search_criteria.plate_number`     | Vehicle plate number                  |
| `$cadastral_number`                | `search_criteria.cadastral_number` | Cadastral number                      |
| `$document`                        | `search_criteria.document`         | Generic document field                |
| `$pId`                             | `search_criteria.pId`              | Probation request ID (from parent)    |
| `$pDate`                           | `search_criteria.pDate`            | Probation date (from parent)          |

---

## Default Response Transformation

All methods (except those with custom transforms noted in their docs) use `applyDefaultTransformation()`:

### Success Detection (first match wins)

```
response.success === true
response.result_code === 1
response.AnswereId === 1
response.pResult === 1
response.status === 1
response.status?.code === 200
```

### Data Extraction (first match wins)

```
response.items
response.data
response.Data
response.results
response.result.data
response.result (if object)
entire response (fallback)
```

### Unified Output

```json
{
  "success": true,
  "code": 1,
  "message": "string",
  "data": {},
  "raw": {}
}
```

---

## Integration Status Enum

| Status           | Meaning                                 |
| ---------------- | --------------------------------------- |
| `success`        | API returned valid data                 |
| `pending`        | Waiting for processing                  |
| `running`        | Currently executing                     |
| `api_failure`    | 5xx / timeout / network error           |
| `unauthorized`   | 401/403                                 |
| `not_found`      | Entity doesn't exist in external system |
| `params_missing` | Validation error                        |
| `timeout`        | Request timed out                       |
| `completed`      | Records successfully created in DB      |
| `skipped`        | Integration skipped                     |
