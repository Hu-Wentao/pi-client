import { realpath } from "node:fs/promises";

import {
  hasTrustRequiringProjectResources,
  ProjectTrustStore,
} from "@earendil-works/pi-coding-agent";

const authorizationBrand: unique symbol = Symbol("ProjectTrustAuthorization");

export type ProjectTrustDecision = "trust" | "deny" | "undecided";
export type ProjectTrustSource = "not-required" | "saved" | "decision-provider";

export interface ProjectTrustRequest {
  readonly cwd: string;
  readonly agentDir: string;
  readonly hasProtectedProjectResources: boolean;
}

export type ProjectTrustDecisionProvider = (
  request: ProjectTrustRequest,
) => ProjectTrustDecision | Promise<ProjectTrustDecision>;

export interface ProjectTrustBackend {
  hasProtectedProjectResources(cwd: string): boolean | Promise<boolean>;
  readSavedDecision(cwd: string, agentDir: string): boolean | null | Promise<boolean | null>;
}

export interface ProjectTrustAuthorization {
  readonly [authorizationBrand]: true;
  readonly cwd: string;
  readonly projectResourcesAllowed: boolean;
  readonly source: ProjectTrustSource;
}

export type ProjectTrustErrorCode =
  | "project-authorization-invalid"
  | "project-path-invalid"
  | "project-trust-denied"
  | "project-trust-unresolved"
  | "project-trust-resolution-failed";

export class ProjectTrustError extends Error {
  constructor(
    readonly code: ProjectTrustErrorCode,
    message: string,
    options?: ErrorOptions,
  ) {
    super(message, options);
    this.name = "ProjectTrustError";
  }
}

export function assertProjectTrustAuthorization(
  value: ProjectTrustAuthorization,
): asserts value is ProjectTrustAuthorization {
  const candidate = value as unknown as Record<PropertyKey, unknown>;
  if (typeof value !== "object" || value === null || candidate[authorizationBrand] !== true) {
    throw new ProjectTrustError(
      "project-authorization-invalid",
      "Project resource loading requires an authorization issued by ProjectTrustCoordinator.",
    );
  }
}

export class PublicPiSdkProjectTrustBackend implements ProjectTrustBackend {
  hasProtectedProjectResources(cwd: string): boolean {
    return hasTrustRequiringProjectResources(cwd);
  }

  readSavedDecision(cwd: string, agentDir: string): boolean | null {
    return new ProjectTrustStore(agentDir).get(cwd);
  }
}

export interface ProjectTrustCoordinatorOptions {
  readonly backend?: ProjectTrustBackend;
  readonly decisionProvider?: ProjectTrustDecisionProvider;
  readonly canonicalizePath?: (cwd: string) => string | Promise<string>;
}

export class ProjectTrustCoordinator {
  readonly #backend: ProjectTrustBackend;
  readonly #decisionProvider: ProjectTrustDecisionProvider | undefined;
  readonly #canonicalizePath: (cwd: string) => string | Promise<string>;

  constructor(options: ProjectTrustCoordinatorOptions = {}) {
    this.#backend = options.backend ?? new PublicPiSdkProjectTrustBackend();
    this.#decisionProvider = options.decisionProvider;
    this.#canonicalizePath = options.canonicalizePath ?? realpath;
  }

  async authorize(input: {
    readonly cwd: string;
    readonly agentDir: string;
  }): Promise<ProjectTrustAuthorization> {
    let cwd: string;
    try {
      cwd = await this.#canonicalizePath(input.cwd);
    } catch (error) {
      throw new ProjectTrustError(
        "project-path-invalid",
        "The project path could not be canonicalized.",
        { cause: error },
      );
    }

    let hasProtectedProjectResources: boolean;
    try {
      hasProtectedProjectResources = await this.#backend.hasProtectedProjectResources(cwd);
    } catch (error) {
      throw new ProjectTrustError(
        "project-trust-resolution-failed",
        "Protected project resources could not be inspected.",
        { cause: error },
      );
    }

    if (!hasProtectedProjectResources) {
      return this.#createAuthorization(cwd, false, "not-required");
    }

    let savedDecision: boolean | null;
    try {
      savedDecision = await this.#backend.readSavedDecision(cwd, input.agentDir);
    } catch (error) {
      throw new ProjectTrustError(
        "project-trust-resolution-failed",
        "Saved project trust could not be read.",
        { cause: error },
      );
    }

    if (savedDecision === true) {
      return this.#createAuthorization(cwd, true, "saved");
    }
    if (savedDecision === false) {
      throw new ProjectTrustError(
        "project-trust-denied",
        "Protected project resources are not trusted.",
      );
    }
    if (!this.#decisionProvider) {
      throw new ProjectTrustError(
        "project-trust-unresolved",
        "Protected project resources require an explicit trust decision.",
      );
    }

    let decision: ProjectTrustDecision;
    try {
      decision = await this.#decisionProvider({
        cwd,
        agentDir: input.agentDir,
        hasProtectedProjectResources,
      });
    } catch (error) {
      throw new ProjectTrustError(
        "project-trust-resolution-failed",
        "The project trust decision provider failed.",
        { cause: error },
      );
    }

    if (decision === "trust") {
      return this.#createAuthorization(cwd, true, "decision-provider");
    }
    if (decision === "deny") {
      throw new ProjectTrustError(
        "project-trust-denied",
        "Protected project resources are not trusted.",
      );
    }

    throw new ProjectTrustError(
      "project-trust-unresolved",
      "Protected project resources require an explicit trust decision.",
    );
  }

  #createAuthorization(
    cwd: string,
    projectResourcesAllowed: boolean,
    source: ProjectTrustSource,
  ): ProjectTrustAuthorization {
    return Object.freeze({
      [authorizationBrand]: true as const,
      cwd,
      projectResourcesAllowed,
      source,
    });
  }
}
