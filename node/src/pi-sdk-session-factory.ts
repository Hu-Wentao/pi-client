import {
  type AgentSession,
  createAgentSessionFromServices,
  createAgentSessionServices,
  SessionManager,
  SettingsManager,
} from "@earendil-works/pi-coding-agent";

import {
  assertProjectTrustAuthorization,
  type ProjectTrustAuthorization,
} from "./project-trust.js";
import { assertRuntimeCompatibility } from "./runtime-metadata.js";

export interface PiSdkDiagnosticCounts {
  readonly info: number;
  readonly warning: number;
  readonly error: number;
}

export interface PiSdkSessionHandle {
  readonly cwd: string;
  readonly sessionId: string;
  readonly persistence: "memory";
  readonly projectResourcesLoaded: boolean;
  readonly diagnosticCounts: PiSdkDiagnosticCounts;
  dispose(): Promise<void>;
}

export interface PiSdkRuntimeSessionFactory {
  create(input: {
    readonly authorization: ProjectTrustAuthorization;
    readonly agentDir: string;
  }): Promise<PiSdkSessionHandle>;
}

function countDiagnostics(
  diagnostics: ReadonlyArray<{ readonly type: "info" | "warning" | "error" }>,
): PiSdkDiagnosticCounts {
  const counts = { info: 0, warning: 0, error: 0 };
  for (const diagnostic of diagnostics) {
    counts[diagnostic.type] += 1;
  }
  return Object.freeze(counts);
}

class PublicPiSdkSessionHandle implements PiSdkSessionHandle {
  readonly persistence = "memory" as const;
  readonly #session: AgentSession;
  readonly #settingsManager: SettingsManager;
  #disposePromise: Promise<void> | undefined;

  constructor(
    readonly cwd: string,
    readonly sessionId: string,
    readonly projectResourcesLoaded: boolean,
    readonly diagnosticCounts: PiSdkDiagnosticCounts,
    session: AgentSession,
    settingsManager: SettingsManager,
  ) {
    this.#session = session;
    this.#settingsManager = settingsManager;
  }

  dispose(): Promise<void> {
    this.#disposePromise ??= this.#disposeOnce();
    return this.#disposePromise;
  }

  async #disposeOnce(): Promise<void> {
    const errors: unknown[] = [];

    if (!this.#session.isIdle) {
      try {
        await this.#session.abort();
      } catch (error) {
        errors.push(error);
      }
    }

    try {
      this.#session.dispose();
    } catch (error) {
      errors.push(error);
    }

    try {
      await this.#settingsManager.flush();
    } catch (error) {
      errors.push(error);
    }

    for (const settingsError of this.#settingsManager.drainErrors()) {
      errors.push(settingsError.error);
    }

    if (errors.length > 0) {
      throw new AggregateError(errors, "Pi SDK session disposal failed.");
    }
  }
}

export class PublicPiSdkRuntimeSessionFactory implements PiSdkRuntimeSessionFactory {
  async create(input: {
    readonly authorization: ProjectTrustAuthorization;
    readonly agentDir: string;
  }): Promise<PiSdkSessionHandle> {
    assertRuntimeCompatibility();
    assertProjectTrustAuthorization(input.authorization);

    const { authorization, agentDir } = input;
    const settingsManager = SettingsManager.create(authorization.cwd, agentDir, {
      projectTrusted: authorization.projectResourcesAllowed,
    });
    let session: AgentSession | undefined;

    try {
      const services = await createAgentSessionServices({
        cwd: authorization.cwd,
        agentDir,
        settingsManager,
        resourceLoaderOptions: {
          noContextFiles: !authorization.projectResourcesAllowed,
        },
      });
      const result = await createAgentSessionFromServices({
        services,
        sessionManager: SessionManager.inMemory(authorization.cwd),
        noTools: "all",
      });
      session = result.session;

      return new PublicPiSdkSessionHandle(
        authorization.cwd,
        session.sessionId,
        authorization.projectResourcesAllowed,
        countDiagnostics(services.diagnostics),
        session,
        settingsManager,
      );
    } catch (error) {
      session?.dispose();
      await settingsManager.flush();
      throw error;
    }
  }
}
