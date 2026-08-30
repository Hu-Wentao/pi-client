import '../../protocol/pi_protocol.dart';
import 'pi_node_errors.dart';

final class PiSessionId {
  PiSessionId(String value) : value = _validatedOpaqueId(value, 'sessionId');

  final String value;

  @override
  bool operator ==(Object other) =>
      other is PiSessionId && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'PiSessionId(<redacted>)';
}

final class PiMessageId {
  PiMessageId(String value) : value = _validatedOpaqueId(value, 'messageId');

  final String value;

  @override
  bool operator ==(Object other) =>
      other is PiMessageId && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'PiMessageId(<redacted>)';
}

final class PiSessionTreeEntryId {
  PiSessionTreeEntryId(String value)
    : value = _validatedOpaqueId(value, 'sessionTreeEntryId');

  final String value;

  @override
  bool operator ==(Object other) =>
      other is PiSessionTreeEntryId && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'PiSessionTreeEntryId(<redacted>)';
}

final class PiSessionAdminRevision {
  PiSessionAdminRevision(String value)
    : value = _validatedOpaqueId(value, 'adminRevision');

  final String value;

  @override
  bool operator ==(Object other) =>
      other is PiSessionAdminRevision && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'PiSessionAdminRevision(<redacted>)';
}

final class PiCommandId {
  PiCommandId(String value) : value = _validatedOpaqueId(value, 'commandId');

  final String value;

  @override
  bool operator ==(Object other) =>
      other is PiCommandId && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'PiCommandId(<redacted>)';
}

final class PiProjectId {
  PiProjectId(String value) : value = _validatedOpaqueId(value, 'projectId');

  final String value;

  @override
  bool operator ==(Object other) =>
      other is PiProjectId && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'PiProjectId(<redacted>)';
}

final class PiWorktreeId {
  PiWorktreeId(String value) : value = _validatedOpaqueId(value, 'worktreeId');

  final String value;

  @override
  bool operator ==(Object other) =>
      other is PiWorktreeId && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'PiWorktreeId(<redacted>)';
}

final class PiMainProjectId {
  PiMainProjectId(String value)
    : value = _validatedOpaqueId(value, 'mainProjectId');

  final String value;

  @override
  bool operator ==(Object other) =>
      other is PiMainProjectId && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'PiMainProjectId(<redacted>)';
}

final class PiProjectTrustRevision {
  PiProjectTrustRevision(String value)
    : value = _validatedOpaqueId(value, 'trustRevision');

  final String value;

  @override
  bool operator ==(Object other) =>
      other is PiProjectTrustRevision && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'PiProjectTrustRevision(<redacted>)';
}

enum PiProjectTrustStatus { notRequired, trusted, approvalRequired, denied }

enum PiProjectTrustReason {
  piSettings,
  piExtensions,
  piSkills,
  piPrompts,
  piThemes,
  piSystemPrompt,
  agentSkills,
  savedApproval,
  savedDenial,
}

final class PiProjectTrustSnapshot {
  PiProjectTrustSnapshot({
    required this.status,
    required Iterable<PiProjectTrustReason> reasons,
    required this.revision,
  }) : reasons = List<PiProjectTrustReason>.unmodifiable(reasons) {
    if (status == PiProjectTrustStatus.notRequired && this.reasons.isNotEmpty) {
      throw ArgumentError('A trust-free project must not contain reasons.');
    }
    if (status != PiProjectTrustStatus.notRequired && this.reasons.isEmpty) {
      throw ArgumentError('A restricted or trusted project requires reasons.');
    }
  }

  final PiProjectTrustStatus status;
  final List<PiProjectTrustReason> reasons;
  final PiProjectTrustRevision revision;

  bool get allowsProjectResources => status == PiProjectTrustStatus.trusted;
  bool get requiresApproval =>
      status == PiProjectTrustStatus.approvalRequired ||
      status == PiProjectTrustStatus.denied;

