import type { PiSdkRuntimeSessionFactory, PiSdkSessionHandle } from "./pi-sdk-session-factory.js";
import {
  ProjectTrustCoordinator,
  ProjectTrustError,
  type ProjectTrustSource,
} from "./project-trust.js";
import {
  assertRuntimeCompatibility,
  getRuntimeMetadata,
  RuntimeCompatibilityError,
  type PiNodeRuntimeMetadata,
} from "./runtime-metadata.js";

export type PiNodeLifecycleState =
  | "created"
  | "starting"
  | "ready"
  | "stopping"
  | "stopped"
  | "failed";

export type PiNodeFailureCode =
  | "runtime-incompatible"
  | "project-authorization-invalid"
  | "project-path-invalid"
  | "project-trust-denied"
  | "project-trust-unresolved"
  | "project-trust-resolution-failed"
  | "session-start-failed"
  | "session-disposal-failed";

export interface PiNodeHealth {
  readonly state: PiNodeLifecycleState;
  readonly healthy: boolean;
  readonly observedAtMs: number;
  readonly launchRequestedAtMs?: number;
  readonly readyAtMs?: number;
  readonly stoppedAtMs?: number;
  readonly uptimeMs: number;
  readonly runtime: PiNodeRuntimeMetadata;
  readonly projectResourceAccess: "pending" | "restricted" | "trusted";
  readonly trustSource?: ProjectTrustSource;
  readonly session: {
    readonly active: boolean;
    readonly persistence: "none" | "memory";
  };
  readonly failure?: {
    readonly code: PiNodeFailureCode;
  };
}

export interface PiNodeCapabilities {
  readonly sdkEmbedding: true;
  readonly piSdkVersion: string;
  readonly projectTrustGate: "fail-closed";
  readonly projectResourceModes: readonly ["restricted", "trusted"];
  readonly sessionLifecycle: "single-active-session";
  readonly sessionPersistence: "memory-only";
  readonly deterministicDisposal: true;
  readonly providerCredentialsRequiredForStartup: false;
  readonly providerNetworkRequiredForHealth: false;
  readonly wireProtocol: "not-defined";
}

export class PiNodeLifecycleError extends Error {
  readonly code = "invalid-lifecycle-transition";

  constructor(message: string) {
    super(message);
    this.name = "PiNodeLifecycleError";
  }
}

export interface PiNodeRuntimeOptions {
  readonly cwd: string;
  readonly agentDir: string;
  readonly trustCoordinator: ProjectTrustCoordinator;
  readonly sessionFactory: PiSdkRuntimeSessionFactory;
  readonly clock?: () => number;
}

export class PiNodeRuntime {
  readonly #cwd: string;
  readonly #agentDir: string;
  readonly #trustCoordinator: ProjectTrustCoordinator;
  readonly #sessionFactory: PiSdkRuntimeSessionFactory;
  readonly #clock: () => number;
  readonly #runtimeMetadata: PiNodeRuntimeMetadata;

  #state: PiNodeLifecycleState = "created";
  #session: PiSdkSessionHandle | undefined;
  #startPromise: Promise<void> | undefined;
  #stopPromise: Promise<void> | undefined;
  #launchRequestedAtMs: number | undefined;
  #readyAtMs: number | undefined;
  #stoppedAtMs: number | undefined;
  #projectResourceAccess: "pending" | "restricted" | "trusted" = "pending";
  #trustSource: ProjectTrustSource | undefined;
  #failureCode: PiNodeFailureCode | undefined;

  constructor(options: PiNodeRuntimeOptions) {
    this.#cwd = options.cwd;
    this.#agentDir = options.agentDir;
    this.#trustCoordinator = options.trustCoordinator;
    this.#sessionFactory = options.sessionFactory;
    this.#clock = options.clock ?? Date.now;
    this.#runtimeMetadata = getRuntimeMetadata();
  }

  get state(): PiNodeLifecycleState {
    return this.#state;
  }

