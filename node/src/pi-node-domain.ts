import type { ProjectTrustAuthorization } from "./project-trust.js";

export type PiNodeJsonValue =
  | null
  | boolean
  | number
  | string
  | readonly PiNodeJsonValue[]
  | { readonly [key: string]: PiNodeJsonValue };

export type PiNodeMessageRole = "user" | "assistant" | "tool" | "custom";
export type PiNodeMessagePhase = "started" | "updated" | "completed";

export type PiNodeMessagePart =
  | {
      readonly type: "text";
      readonly text: string;
    }
  | {
      readonly type: "thinking";
      readonly text: string;
      readonly redacted: boolean;
    }
  | {
      readonly type: "image";
      readonly mimeType: string;
      readonly data: string;
    }
  | {
      readonly type: "tool-call";
      readonly id: string;
      readonly name: string;
      readonly arguments: PiNodeJsonValue;
    }
  | {
      readonly type: "unsupported";
      readonly sourceType: string;
    };

export interface PiNodeMessageUsage {
  readonly inputTokens: number;
  readonly outputTokens: number;
  readonly cacheReadTokens: number;
  readonly cacheWriteTokens: number;
  readonly totalTokens: number;
  readonly totalCost: number;
}

export interface PiNodeMessage {
  readonly id: string;
  readonly role: PiNodeMessageRole;
  readonly sourceRole: string;
  readonly timestampMs: number;
  readonly parts: readonly PiNodeMessagePart[];
  readonly assistant?: {
    readonly provider: string;
    readonly model: string;
    readonly stopReason: string;
    readonly errorMessage?: string;
    readonly usage?: PiNodeMessageUsage;
  };
  readonly tool?: {
    readonly callId: string;
    readonly name: string;
    readonly isError: boolean;
  };
}

export interface PiNodeSessionSummary {
  readonly sessionId: string;
  readonly cwd: string;
  readonly name?: string;
  readonly createdAtMs: number;
  readonly modifiedAtMs: number;
  readonly messageCount: number;
  readonly firstMessage: string;
  readonly running: boolean;
  readonly adminRevision: string;
}

export interface PiNodeSessionSnapshot extends PiNodeSessionSummary {
  readonly persistence: "persistent";
  readonly messages: readonly PiNodeMessage[];
  readonly lastEventSequence: number;
}

export type PiNodeCommandFailureCode =
  | "invalid-prompt"
  | "session-busy"
  | "model-unavailable"
  | "provider-auth-required"
  | "prompt-rejected"
  | "runtime-failed"
  | "aborted";

export interface PiNodeCommandFailure {
  readonly code: PiNodeCommandFailureCode;
  readonly message: string;
}

export type PiNodePromptAdmissionStatus = "accepted" | "rejected" | "uncertain";

export interface PiNodePromptAdmission {
  readonly sessionId: string;
  readonly commandId: string;
  readonly status: PiNodePromptAdmissionStatus;
  readonly failure?: PiNodeCommandFailure;
}

export interface PiNodeCommandCompletion {
  readonly outcome: "succeeded" | "failed" | "aborted";
  readonly failure?: PiNodeCommandFailure;
}

export type PiNodeAbortResult =
  | {
      readonly status: "not-running";
      readonly sessionId: string;
    }
  | {
      readonly status: "requested";
      readonly sessionId: string;
      readonly commandId?: string;
    };

export interface PiNodeEventBase {
  readonly sessionId: string;
  readonly sequence: number;
  readonly emittedAtMs: number;
}

export type PiNodeSessionEvent =
  | (PiNodeEventBase & {
      readonly type: "message";
      readonly phase: PiNodeMessagePhase;
      readonly message: PiNodeMessage;
    })
  | (PiNodeEventBase & {
      readonly type: "running";
      readonly running: boolean;
      readonly commandId?: string;
    })
  | (PiNodeEventBase & {
      readonly type: "command-completed";
      readonly commandId: string;
      readonly outcome: "succeeded" | "failed" | "aborted" | "rejected";
      readonly failure?: PiNodeCommandFailure;
    });

export type PiNodeSessionEventListener = (event: PiNodeSessionEvent) => void;

export type PiNodeProjectTrustStatus = "not-required" | "trusted" | "approval-required" | "denied";

export type PiNodeProjectTrustReason =
  | "pi-settings"
  | "pi-extensions"
  | "pi-skills"
  | "pi-prompts"
  | "pi-themes"
  | "pi-system-prompt"
  | "agent-skills"
  | "saved-approval"
  | "saved-denial";

export interface PiNodeProjectTrustSnapshot {
  readonly status: PiNodeProjectTrustStatus;
  readonly reasons: readonly PiNodeProjectTrustReason[];
  readonly revision: string;
}

export interface PiNodeProjectIdentity {
  readonly projectId: string;
  readonly canonicalCwd: string;
  readonly isGitRepository: boolean;
  readonly gitRoot?: string;
  readonly mainWorktreeRoot?: string;
  readonly branch?: string;
  readonly isLinkedWorktree: boolean;
  readonly isDetachedHead: boolean;
  readonly worktreeId: string;
  readonly mainProjectId: string;
}

export interface PiNodeProjectSnapshot {
  readonly identity: PiNodeProjectIdentity;
  readonly trust: PiNodeProjectTrustSnapshot;
}

