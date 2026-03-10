import type { BaseIntegrationService } from "./base-integration.service.js";

export class IntegrationRegistry {
  private services = new Map<string, BaseIntegrationService>();

  register(service: BaseIntegrationService): void {
    const meta = service.getMeta();
    for (const methodName of meta.supportedMethods) {
      if (this.services.has(methodName)) {
        throw new Error(
          `Duplicate registration: methodName "${methodName}" is already registered`,
        );
      }
      this.services.set(methodName, service);
    }
  }

  resolve(methodName: string): BaseIntegrationService | undefined {
    return this.services.get(methodName);
  }

  getRegisteredMethods(): string[] {
    return Array.from(this.services.keys());
  }

  getAllServices(): BaseIntegrationService[] {
    return [...new Set(this.services.values())];
  }
}
