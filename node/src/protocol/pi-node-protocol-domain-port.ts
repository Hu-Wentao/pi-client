import type {
  PiNodeAbortResult,
  PiNodeDirectoryListing,
  PiNodeKnownProjectSnapshot,
  PiNodeProjectBootstrap,
  PiNodeProjectSnapshot,
  PiNodePromptAdmission,
  PiNodeSessionEvent,
  PiNodeSessionEventListener,
  PiNodeSessionSnapshot,
  PiNodeSessionSummary,
} from "../pi-node-domain.js";
import type { PiNodeDomainService, PiNodeSessionObservation } from "../pi-node-domain-service.js";

export interface PiNodeProtocolDomain {
  getProjectBootstrap(): Promise<PiNodeProjectBootstrap>;
  browseDirectory(input: {
    readonly directory: string;
    readonly maxChildren: number;
  }): Promise<PiNodeDirectoryListing>;
  validateProject(input: { readonly candidateDirectory: string }): Promise<PiNodeProjectSnapshot>;
  listKnownProjects(input: {
    readonly maxProjects: number;
  }): Promise<readonly PiNodeKnownProjectSnapshot[]>;
  approveProjectTrust(input: {
    readonly canonicalCwd: string;
    readonly trustRevision: string;
  }): Promise<PiNodeProjectSnapshot>;
  listSessions(input: { readonly cwd: string }): Promise<readonly PiNodeSessionSummary[]>;
  getSession(input: {
    readonly cwd: string;
    readonly sessionId: string;
  }): Promise<PiNodeSessionSnapshot>;
  createSession(input: { readonly cwd: string }): Promise<PiNodeSessionSnapshot>;
  observeSession(sessionId: string, listener: PiNodeSessionEventListener): PiNodeSessionObservation;
  submitPrompt(input: {
    readonly sessionId: string;
    readonly commandId: string;
    readonly text: string;
  }): Promise<PiNodePromptAdmission>;
  abort(input: { readonly sessionId: string }): Promise<PiNodeAbortResult>;
}

/** Keeps the Protobuf wire coordinator dependent on a narrow Pi Client-owned port. */
export class PiNodeDomainServiceProtocolAdapter implements PiNodeProtocolDomain {
  constructor(readonly domainService: PiNodeDomainService) {}

  getProjectBootstrap(): Promise<PiNodeProjectBootstrap> {
    return this.domainService.getProjectBootstrap();
  }

  browseDirectory(input: {
    readonly directory: string;
    readonly maxChildren: number;
  }): Promise<PiNodeDirectoryListing> {
    return this.domainService.browseProjectDirectory(input);
  }

  validateProject(input: { readonly candidateDirectory: string }): Promise<PiNodeProjectSnapshot> {
    return this.domainService.validateProject(input);
  }

  listKnownProjects(input: {
    readonly maxProjects: number;
  }): Promise<readonly PiNodeKnownProjectSnapshot[]> {
    return this.domainService.listKnownProjects(input);
  }

  approveProjectTrust(input: {
    readonly canonicalCwd: string;
    readonly trustRevision: string;
  }): Promise<PiNodeProjectSnapshot> {
    return this.domainService.approveProjectTrust(input);
  }

  listSessions(input: { readonly cwd: string }): Promise<readonly PiNodeSessionSummary[]> {
    return this.domainService.listPersistentSessions(input);
  }

  getSession(input: {
    readonly cwd: string;
    readonly sessionId: string;
  }): Promise<PiNodeSessionSnapshot> {
    return this.domainService.loadSessionSnapshot(input);
  }

  createSession(input: { readonly cwd: string }): Promise<PiNodeSessionSnapshot> {
    return this.domainService.createPersistentSession(input);
  }

  observeSession(
    sessionId: string,
    listener: (event: PiNodeSessionEvent) => void,
  ): PiNodeSessionObservation {
    return this.domainService.observeSession(sessionId, listener);
  }

  submitPrompt(input: {
    readonly sessionId: string;
    readonly commandId: string;
    readonly text: string;
  }): Promise<PiNodePromptAdmission> {
    return this.domainService.submitPrompt(input);
  }

  abort(input: { readonly sessionId: string }): Promise<PiNodeAbortResult> {
    return this.domainService.abortActiveRun(input);
  }
}
