/// Figma:
/// - Frame: none
/// - Page Title: Pi Client
/// - Node: none
/// Figma Fidelity: excluded | no Figma design was supplied; the UI is an independent Flutter implementation over the first-party Pi Node boundary
/// Figma Data:
/// - none
/// State Ownership: page-owned [WorkspaceViewModel]
/// Public Views:
/// - [WorkspaceView] — typed Page primary View.
/// Widget Tree: [WorkspaceView] > [NodeConnectionView],
///   [ProjectBrowserView], [SessionBrowserView],
///   [BranchNavigatorView], [ConversationView] > [PiMessageBubble] × N,
///   [PromptComposerView],
///   [ProjectTrustDialog] (conditional)
/// Theme: material
/// Events: [WorkspaceStarted], [WorkspaceConnectionRetried],
///   [WorkspaceProjectDirectoryBrowsed], [WorkspaceProjectPathValidated],
///   [WorkspaceProjectSelected], [WorkspaceProjectTrustApproved],
///   [WorkspaceSessionsRefreshed], [WorkspaceSessionSelected],
///   [WorkspaceNewSessionRequested], [WorkspaceSessionRenamed],
///   [WorkspaceSessionCustomNameCleared], [WorkspaceSessionAutoNamed],
///   [WorkspaceSessionDeleted], [WorkspaceSessionTreeNavigated],
///   [WorkspaceSessionForked], [WorkspaceSessionCloned],
///   [WorkspaceOlderHistoryRequested], [WorkspaceSessionStatsRefreshed],
///   [WorkspaceSessionExportRequested], [WorkspaceSessionExportCancelled],
///   [WorkspacePromptSubmitted], [WorkspaceAgentStopped]
/// Startup Event: [WorkspaceStarted]
/// ViewModels: [WorkspaceViewModel]
/// Models: [WorkspaceModel]
/// Notes: The typed root route remains at `/`. [WorkspaceService] delegates
///   only to the app-owned [PiNodeApi], while [WorkspaceViewModel] owns typed
///   [PiSessionSummary], [PiMessage], and [PiSessionEvent] feature state and
///   subscriptions. Startup connects, resolves the Node-owned default project,
///   loads session-derived known projects, and lists the selected project's
///   sessions; directory browsing, manual-path validation, project selection,
///   explicit trust approval, refresh, session selection, creation, rename,
///   custom-name clearing, bounded model-assisted naming, confirmed deletion,
///   prompt admission, ordered events, sequence-gap recovery, abort, and clean
///   close remain observable. Flat session-tree loading, same-session branch
///   navigation, recoverable edit-from-here text, independent fork, active-branch
///   clone, runtime replacement, opaque-cursor history pagination with a
///   50-message initial tail, full-session statistics, streamed HTML/JSONL
///   export progress/cancellation, and authoritative history/tree refresh are
///   generation-guarded. Local-host, remote-node-required, unsupported,
///   empty, rejected, uncertain, disconnected, retry, and stale-result-safe
///   states never invent runtime data. Optimistic prompts are removed only for
///   definitive rejection and retained for uncertain admission. Synchronous
///   busy guards and operation/event generations prevent duplicate work and
///   stale emissions without an extra Bloc concurrency dependency.

part of 'workspace.dart';

enum WorkspaceEventStatus { idle, listening, recovering, error }

enum WorkspacePromptAdmissionStatus { idle, accepted, rejected, uncertain }

@FrState
abstract class WorkspaceModel with _$WorkspaceModel {
  const factory WorkspaceModel({
    @JsonKey(includeToJson: false)
    @Default(PiNodeConnectionSnapshot.disconnected())
    PiNodeConnectionSnapshot connection,
    @Default(PiNodeCompositionAvailability.externalNode)
    PiNodeCompositionAvailability nodeAvailability,
    @Default(WorkspaceEventStatus.idle) WorkspaceEventStatus eventStatus,
    @Default(WorkspacePromptAdmissionStatus.idle)
    WorkspacePromptAdmissionStatus promptAdmissionStatus,
    @JsonKey(includeToJson: false) PiProjectBootstrap? projectBootstrap,
    @JsonKey(includeToJson: false)
    @Default(<PiKnownProject>[])
    List<PiKnownProject> knownProjects,
    @JsonKey(includeToJson: false) PiProject? selectedProject,
    @JsonKey(includeToJson: false) PiDirectoryListing? projectDirectory,
    @JsonKey(includeToJson: false)
    @Default(<PiSessionSummary>[])
    List<PiSessionSummary> sessions,
    @JsonKey(includeToJson: false) PiSessionId? selectedSessionId,
    @JsonKey(includeToJson: false) PiSessionId? sessionAdminSessionId,
    @JsonKey(includeToJson: false)
    PiSessionAdminOperation? sessionAdminOperation,
    @JsonKey(includeToJson: false)
    @Default(<PiMessage>[])
    List<PiMessage> messages,
    @JsonKey(includeToJson: false) PiSessionHistoryCursor? historyCursor,
    @JsonKey(includeToJson: false)
    PiSessionBranchRevision? activeBranchRevision,
    @JsonKey(includeToJson: false) PiSessionTreeRevision? treeRevision,
    @Default(false) bool historyHasMore,
    @Default(false) bool historyLoading,
    @JsonKey(includeToJson: false) PiSessionStats? sessionStats,
    @Default(false) bool sessionStatsLoading,
    @JsonKey(includeToJson: false) PiSessionTree? sessionTree,
    @JsonKey(includeToJson: false)
    PiSessionTreeMutationOperation? sessionTreeMutationOperation,
    @Default(false) bool sessionTreeLoading,
    @Default(false) bool sessionTreeMutationLoading,
    @Default(0) int composerDraftGeneration,
    @JsonKey(includeToJson: false) String? composerDraft,
    @Default(false) bool projectLoading,
    @Default(false) bool projectBrowsing,
    @Default(false) bool projectValidating,
    @Default(false) bool projectTrustApproving,
    @Default(false) bool sessionsLoading,
    @Default(false) bool conversationLoading,
    @Default(false) bool creatingSession,
    @Default(false) bool sessionAdminLoading,
    @Default(false) bool sessionExportLoading,
    @JsonKey(includeToJson: false) PiSessionExportFormat? sessionExportFormat,
    @Default(0) int sessionExportSavedBytes,
    @Default(0) int sessionExportTotalBytes,
    String? lastExportFileName,
    @Default(false) bool sending,
    @Default(false) bool stopping,
    String? nodeError,
    String? projectError,
    String? sessionError,
    String? sessionAdminError,
    String? sessionTreeError,
    String? conversationError,
    String? sessionStatsError,
    String? sessionExportError,
    String? promptError,
    String? statusMessage,
  }) = _WorkspaceModel;
}