  @override
  bool operator ==(Object other) =>
      other is PiProjectTrustSnapshot &&
      status == other.status &&
      revision == other.revision &&
      _sameList(reasons, other.reasons);

  @override
  int get hashCode => Object.hash(status, revision, Object.hashAll(reasons));

  @override
  String toString() =>
      'PiProjectTrustSnapshot(status: $status, reasons: ${reasons.length}, <redacted>)';
}

final class PiProjectIdentity {
  PiProjectIdentity({
    required this.projectId,
    required String canonicalWorkingDirectory,
    required this.isGitRepository,
    String? gitRoot,
    String? mainWorktreeRoot,
    String? branch,
    required this.isLinkedWorktree,
    required this.isDetachedHead,
    required this.worktreeId,
    required this.mainProjectId,
  }) : canonicalWorkingDirectory = _validatedPath(canonicalWorkingDirectory),
       gitRoot = gitRoot == null ? null : _validatedPath(gitRoot),
       mainWorktreeRoot = mainWorktreeRoot == null
           ? null
           : _validatedPath(mainWorktreeRoot),
       branch = branch == null
           ? null
           : _validatedText(branch, 'branch', allowEmpty: false) {
    if (isGitRepository &&
        (this.gitRoot == null || this.mainWorktreeRoot == null)) {
      throw ArgumentError('Git project identity requires Git roots.');
    }
    if (!isGitRepository &&
        (this.gitRoot != null ||
            this.mainWorktreeRoot != null ||
            this.branch != null ||
            isLinkedWorktree ||
            isDetachedHead)) {
      throw ArgumentError('Non-Git project identity contains Git-only fields.');
    }
    if (isDetachedHead && this.branch != null) {
      throw ArgumentError(
        'Detached project identity must not contain a branch.',
      );
    }
  }

  final PiProjectId projectId;
  final String canonicalWorkingDirectory;
  final bool isGitRepository;
  final String? gitRoot;
  final String? mainWorktreeRoot;
  final String? branch;
  final bool isLinkedWorktree;
  final bool isDetachedHead;
  final PiWorktreeId worktreeId;
  final PiMainProjectId mainProjectId;

  @override
  bool operator ==(Object other) =>
      other is PiProjectIdentity &&
      projectId == other.projectId &&
      canonicalWorkingDirectory == other.canonicalWorkingDirectory &&
      isGitRepository == other.isGitRepository &&
      gitRoot == other.gitRoot &&
      mainWorktreeRoot == other.mainWorktreeRoot &&
      branch == other.branch &&
      isLinkedWorktree == other.isLinkedWorktree &&
      isDetachedHead == other.isDetachedHead &&
      worktreeId == other.worktreeId &&
      mainProjectId == other.mainProjectId;

  @override
  int get hashCode => Object.hash(
    projectId,
    canonicalWorkingDirectory,
    isGitRepository,
    gitRoot,
    mainWorktreeRoot,
    branch,
    isLinkedWorktree,
    isDetachedHead,
    worktreeId,
    mainProjectId,
  );

  @override
  String toString() => 'PiProjectIdentity(<redacted>)';
}

final class PiProject {
  const PiProject({required this.identity, required this.trust});

  final PiProjectIdentity identity;
  final PiProjectTrustSnapshot trust;

  @override
  bool operator ==(Object other) =>
      other is PiProject && identity == other.identity && trust == other.trust;

  @override
  int get hashCode => Object.hash(identity, trust);

  @override
  String toString() => 'PiProject(<redacted>)';
}

final class PiKnownProject {
  PiKnownProject({
    required this.project,
    required DateTime lastSessionAt,
    required int sessionCount,
  }) : lastSessionAt = _validatedUtcInstant(lastSessionAt, 'lastSessionAt'),
       sessionCount = _validatedPositiveInt(sessionCount, 'sessionCount');

  final PiProject project;
  final DateTime lastSessionAt;
  final int sessionCount;