export interface PiNodeKnownProjectSnapshot {
  readonly project: PiNodeProjectSnapshot;
  readonly lastSessionAtMs: number;
  readonly sessionCount: number;
}

export interface PiNodeDirectoryEntry {
  readonly name: string;
  readonly canonicalPath: string;
  readonly isSymbolicLink: boolean;
}

export interface PiNodeDirectoryListing {
  readonly canonicalDirectory: string;
  readonly parentDirectory?: string;
  readonly children: readonly PiNodeDirectoryEntry[];
  readonly truncated: boolean;
}

export interface PiNodeProjectBootstrap {
  readonly homeDirectory: string;
  readonly defaultProject: PiNodeProjectSnapshot;
}

export type PiNodeSessionBackendEvent =
  | {
      readonly type: "message";
      readonly phase: PiNodeMessagePhase;
      readonly message: PiNodeMessage;
    }
  | {
      readonly type: "running";
      readonly running: boolean;
    };

export interface PiNodeSessionBackendSnapshot extends PiNodeSessionSummary {
  readonly persistence: "persistent";
  readonly messages: readonly PiNodeMessage[];
}

export interface PiNodePromptExecution {
  readonly admission: {
    readonly status: PiNodePromptAdmissionStatus;
    readonly failure?: PiNodeCommandFailure;
  };
  readonly completion: Promise<PiNodeCommandCompletion>;
}

export interface PiNodeDomainSessionBackend {
  readonly sessionId: string;
  readonly cwd: string;
  readonly persistence: "persistent";
  readonly isRunning: boolean;
  getSnapshot(): PiNodeSessionBackendSnapshot;
  subscribe(listener: (event: PiNodeSessionBackendEvent) => void): () => void;
  startPrompt(input: { readonly text: string }): Promise<PiNodePromptExecution>;
  abort(): Promise<boolean>;
  dispose(): Promise<void>;
}

export interface PiNodeSessionDeleteConfirmation {
  readonly sessionId: string;
  readonly adminRevision: string;
  readonly displayedTitle: string;
  readonly destructiveActionAcknowledged: boolean;
}

export interface PiNodeSessionDeleteResult {
  readonly sessionId: string;
  readonly reparentedChildCount: number;
}

export interface PiNodeSessionAdministrationBackend {
  renamePersistentSession(input: {
    readonly authorization: ProjectTrustAuthorization;
    readonly agentDir: string;
    readonly sessionId: string;
    readonly name: string;
  }): Promise<PiNodeSessionSummary>;
  clearPersistentSessionName(input: {
    readonly authorization: ProjectTrustAuthorization;
    readonly agentDir: string;
    readonly sessionId: string;
  }): Promise<PiNodeSessionSummary>;
  autoNamePersistentSession(input: {
    readonly authorization: ProjectTrustAuthorization;
    readonly agentDir: string;
    readonly sessionId: string;
    readonly timeoutMillis: number;
    readonly signal?: AbortSignal;
  }): Promise<PiNodeSessionSummary>;
  deletePersistentSession(input: {
    readonly authorization: ProjectTrustAuthorization;
    readonly agentDir: string;
    readonly sessionId: string;
    readonly confirmation: PiNodeSessionDeleteConfirmation;
  }): Promise<PiNodeSessionDeleteResult>;
}

export interface PiNodeDomainSessionBackendFactory extends PiNodeSessionAdministrationBackend {
  listPersistentSessions(input: {
    readonly authorization: ProjectTrustAuthorization;
    readonly agentDir: string;
  }): Promise<readonly PiNodeSessionSummary[]>;
  createPersistentSession(input: {
    readonly authorization: ProjectTrustAuthorization;
    readonly agentDir: string;
  }): Promise<PiNodeDomainSessionBackend>;
  openPersistentSession(input: {
    readonly authorization: ProjectTrustAuthorization;
    readonly agentDir: string;
    readonly sessionId: string;
  }): Promise<PiNodeDomainSessionBackend>;
}

export type PiNodeDomainErrorCode =
  | "service-disposed"
  | "invalid-project-path"
  | "project-not-registered"
  | "project-trust-revision-stale"
  | "project-browse-failed"
  | "project-validation-failed"
  | "project-list-failed"
  | "project-trust-persist-failed"
  | "project-trust-denied"
  | "project-trust-unresolved"
  | "project-trust-resolution-failed"
  | "session-not-found"
  | "session-not-loaded"
  | "session-owned"
  | "session-capacity-exceeded"
  | "session-list-failed"
  | "session-create-failed"
  | "session-load-failed"
  | "session-dispose-failed"
  | "session-admin-invalid-name"
  | "session-admin-confirmation-required"
  | "session-admin-conflict"
  | "session-admin-locked"
  | "session-admin-failed"
  | "session-auto-name-model-unavailable"
  | "session-auto-name-provider-auth-required"
  | "session-auto-name-timeout"
  | "session-auto-name-cancelled"
  | "session-auto-name-failed"
  | "abort-failed";

export class PiNodeDomainError extends Error {
  constructor(
    readonly code: PiNodeDomainErrorCode,
    message: string,
    options?: ErrorOptions,
  ) {
    super(message, options);
    this.name = "PiNodeDomainError";
  }
}