  start(): Promise<void> {
    if ((this.#state === "starting" || this.#state === "ready") && this.#startPromise) {
      return this.#startPromise;
    }
    if (this.#state !== "created") {
      throw new PiNodeLifecycleError(`Cannot start Pi Node from state ${this.#state}.`);
    }

    assertRuntimeCompatibility();
    this.#state = "starting";
    this.#launchRequestedAtMs = this.#clock();
    this.#startPromise = this.#startOnce();
    return this.#startPromise;
  }

  async #startOnce(): Promise<void> {
    try {
      const authorization = await this.#trustCoordinator.authorize({
        cwd: this.#cwd,
        agentDir: this.#agentDir,
      });
      this.#projectResourceAccess = authorization.projectResourcesAllowed
        ? "trusted"
        : "restricted";
      this.#trustSource = authorization.source;
      this.#session = await this.#sessionFactory.create({
        authorization,
        agentDir: this.#agentDir,
      });
      this.#readyAtMs = this.#clock();
      this.#state = "ready";
    } catch (error) {
      this.#failureCode = mapFailureCode(error, "session-start-failed");
      this.#state = "failed";
      throw error;
    }
  }

  stop(): Promise<void> {
    this.#stopPromise ??= this.#stopOnce();
    return this.#stopPromise;
  }

  async #stopOnce(): Promise<void> {
    if (this.#state === "created") {
      this.#state = "stopped";
      this.#stoppedAtMs = this.#clock();
      return;
    }

    if (this.#startPromise) {
      try {
        await this.#startPromise;
      } catch {
        return;
      }
    }

    if (!this.#session) {
      return;
    }

    this.#state = "stopping";
    try {
      await this.#session.dispose();
      this.#session = undefined;
      this.#state = "stopped";
      this.#stoppedAtMs = this.#clock();
    } catch (error) {
      this.#failureCode = "session-disposal-failed";
      this.#state = "failed";
      throw error;
    }
  }

  dispose(): Promise<void> {
    return this.stop();
  }

  getHealth(): PiNodeHealth {
    const observedAtMs = this.#clock();
    const uptimeStart = this.#readyAtMs;
    const uptimeEnd = this.#stoppedAtMs ?? observedAtMs;
    const uptimeMs = uptimeStart === undefined ? 0 : Math.max(0, uptimeEnd - uptimeStart);

    return Object.freeze({
      state: this.#state,
      healthy: this.#state === "ready",
      observedAtMs,
      ...(this.#launchRequestedAtMs === undefined
        ? {}
        : { launchRequestedAtMs: this.#launchRequestedAtMs }),
      ...(this.#readyAtMs === undefined ? {} : { readyAtMs: this.#readyAtMs }),
      ...(this.#stoppedAtMs === undefined ? {} : { stoppedAtMs: this.#stoppedAtMs }),
      uptimeMs,
      runtime: this.#runtimeMetadata,
      projectResourceAccess: this.#projectResourceAccess,
      ...(this.#trustSource === undefined ? {} : { trustSource: this.#trustSource }),
      session: Object.freeze({
        active: this.#session !== undefined,
        persistence: this.#session?.persistence ?? "none",
      }),
      ...(this.#failureCode === undefined
        ? {}
        : { failure: Object.freeze({ code: this.#failureCode }) }),
    });
  }

  getCapabilities(): PiNodeCapabilities {
    return Object.freeze({
      sdkEmbedding: true,
      piSdkVersion: this.#runtimeMetadata.piSdkVersion,
      projectTrustGate: "fail-closed",
      projectResourceModes: Object.freeze(["restricted", "trusted"] as const),
      sessionLifecycle: "single-active-session",
      sessionPersistence: "memory-only",
      deterministicDisposal: true,
      providerCredentialsRequiredForStartup: false,
      providerNetworkRequiredForHealth: false,
      wireProtocol: "not-defined",
    });
  }
}

function mapFailureCode(error: unknown, fallback: PiNodeFailureCode): PiNodeFailureCode {
  if (error instanceof ProjectTrustError) {
    return error.code;
  }
  if (error instanceof RuntimeCompatibilityError) {
    return error.code;
  }
  return fallback;
}