  @override
  bool operator ==(Object other) =>
      other is PiKnownProject &&
      project == other.project &&
      lastSessionAt == other.lastSessionAt &&
      sessionCount == other.sessionCount;

  @override
  int get hashCode => Object.hash(project, lastSessionAt, sessionCount);

  @override
  String toString() => 'PiKnownProject(<redacted>)';
}

final class PiProjectBootstrap {
  PiProjectBootstrap({
    required String homeDirectory,
    required this.defaultProject,
  }) : homeDirectory = _validatedPath(homeDirectory);

  final String homeDirectory;
  final PiProject defaultProject;

  @override
  String toString() => 'PiProjectBootstrap(<redacted>)';
}

final class PiDirectoryEntry {
  PiDirectoryEntry({
    required String name,
    required String canonicalPath,
    required this.isSymbolicLink,
  }) : name = _validatedText(name, 'name', allowEmpty: false),
       canonicalPath = _validatedPath(canonicalPath);

  final String name;
  final String canonicalPath;
  final bool isSymbolicLink;

  @override
  bool operator ==(Object other) =>
      other is PiDirectoryEntry &&
      name == other.name &&
      canonicalPath == other.canonicalPath &&
      isSymbolicLink == other.isSymbolicLink;

  @override
  int get hashCode => Object.hash(name, canonicalPath, isSymbolicLink);

  @override
  String toString() => 'PiDirectoryEntry(<redacted>)';
}

final class PiDirectoryListing {
  PiDirectoryListing({
    required String canonicalDirectory,
    String? parentDirectory,
    required Iterable<PiDirectoryEntry> children,
    required this.truncated,
  }) : canonicalDirectory = _validatedPath(canonicalDirectory),
       parentDirectory = parentDirectory == null
           ? null
           : _validatedPath(parentDirectory),
       children = List<PiDirectoryEntry>.unmodifiable(children);

  final String canonicalDirectory;
  final String? parentDirectory;
  final List<PiDirectoryEntry> children;
  final bool truncated;

  @override
  String toString() => 'PiDirectoryListing(<redacted>)';
}

final class PiBrowseDirectoryRequest {
  PiBrowseDirectoryRequest({required String directory, this.maxChildren = 64})
    : directory = _validatedPath(directory) {
    _validatedBoundedCount(maxChildren, 'maxChildren', 128);
  }

  final String directory;
  final int maxChildren;

  @override
  String toString() => 'PiBrowseDirectoryRequest(<redacted>)';
}

final class PiValidateProjectRequest {
  PiValidateProjectRequest({required String candidateDirectory})
    : candidateDirectory = _validatedPath(candidateDirectory);

  final String candidateDirectory;

  @override
  String toString() => 'PiValidateProjectRequest(<redacted>)';
}

final class PiProjectTrustApproval {
  const PiProjectTrustApproval({
    required this.projectId,
    required this.revision,
  });

  final PiProjectId projectId;
  final PiProjectTrustRevision revision;

  @override
  String toString() => 'PiProjectTrustApproval(<redacted>)';
}

enum PiNodeConnectionStatus {
  disconnected,
  connecting,
  connected,
  closing,
  closed,
}

final class PiNodeConnectionSnapshot {
  const PiNodeConnectionSnapshot._(
    this.status,
    this.negotiatedVersion,
    this.capabilities,
  );

  const PiNodeConnectionSnapshot.disconnected()
    : this._(
        PiNodeConnectionStatus.disconnected,
        null,
        const <PiProtocolCapability>{},
      );

  const PiNodeConnectionSnapshot.connecting()
    : this._(
        PiNodeConnectionStatus.connecting,
        null,
        const <PiProtocolCapability>{},
      );

  factory PiNodeConnectionSnapshot.connected(
    PiProtocolVersion negotiatedVersion, {
    Iterable<PiProtocolCapability> capabilities =
        const <PiProtocolCapability>[],
  }) => PiNodeConnectionSnapshot._(
    PiNodeConnectionStatus.connected,
    negotiatedVersion,
    Set<PiProtocolCapability>.unmodifiable(capabilities),
  );

