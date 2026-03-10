import { HttpClient } from "./http-client.js";
import { IntegrationRegistry } from "./integration-registry.js";
import type { BaseIntegrationService } from "./base-integration.service.js";

import { GcpDocrestService } from "../services/gcp-docrest.service.js";
import { GcpRestService } from "../services/gcp-rest.service.js";
import { GcpBirthdaterestService } from "../services/gcp-birthdaterest.service.js";
import { MvdAddressService } from "../services/mvd-address.service.js";
import { MvdEmamuriyService } from "../services/mvd-emamuriy.service.js";
import { MvdPersonProbationService } from "../services/mvd-person-probation.service.js";
import { ConvictionsService } from "../services/convictions.service.js";
import { MibAlimonyService } from "../services/mib-alimony.service.js";
import { MibDebtbanService } from "../services/mib-debtban.service.js";
import { JusticeMigrationService } from "../services/justice-migration.service.js";
import { JusticeBirthService } from "../services/justice-birth.service.js";
import { JusticeMarriageService } from "../services/justice-marriage.service.js";
import { JusticeDivorceService } from "../services/justice-divorce.service.js";
import { JusticeDeathService } from "../services/justice-death.service.js";
import { AdliyaFamilyCheckService } from "../services/adliya-family-check.service.js";
import { MinzdravNarkoService } from "../services/minzdrav-narko.service.js";
import { MinzdravPsychoService } from "../services/minzdrav-psycho.service.js";
import { MinzdravVtekService } from "../services/minzdrav-vtek.service.js";
import { MinzdravMedcertService } from "../services/minzdrav-medcert.service.js";
import { SsvMedkartaService } from "../services/ssv-medkarta.service.js";
import { GnkIndentreDebtService } from "../services/gnk-indentre-debt.service.js";
import { GnkLegalentityDebtService } from "../services/gnk-legalentity-debt.service.js";
import { GnkSelfemployedService } from "../services/gnk-selfemployed.service.js";
import { GnkYattService } from "../services/gnk-yatt.service.js";
import { YhxbbCarinfoService } from "../services/yhxbb-carinfo.service.js";
import { YhxbbDriverlicenseService } from "../services/yhxbb-driverlicense.service.js";
import { KadastrCadnumService } from "../services/kadastr-cadnum.service.js";
import { MinfinPensionService } from "../services/minfin-pension.service.js";
import { LabourServicesService } from "../services/labour-services.service.js";
import { IhmaPovertyRegistryService } from "../services/ihma-poverty-registry.service.js";
import { MinvuzDiplomaService } from "../services/minvuz-diploma.service.js";
import { DtmCertificateService } from "../services/dtm-certificate.service.js";
import { DtmNostrificationService } from "../services/dtm-nostrification.service.js";

type ServiceConstructor = new (
  httpClient: HttpClient,
) => BaseIntegrationService;

const ALL_SERVICES: ServiceConstructor[] = [
  GcpDocrestService,
  GcpRestService,
  GcpBirthdaterestService,
  MvdAddressService,
  MvdEmamuriyService,
  MvdPersonProbationService,
  ConvictionsService,
  MibAlimonyService,
  MibDebtbanService,
  JusticeMigrationService,
  JusticeBirthService,
  JusticeMarriageService,
  JusticeDivorceService,
  JusticeDeathService,
  AdliyaFamilyCheckService,
  MinzdravNarkoService,
  MinzdravPsychoService,
  MinzdravVtekService,
  MinzdravMedcertService,
  SsvMedkartaService,
  GnkIndentreDebtService,
  GnkLegalentityDebtService,
  GnkSelfemployedService,
  GnkYattService,
  YhxbbCarinfoService,
  YhxbbDriverlicenseService,
  KadastrCadnumService,
  MinfinPensionService,
  LabourServicesService,
  IhmaPovertyRegistryService,
  MinvuzDiplomaService,
  DtmCertificateService,
  DtmNostrificationService,
];

export class IntegrationFactory {
  private registry: IntegrationRegistry;
  private httpClient: HttpClient;

  constructor(httpClient?: HttpClient) {
    this.httpClient = httpClient ?? new HttpClient();
    this.registry = new IntegrationRegistry();
    this.registerAll();
  }

  private registerAll(): void {
    for (const ServiceClass of ALL_SERVICES) {
      const instance = new ServiceClass(this.httpClient);
      this.registry.register(instance);
    }
  }

  getRegistry(): IntegrationRegistry {
    return this.registry;
  }

  getHttpClient(): HttpClient {
    return this.httpClient;
  }
}
