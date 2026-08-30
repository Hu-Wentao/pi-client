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
///   [ConversationView] > [PiMessageBubble] × N, [PromptComposerView],
///   [ProjectTrustDialog] (conditional)
/// Theme: material
/// Events: [WorkspaceStarted], [WorkspaceConnectionRetried],
///   [WorkspaceProjectDirectoryBrowsed], [WorkspaceProjectPathValidated],
///   [WorkspaceProjectSelected], [WorkspaceProjectTrustApproved],
///   [WorkspaceSessionsRefreshed], [WorkspaceSessionSelected],
///   [WorkspaceNewSessionRequested], [WorkspacePromptSubmitted],
///   [WorkspaceAgentStopped]
/// Startup Event: [WorkspaceStarted]
/// ViewModels: [WorkspaceViewModel]
/// Models: [WorkspaceModel]
/// Notes: The typed root route remains at `/`. [WorkspaceService] delegates
///   only to the app-owned [PiNodeApi], while [WorkspaceViewModel] owns typed
///   [PiSessionSummary], [PiMessage], and [PiSessionEvent] feature state and
///   subscriptions. Startup connects, resolves the Node-owned default project,
///   loads session-derived known projects, and lists the selected project's
///   sessions; directory browsing, manual-path validation, project selection,
///   explicit trust approval, refresh, session selection, creation,
///   prompt admission, ordered events, sequence-gap recovery, abort, and clean
///   close remain observable. Local-host, remote-node-required, unsupported,
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
    @JsonKey(includeToJson: false)
    @Default(<PiMessage>[])
    List<PiMessage> messages,
    @Default(false) bool projectLoading,
    @Default(false) bool projectBrowsing,
    @Default(false) bool projectValidating,
    @Default(false) bool projectTrustApproving,
    @Default(false) bool sessionsLoading,
    @Default(false) bool conversationLoading,
    @Default(false) bool creatingSession,
    @Default(false) bool sending,
    @Default(false) bool stopping,
    String? nodeError,
    String? projectError,
    String? sessionError,
    String? conversationError,
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