  const PiNodeConnectionSnapshot.closing()
    : this._(
        PiNodeConnectionStatus.closing,
        null,
        const <PiProtocolCapability>{},
      );

  const PiNodeConnectionSnapshot.closed()
    : this._(
        PiNodeConnectionStatus.closed,
        null,
        const <PiProtocolCapability>{},
      );

  final PiNodeConnectionStatus status;
  final PiProtocolVersion? negotiatedVersion;
  final Set<PiProtocolCapability> capabilities;

  @override
  bool operator ==(Object other) =>
      other is PiNodeConnectionSnapshot &&
      status == other.status &&
      negotiatedVersion == other.negotiatedVersion &&
      _sameCapabilities(capabilities, other.capabilities);

  @override
  int get hashCode => Object.hash(
    status,
    negotiatedVersion,
    Object.hashAll(
      capabilities.toList(growable: false)
        ..sort((left, right) => left.index.compareTo(right.index)),
    ),
  );

  @override
  String toString() =>
      'PiNodeConnectionSnapshot(status: $status, '
      'protocol: ${negotiatedVersion ?? '<none>'}, '
      'capabilities: ${capabilities.length})';
}

bool _sameCapabilities(
  Set<PiProtocolCapability> left,
  Set<PiProtocolCapability> right,
) => left.length == right.length && left.containsAll(right);

enum PiMessageRole { user, assistant, tool, system }

final class PiMessage {
  PiMessage({
    required this.id,
    required this.role,
    required String text,
    required DateTime createdAt,
    required this.isStreaming,
  }) : text = _validatedText(text, 'text'),
       createdAt = _validatedUtcInstant(createdAt, 'createdAt');

  final PiMessageId id;
  final PiMessageRole role;
  final String text;
  final DateTime createdAt;
  final bool isStreaming;

  @override
  bool operator ==(Object other) =>
      other is PiMessage &&
      id == other.id &&
      role == other.role &&
      text == other.text &&
      createdAt == other.createdAt &&
      isStreaming == other.isStreaming;

  @override
  int get hashCode => Object.hash(id, role, text, createdAt, isStreaming);

  @override
  String toString() => 'PiMessage(role: $role, <redacted>)';
}

final class PiSessionSummary {
  PiSessionSummary({
    required this.id,
    required String title,
    required String workingDirectory,
    required DateTime createdAt,
    required DateTime updatedAt,
    required this.isRunning,
    required this.hasUnread,
    required this.adminRevision,
    required this.hasCustomName,
    this.parentSessionId,
  }) : title = _validatedText(title, 'title', allowEmpty: false),
       workingDirectory = _validatedPath(workingDirectory),
       createdAt = _validatedUtcInstant(createdAt, 'createdAt'),
       updatedAt = _validatedUtcInstant(updatedAt, 'updatedAt') {
    if (updatedAt.isBefore(createdAt)) {
      throw ArgumentError('updatedAt must not be before createdAt.');
    }
  }

  final PiSessionId id;
  final String title;
  final String workingDirectory;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isRunning;
  final bool hasUnread;
  final PiSessionAdminRevision adminRevision;
  final bool hasCustomName;
  final PiSessionId? parentSessionId;

  @override
  bool operator ==(Object other) =>
      other is PiSessionSummary &&
      id == other.id &&
      title == other.title &&
      workingDirectory == other.workingDirectory &&
      createdAt == other.createdAt &&
      updatedAt == other.updatedAt &&
      isRunning == other.isRunning &&
      hasUnread == other.hasUnread &&
      adminRevision == other.adminRevision &&
      hasCustomName == other.hasCustomName &&
      parentSessionId == other.parentSessionId;

  @override
  int get hashCode => Object.hash(
    id,
    title,
    workingDirectory,
    createdAt,
    updatedAt,
    isRunning,
    hasUnread,
    adminRevision,
    hasCustomName,
    parentSessionId,
  );