sealed class WorkspaceEvent {
  const WorkspaceEvent();
}

final class WorkspaceStarted extends WorkspaceEvent {
  const WorkspaceStarted();
}

final class WorkspaceConnectionRetried extends WorkspaceEvent {
  const WorkspaceConnectionRetried();
}

final class WorkspaceProjectDirectoryBrowsed extends WorkspaceEvent {
  const WorkspaceProjectDirectoryBrowsed(this.directory);

  final String directory;
}

final class WorkspaceProjectPathValidated extends WorkspaceEvent {
  const WorkspaceProjectPathValidated(this.candidateDirectory);

  final String candidateDirectory;
}

final class WorkspaceProjectSelected extends WorkspaceEvent {
  const WorkspaceProjectSelected(this.project);

  final PiProject project;
}

final class WorkspaceProjectTrustApproved extends WorkspaceEvent {
  const WorkspaceProjectTrustApproved({
    this.createSessionAfterApproval = false,
    this.sessionIdAfterApproval,
  });

  final bool createSessionAfterApproval;
  final PiSessionId? sessionIdAfterApproval;
}

final class WorkspaceSessionsRefreshed extends WorkspaceEvent {
  const WorkspaceSessionsRefreshed();
}

final class WorkspaceSessionSelected extends WorkspaceEvent {
  const WorkspaceSessionSelected(this.sessionId);

  final PiSessionId sessionId;
}

final class WorkspaceNewSessionRequested extends WorkspaceEvent {
  const WorkspaceNewSessionRequested();
}

final class WorkspaceSessionRenamed extends WorkspaceEvent {
  const WorkspaceSessionRenamed({required this.sessionId, required this.name});

  final PiSessionId sessionId;
  final String name;
}

final class WorkspaceSessionCustomNameCleared extends WorkspaceEvent {
  const WorkspaceSessionCustomNameCleared(this.sessionId);

  final PiSessionId sessionId;
}

final class WorkspaceSessionAutoNamed extends WorkspaceEvent {
  const WorkspaceSessionAutoNamed(this.sessionId);

  final PiSessionId sessionId;
}

final class WorkspaceSessionDeleted extends WorkspaceEvent {
  const WorkspaceSessionDeleted(this.confirmation);

  final PiDeleteSessionConfirmation confirmation;
}

final class WorkspaceSessionTreeNavigated extends WorkspaceEvent {
  const WorkspaceSessionTreeNavigated(this.entryId);

  final PiSessionTreeEntryId entryId;
}

final class WorkspaceSessionForked extends WorkspaceEvent {
  const WorkspaceSessionForked(this.userEntryId);

  final PiSessionTreeEntryId userEntryId;
}

final class WorkspaceSessionCloned extends WorkspaceEvent {
  const WorkspaceSessionCloned();
}

final class WorkspaceOlderHistoryRequested extends WorkspaceEvent {
  const WorkspaceOlderHistoryRequested();
}

final class WorkspaceSessionStatsRefreshed extends WorkspaceEvent {
  const WorkspaceSessionStatsRefreshed();
}

final class WorkspaceSessionExportRequested extends WorkspaceEvent {
  const WorkspaceSessionExportRequested(this.format);

  final PiSessionExportFormat format;
}

final class WorkspaceSessionExportCancelled extends WorkspaceEvent {
  const WorkspaceSessionExportCancelled();
}

final class WorkspacePromptSubmitted extends WorkspaceEvent {
  const WorkspacePromptSubmitted(this.prompt);

  final String prompt;
}

final class WorkspaceAgentStopped extends WorkspaceEvent {
  const WorkspaceAgentStopped();
}

final class _WorkspaceConnectionSnapshotReceived extends WorkspaceEvent {
  const _WorkspaceConnectionSnapshotReceived(this.snapshot);

  final PiNodeConnectionSnapshot snapshot;
}

final class _WorkspaceSessionEventReceived extends WorkspaceEvent {
  const _WorkspaceSessionEventReceived({
    required this.sessionId,
    required this.generation,
    required this.event,
  });

  final PiSessionId sessionId;
  final int generation;
  final PiSessionEvent event;
}

final class _WorkspaceSessionEventsFailed extends WorkspaceEvent {
  const _WorkspaceSessionEventsFailed({
    required this.sessionId,
    required this.generation,
    required this.error,
  });

  final PiSessionId sessionId;
  final int generation;
  final Object error;
}

final class _WorkspaceSessionEventsClosed extends WorkspaceEvent {
  const _WorkspaceSessionEventsClosed({
    required this.sessionId,
    required this.generation,
  });

  final PiSessionId sessionId;
  final int generation;
}
