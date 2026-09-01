import type {
  PiNodeAbortResult,
  PiNodeDirectoryListing,
  PiNodeKnownProjectSnapshot,
  PiNodeMessageContent,
  PiNodeMessageContentRequest,
  PiNodeProjectBootstrap,
  PiNodeProjectSnapshot,
  PiNodePromptAdmission,
  PiNodeSessionDeleteConfirmation,
  PiNodeSessionDeleteResult,
  PiNodeSessionEvent,
  PiNodeSessionEventListener,
  PiNodeSessionExportFormat,
  PiNodeSessionHistoryPage,
  PiNodeSessionSnapshot,
  PiNodeSessionStats,
  PiNodeSessionSummary,
  PiNodeSessionTreeMutationResult,
  PiNodeSessionTreeSnapshot,
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
  getSessionHistory(input: {
    readonly cwd: string;
    readonly sessionId: string;
    readonly cursor?: string;
    readonly limit: number;
    readonly expectedActiveBranchRevision?: string;
    readonly expectedTreeRevision?: string;
  }): Promise<PiNodeSessionHistoryPage>;
  getMessageContent(input: {
    readonly cwd: string;
    readonly request: PiNodeMessageContentRequest;
  }): Promise<PiNodeMessageContent>;
  getSessionStats(input: {
    readonly cwd: string;
    readonly sessionId: string;
  }): Promise<PiNodeSessionStats>;
  exportSession(input: {
    readonly cwd: string;
    readonly sessionId: string;
    readonly format: PiNodeSessionExportFormat;
    readonly outputPath: string;
    readonly expectedActiveBranchRevision?: string;
    readonly expectedTreeRevision?: string;
  }): Promise<void>;
  getSessionTree(input: {
    readonly cwd: string;
    readonly sessionId: string;
  }): Promise<PiNodeSessionTreeSnapshot>;
  navigateSessionTree(input: {
    readonly cwd: string;
    readonly sessionId: string;
    readonly entryId: string;
    readonly expectedAdminRevision: string;
  }): Promise<PiNodeSessionTreeMutationResult>;
  forkSession(input: {
    readonly cwd: string;
    readonly sessionId: string;
    readonly userEntryId: string;
    readonly expectedAdminRevision: string;
  }): Promise<PiNodeSessionTreeMutationResult>;
  cloneSession(input: {
    readonly cwd: string;
    readonly sessionId: string;
    readonly expectedAdminRevision: string;
  }): Promise<PiNodeSessionTreeMutationResult>;
  observeSession(sessionId: string, listener: PiNodeSessionEventListener): PiNodeSessionObservation;
  submitPrompt(input: {
    readonly sessionId: string;
    readonly commandId: string;
    readonly text: string;
  }): Promise<PiNodePromptAdmission>;
  abort(input: { readonly sessionId: string }): Promise<PiNodeAbortResult>;
  renameSession(input: {
    readonly cwd: string;
    readonly sessionId: string;
    readonly name: string;
  }): Promise<PiNodeSessionSummary>;
  clearSessionName(input: {
    readonly cwd: string;
    readonly sessionId: string;
  }): Promise<PiNodeSessionSummary>;
  autoNameSession(input: {
    readonly cwd: string;
    readonly sessionId: string;
    readonly timeoutMillis: number;
    readonly signal?: AbortSignal;
  }): Promise<PiNodeSessionSummary>;
  deleteSession(input: {
    readonly cwd: string;
    readonly sessionId: string;
    readonly confirmation: PiNodeSessionDeleteConfirmation;
  }): Promise<PiNodeSessionDeleteResult>;
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

  async getSessionHistory(input: {
    readonly cwd: string;
    readonly sessionId: string;
    readonly cursor?: string;
    readonly limit: number;
    readonly expectedActiveBranchRevision?: string;
    readonly expectedTreeRevision?: string;
  }): Promise<PiNodeSessionHistoryPage> {
    await this.domainService.loadSessionSnapshot(input);
    return this.domainService.getLoadedSessionHistory(input);
  }

  async getMessageContent(input: {
    readonly cwd: string;
    readonly request: PiNodeMessageContentRequest;
  }): Promise<PiNodeMessageContent> {
    await this.domainService.loadSessionSnapshot({
      cwd: input.cwd,
      sessionId: input.request.binding.sessionId,
    });
    return this.domainService.getLoadedMessageContent(input.request);
  }

  async getSessionStats(input: {
    readonly cwd: string;
    readonly sessionId: string;
  }): Promise<PiNodeSessionStats> {
    await this.domainService.loadSessionSnapshot(input);
    return this.domainService.getLoadedSessionStats(input);
  }

  async exportSession(input: {
    readonly cwd: string;
    readonly sessionId: string;
    readonly format: PiNodeSessionExportFormat;
    readonly outputPath: string;
    readonly expectedActiveBranchRevision?: string;
    readonly expectedTreeRevision?: string;
  }): Promise<void> {
    await this.domainService.loadSessionSnapshot(input);
    await this.domainService.exportLoadedSession(input);
  }

  getSessionTree(input: {
    readonly cwd: string;
    readonly sessionId: string;
  }): Promise<PiNodeSessionTreeSnapshot> {
    return this.domainService.getLoadedSessionTree(input);
  }

  navigateSessionTree(input: {
    readonly cwd: string;
    readonly sessionId: string;
    readonly entryId: string;
    readonly expectedAdminRevision: string;
  }): Promise<PiNodeSessionTreeMutationResult> {
    return this.domainService.navigateSessionTree(input);
  }

  forkSession(input: {
    readonly cwd: string;
    readonly sessionId: string;
    readonly userEntryId: string;
    readonly expectedAdminRevision: string;
  }): Promise<PiNodeSessionTreeMutationResult> {
    return this.domainService.forkSessionFromUserEntry(input);
  }

  cloneSession(input: {
    readonly cwd: string;
    readonly sessionId: string;
    readonly expectedAdminRevision: string;
  }): Promise<PiNodeSessionTreeMutationResult> {
    return this.domainService.cloneSessionActiveBranch(input);
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

  renameSession(input: {
    readonly cwd: string;
    readonly sessionId: string;
    readonly name: string;
  }): Promise<PiNodeSessionSummary> {
    return this.domainService.renamePersistentSession(input);
  }

  clearSessionName(input: {
    readonly cwd: string;
    readonly sessionId: string;
  }): Promise<PiNodeSessionSummary> {
    return this.domainService.clearPersistentSessionName(input);
  }

  autoNameSession(input: {
    readonly cwd: string;
    readonly sessionId: string;
    readonly timeoutMillis: number;
    readonly signal?: AbortSignal;
  }): Promise<PiNodeSessionSummary> {
    return this.domainService.autoNamePersistentSession(input);
  }

  deleteSession(input: {
    readonly cwd: string;
    readonly sessionId: string;
    readonly confirmation: PiNodeSessionDeleteConfirmation;
  }): Promise<PiNodeSessionDeleteResult> {
    return this.domainService.deletePersistentSession(input);
  }
}