  @override
  String toString() => 'PiSessionSummary(<redacted>)';
}

final class PiSessionDetail {
  PiSessionDetail({
    required this.summary,
    required Iterable<PiMessage> messages,
  }) : messages = List<PiMessage>.unmodifiable(messages);

  final PiSessionSummary summary;
  final List<PiMessage> messages;

  @override
  bool operator ==(Object other) {
    if (other is! PiSessionDetail || summary != other.summary) return false;
    if (messages.length != other.messages.length) return false;
    for (var index = 0; index < messages.length; index += 1) {
      if (messages[index] != other.messages[index]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(summary, Object.hashAll(messages));

  @override
  String toString() => 'PiSessionDetail(<redacted>)';
}

enum PiSessionTreeEntryKind {
  userMessage,
  assistantMessage,
  toolMessage,
  customMessage,
  thinkingLevel,
  modelChange,
  compaction,
  branchSummary,
  custom,
  label,
  sessionInfo,
}

final class PiSessionTreeNode {
  PiSessionTreeNode({
    required this.id,
    this.parentId,
    required this.kind,
    required String text,
    required DateTime createdAt,
    this.label,
    required int depth,
    required this.isOnActivePath,
    required this.hasChildren,
    required this.canEditFromHere,
    required this.canFork,
  }) : text = _validatedText(text, 'text'),
       createdAt = _validatedUtcInstant(createdAt, 'createdAt'),
       depth = _validatedBoundedCount(depth, 'depth', 0xffffffff) {
    if (label != null) _validatedText(label!, 'label', allowEmpty: false);
  }

  final PiSessionTreeEntryId id;
  final PiSessionTreeEntryId? parentId;
  final PiSessionTreeEntryKind kind;
  final String text;
  final DateTime createdAt;
  final String? label;
  final int depth;
  final bool isOnActivePath;
  final bool hasChildren;
  final bool canEditFromHere;
  final bool canFork;

  @override
  bool operator ==(Object other) =>
      other is PiSessionTreeNode &&
      id == other.id &&
      parentId == other.parentId &&
      kind == other.kind &&
      text == other.text &&
      createdAt == other.createdAt &&
      label == other.label &&
      depth == other.depth &&
      isOnActivePath == other.isOnActivePath &&
      hasChildren == other.hasChildren &&
      canEditFromHere == other.canEditFromHere &&
      canFork == other.canFork;

  @override
  int get hashCode => Object.hash(
    id,
    parentId,
    kind,
    text,
    createdAt,
    label,
    depth,
    isOnActivePath,
    hasChildren,
    canEditFromHere,
    canFork,
  );
}

final class PiSessionTree {
  PiSessionTree({
    required this.sessionId,
    required Iterable<PiSessionTreeNode> nodes,
    required Iterable<PiSessionTreeEntryId> activePathEntryIds,
    this.activeLeafEntryId,
    required this.canCloneActiveBranch,
    required this.adminRevision,
  }) : nodes = List<PiSessionTreeNode>.unmodifiable(nodes),
       activePathEntryIds = List<PiSessionTreeEntryId>.unmodifiable(
         activePathEntryIds,
       );

  final PiSessionId sessionId;
  final List<PiSessionTreeNode> nodes;
  final List<PiSessionTreeEntryId> activePathEntryIds;
  final PiSessionTreeEntryId? activeLeafEntryId;
  final bool canCloneActiveBranch;
  final PiSessionAdminRevision adminRevision;

  PiSessionTreeNode? nodeById(PiSessionTreeEntryId id) =>
      nodes.where((node) => node.id == id).firstOrNull;

  @override
  bool operator ==(Object other) =>
      other is PiSessionTree &&
      sessionId == other.sessionId &&
      _sameList(nodes, other.nodes) &&
      _sameList(activePathEntryIds, other.activePathEntryIds) &&
      activeLeafEntryId == other.activeLeafEntryId &&
      canCloneActiveBranch == other.canCloneActiveBranch &&
      adminRevision == other.adminRevision;

  @override
  int get hashCode => Object.hash(
    sessionId,
    Object.hashAll(nodes),
    Object.hashAll(activePathEntryIds),
    activeLeafEntryId,
    canCloneActiveBranch,
    adminRevision,
  );
}

final class PiCreateSessionRequest {
  const PiCreateSessionRequest({required this.projectId});

  final PiProjectId projectId;

  @override
  String toString() => 'PiCreateSessionRequest(<redacted>)';
}

enum PiSessionAdminOperation { rename, clearName, autoName, delete }

sealed class PiSessionAdminCommand {
  const PiSessionAdminCommand({
    required this.commandId,
    required this.projectId,
    required this.sessionId,
  });

  final PiCommandId commandId;
  final PiProjectId projectId;
  final PiSessionId sessionId;
}

final class PiRenameSessionCommand extends PiSessionAdminCommand {
  PiRenameSessionCommand({
    required super.commandId,
    required super.projectId,
    required super.sessionId,
    required String name,
  }) : name = _validatedText(name, 'name', allowEmpty: false);

  final String name;

  @override
  String toString() => 'PiRenameSessionCommand(<redacted>)';
}

final class PiClearSessionNameCommand extends PiSessionAdminCommand {
  const PiClearSessionNameCommand({
    required super.commandId,
    required super.projectId,
    required super.sessionId,
  });

  @override
  String toString() => 'PiClearSessionNameCommand(<redacted>)';
}

final class PiAutoNameSessionCommand extends PiSessionAdminCommand {
  PiAutoNameSessionCommand({
    required super.commandId,
    required super.projectId,
    required super.sessionId,
    this.timeout = const Duration(seconds: 15),
  }) {
    if (timeout < const Duration(seconds: 1) ||
        timeout > const Duration(seconds: 30)) {
      throw ArgumentError('timeout is outside the supported range.');
    }
  }

  final Duration timeout;

  @override
  String toString() => 'PiAutoNameSessionCommand(<redacted>)';
}

final class PiDeleteSessionConfirmation {
  const PiDeleteSessionConfirmation({
    required this.sessionId,
    required this.adminRevision,
    required this.displayedTitle,
    required this.destructiveActionAcknowledged,
  });

  factory PiDeleteSessionConfirmation.confirmed(PiSessionSummary session) =>
      PiDeleteSessionConfirmation(
        sessionId: session.id,
        adminRevision: session.adminRevision,
        displayedTitle: session.title,
        destructiveActionAcknowledged: true,
      );

  final PiSessionId sessionId;
  final PiSessionAdminRevision adminRevision;
  final String displayedTitle;
  final bool destructiveActionAcknowledged;

  @override
  String toString() => 'PiDeleteSessionConfirmation(<redacted>)';
}

final class PiDeleteSessionCommand extends PiSessionAdminCommand {
  const PiDeleteSessionCommand({
    required super.commandId,
    required super.projectId,
    required super.sessionId,
    required this.confirmation,
  });

  final PiDeleteSessionConfirmation confirmation;

  @override
  String toString() => 'PiDeleteSessionCommand(<redacted>)';
}

sealed class PiSessionAdminResult {
  const PiSessionAdminResult({
    required this.commandId,
    required this.operation,
  });

  final PiCommandId commandId;
  final PiSessionAdminOperation operation;
}

final class PiSessionAdminUpdated extends PiSessionAdminResult {
  const PiSessionAdminUpdated({
    required super.commandId,
    required super.operation,
    required this.session,
  });

  final PiSessionSummary session;
}

final class PiSessionAdminDeleted extends PiSessionAdminResult {
  const PiSessionAdminDeleted({
    required super.commandId,
    required this.sessionId,
    required this.reparentedChildCount,
  }) : super(operation: PiSessionAdminOperation.delete);

  final PiSessionId sessionId;
  final int reparentedChildCount;
}

final class PiSessionAdminRejected extends PiSessionAdminResult {
  const PiSessionAdminRejected({
    required super.commandId,
    required super.operation,
    required this.error,
  });

  final PiNodeException error;
}

final class PiSessionAdminUncertain extends PiSessionAdminResult {
  const PiSessionAdminUncertain({
    required super.commandId,
    required super.operation,
    required this.error,
  });

  final PiNodeException error;
}

enum PiSessionTreeMutationOperation { navigate, fork, clone }

sealed class PiSessionTreeMutationCommand {
  const PiSessionTreeMutationCommand({
    required this.commandId,
    required this.projectId,
    required this.sessionId,
    required this.expectedAdminRevision,
  });

  final PiCommandId commandId;
  final PiProjectId projectId;
  final PiSessionId sessionId;
  final PiSessionAdminRevision expectedAdminRevision;
}

final class PiNavigateSessionTreeCommand extends PiSessionTreeMutationCommand {
  const PiNavigateSessionTreeCommand({
    required super.commandId,
    required super.projectId,
    required super.sessionId,
    required super.expectedAdminRevision,
    required this.entryId,
  });

  final PiSessionTreeEntryId entryId;
}

final class PiForkSessionCommand extends PiSessionTreeMutationCommand {
  const PiForkSessionCommand({
    required super.commandId,
    required super.projectId,
    required super.sessionId,
    required super.expectedAdminRevision,
    required this.userEntryId,
  });

  final PiSessionTreeEntryId userEntryId;
}

final class PiCloneSessionCommand extends PiSessionTreeMutationCommand {
  const PiCloneSessionCommand({
    required super.commandId,
    required super.projectId,
    required super.sessionId,
    required super.expectedAdminRevision,
  });
}

sealed class PiSessionTreeMutationResult {
  const PiSessionTreeMutationResult({
    required this.commandId,
    required this.operation,
  });

  final PiCommandId commandId;
  final PiSessionTreeMutationOperation operation;
}

final class PiSessionTreeMutationUpdated extends PiSessionTreeMutationResult {
  const PiSessionTreeMutationUpdated({
    required super.commandId,
    required super.operation,
    required this.session,
    required this.tree,
    this.editorText,
  });

  final PiSessionDetail session;
  final PiSessionTree tree;
  final String? editorText;
}

final class PiSessionTreeMutationRejected extends PiSessionTreeMutationResult {
  const PiSessionTreeMutationRejected({
    required super.commandId,
    required super.operation,
    required this.error,
  });

  final PiNodeException error;
}

final class PiSessionTreeMutationUncertain extends PiSessionTreeMutationResult {
  const PiSessionTreeMutationUncertain({
    required super.commandId,
    required super.operation,
    required this.error,
  });

  final PiNodeException error;
}

sealed class PiSessionCommand {
  const PiSessionCommand({required this.commandId, required this.sessionId});

  final PiCommandId commandId;
  final PiSessionId sessionId;
}

final class PiPromptCommand extends PiSessionCommand {
  PiPromptCommand({
    required super.commandId,
    required super.sessionId,
    required String prompt,
  }) : prompt = _validatedText(prompt, 'prompt', allowEmpty: false);

  final String prompt;

  @override
  String toString() => 'PiPromptCommand(<redacted>)';
}

final class PiAbortCommand extends PiSessionCommand {
  const PiAbortCommand({required super.commandId, required super.sessionId});

  @override
  String toString() => 'PiAbortCommand(<redacted>)';
}

sealed class PiCommandResult {
  const PiCommandResult(this.commandId);

  final PiCommandId commandId;
}

final class PiCommandAccepted extends PiCommandResult {
  const PiCommandAccepted(super.commandId);

  @override
  String toString() => 'PiCommandAccepted(<redacted>)';
}

final class PiCommandRejected extends PiCommandResult {
  const PiCommandRejected(super.commandId, this.error);

  final PiNodeException error;

  @override
  String toString() =>
      'PiCommandRejected(error: ${error.code.name}, <redacted>)';
}

final class PiCommandUncertain extends PiCommandResult {
  const PiCommandUncertain(super.commandId, this.error);

  final PiNodeException error;

  @override
  String toString() =>
      'PiCommandUncertain(error: ${error.code.name}, <redacted>)';
}

sealed class PiSessionEvent {
  PiSessionEvent({required this.sessionId, required int sequence})
    : sequence = _validatedPositiveInt(sequence, 'sequence');

  final PiSessionId sessionId;
  final int sequence;
}

final class PiSessionMessageAddedEvent extends PiSessionEvent {
  PiSessionMessageAddedEvent({
    required super.sessionId,
    required super.sequence,
    required this.message,
  });

  final PiMessage message;
}

final class PiSessionMessageDeltaEvent extends PiSessionEvent {
  PiSessionMessageDeltaEvent({
    required super.sessionId,
    required super.sequence,
    required this.messageId,
    required String delta,
  }) : delta = _validatedText(delta, 'delta');

  final PiMessageId messageId;
  final String delta;

  @override
  String toString() => 'PiSessionMessageDeltaEvent(<redacted>)';
}

final class PiSessionRunningChangedEvent extends PiSessionEvent {
  PiSessionRunningChangedEvent({
    required super.sessionId,
    required super.sequence,
    required this.isRunning,
  });

  final bool isRunning;
}

final class PiSessionCommandCompletedEvent extends PiSessionEvent {
  PiSessionCommandCompletedEvent({
    required super.sessionId,
    required super.sequence,
    required this.commandId,
    required this.succeeded,
  });

  final PiCommandId commandId;
  final bool succeeded;
}

/// A local recovery signal. The event received at [receivedSequence] is not
/// emitted because one or more earlier events were missing.
final class PiSessionSequenceGapEvent extends PiSessionEvent {
  PiSessionSequenceGapEvent({
    required super.sessionId,
    required int expectedSequence,
    required int receivedSequence,
  }) : expectedSequence = _validatedPositiveInt(
         expectedSequence,
         'expectedSequence',
       ),
       receivedSequence = _validatedPositiveInt(
         receivedSequence,
         'receivedSequence',
       ),
       super(sequence: receivedSequence) {
    if (receivedSequence <= expectedSequence) {
      throw ArgumentError(
        'A sequence gap must advance beyond the expectation.',
      );
    }
  }

  final int expectedSequence;
  final int receivedSequence;
}

bool _sameList<T>(List<T> left, List<T> right) {
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index += 1) {
    if (left[index] != right[index]) return false;
  }
  return true;
}

int _validatedBoundedCount(int value, String name, int maximum) {
  if (value < 0 || value > maximum) {
    throw ArgumentError('$name is outside the supported range.');
  }
  return value;
}

int _validatedPositiveInt(int value, String name) {
  if (value <= 0) throw ArgumentError('$name must be positive.');
  return value;
}

String _validatedOpaqueId(String value, String name) {
  if (value.isEmpty ||
      value.length > 256 ||
      value.trim() != value ||
      _containsForbiddenControl(value)) {
    throw ArgumentError('Invalid $name.');
  }
  return value;
}

String _validatedPath(String value) {
  if (value.isEmpty ||
      value.length > 32768 ||
      value.trim() != value ||
      _containsForbiddenControl(value)) {
    throw ArgumentError('Invalid workingDirectory.');
  }
  return value;
}

String _validatedText(String value, String name, {bool allowEmpty = true}) {
  if ((!allowEmpty && value.trim().isEmpty) ||
      value.length > 1048576 ||
      value.contains('\u0000')) {
    throw ArgumentError('Invalid $name.');
  }
  return value;
}

DateTime _validatedUtcInstant(DateTime value, String name) {
  if (!value.isUtc) throw ArgumentError('$name must be in UTC.');
  return value;
}

bool _containsForbiddenControl(String value) =>
    value.codeUnits.any((unit) => unit <= 0x1f || unit == 0x7f);
