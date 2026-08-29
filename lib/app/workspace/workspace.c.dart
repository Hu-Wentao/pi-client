/// Figma:
/// - Frame: none
/// - Page Title: Pi Client
/// - Node: none
/// Figma Fidelity: excluded | no Figma design was supplied; the UI is an independent Flutter implementation of the pinned pi-web behavior baseline
/// Figma Data:
/// - none
/// State Ownership: page-owned [WorkspaceViewModel]
/// Public Views:
/// - [WorkspaceView] — typed Page primary View.
/// Widget Tree: [WorkspaceView] > [_ConnectionPanel], [_SessionSidebar],
///   [_ConversationHeader], [_MessageTimeline], [_Composer]
/// Theme: material
/// Events: [WorkspaceStarted], [WorkspaceConnectionApplied],
///   [WorkspaceSessionsRefreshed], [WorkspaceSessionSelected],
///   [WorkspaceNewSessionRequested], [WorkspacePromptSubmitted],
///   [WorkspaceAgentStopped]
/// Startup Event: [WorkspaceStarted]
/// ViewModels: [WorkspaceViewModel]
/// Models: [WorkspaceModel], [PiSessionModel], [PiMessageModel]
/// API: GET /api/sessions
/// Behavior:
/// - UI Data: connection state, session summaries, selected-session messages, running state, and incremental assistant output
/// - Source: agegr/pi-web commit 28bab3c25f5f6770c9b0b745ebbfec1c27f7b948 endpoints under /api/sessions and /api/agent
/// - Loading/Refresh: connect on entry, explicitly refresh sessions, load a selected conversation, and keep the active session SSE stream attached
/// - Empty/Error: show a connection action when unavailable, an empty session state when no sessions exist, and retryable inline errors without inventing data
/// Notes: [PiWebGateway] uses GET `/api/sessions` and GET
///   `/api/sessions/:id` for the primary query behavior. It also owns POST
///   `/api/agent/new`, POST `/api/agent/:id`, and GET
///   `/api/agent/:id/events` for session creation, prompt/abort commands, and
///   SSE updates under the same pinned upstream boundary. It uses the
///   application-owned Dio instance with absolute request URIs and per-request
///   Basic Auth. The password remains private to [WorkspaceViewModel], is never
///   included in [WorkspaceModel], JSON output, logs, or repository files. SSE
///   reconnects only for the selected session. Focused service and ViewModel
///   tests own command and stream verification because explicit API contracts
///   expose one primary query/command Behavior.

part of 'workspace.dart';

enum WorkspaceConnectionStatus { disconnected, connecting, connected, error }

enum WorkspaceStreamStatus { idle, connecting, connected, reconnecting, error }

enum PiMessageRole { user, assistant, tool, custom, bash }

@immutable
@JsonSerializable(createFactory: false)
class PiSessionModel {
  const PiSessionModel({
    required this.id,
    required this.cwd,
    required this.created,
    required this.modified,
    required this.messageCount,
    required this.firstMessage,
    required this.running,
    this.name,
  });

  final String id;
  final String cwd;
  final String? name;
  final String created;
  final String modified;
  final int messageCount;
  final String firstMessage;
  final bool running;

  String get title {
    final trimmedName = name?.trim();
    if (trimmedName != null && trimmedName.isNotEmpty) return trimmedName;
    final trimmedFirstMessage = firstMessage.trim();
    if (trimmedFirstMessage.isNotEmpty &&
        trimmedFirstMessage != '(no messages)') {
      return trimmedFirstMessage;
    }
    return id;
  }

  PiSessionModel copyWith({bool? running}) => PiSessionModel(
    id: id,
    cwd: cwd,
    name: name,
    created: created,
    modified: modified,
    messageCount: messageCount,
    firstMessage: firstMessage,
    running: running ?? this.running,
  );

  Map<String, dynamic> toJson() => _$PiSessionModelToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PiSessionModel &&
          id == other.id &&
          cwd == other.cwd &&
          name == other.name &&
          created == other.created &&
          modified == other.modified &&
          messageCount == other.messageCount &&
          firstMessage == other.firstMessage &&
          running == other.running;

  @override
  @JsonKey(includeToJson: false)
  int get hashCode => Object.hash(
    id,
    cwd,
    name,
    created,
    modified,
    messageCount,
    firstMessage,
    running,
  );
}

@immutable
@JsonSerializable(createFactory: false)
class PiMessageModel {
  const PiMessageModel({
    required this.id,
    required this.role,
    required this.text,
    this.isError = false,
    this.timestampMs,
    this.streaming = false,
  });

  final String id;
  final PiMessageRole role;
  final String text;
  final bool isError;
  final int? timestampMs;
  final bool streaming;

  PiMessageModel copyWith({
    String? text,
    bool? isError,
    int? timestampMs,
    bool? streaming,
  }) => PiMessageModel(
    id: id,
    role: role,
    text: text ?? this.text,
    isError: isError ?? this.isError,
    timestampMs: timestampMs ?? this.timestampMs,
    streaming: streaming ?? this.streaming,
  );

  Map<String, dynamic> toJson() => _$PiMessageModelToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PiMessageModel &&
          id == other.id &&
          role == other.role &&
          text == other.text &&
          isError == other.isError &&
          timestampMs == other.timestampMs &&
          streaming == other.streaming;

  @override
  @JsonKey(includeToJson: false)
  int get hashCode =>
      Object.hash(id, role, text, isError, timestampMs, streaming);
}

@FrState
abstract class WorkspaceModel with _$WorkspaceModel {
  const factory WorkspaceModel({
    @Default('http://127.0.0.1:30141') String baseUrl,
    @Default(WorkspaceConnectionStatus.disconnected)
    WorkspaceConnectionStatus connectionStatus,
    @Default(WorkspaceStreamStatus.idle) WorkspaceStreamStatus streamStatus,
    @Default(<PiSessionModel>[]) List<PiSessionModel> sessions,
    String? selectedSessionId,
    @Default(<PiMessageModel>[]) List<PiMessageModel> messages,
    @Default(false) bool sessionsLoading,
    @Default(false) bool conversationLoading,
    @Default(false) bool creatingSession,
    @Default(false) bool sending,
    @Default(false) bool streaming,
    String? error,
    String? statusMessage,
  }) = _WorkspaceModel;
}

sealed class WorkspaceEvent {
  const WorkspaceEvent();
}

final class WorkspaceStarted extends WorkspaceEvent {
  const WorkspaceStarted();
}

final class WorkspaceConnectionApplied extends WorkspaceEvent {
  const WorkspaceConnectionApplied({
    required this.baseUrl,
    required this.password,
  });

  final String baseUrl;
  final String password;
}

final class WorkspaceSessionsRefreshed extends WorkspaceEvent {
  const WorkspaceSessionsRefreshed();
}

final class WorkspaceSessionSelected extends WorkspaceEvent {
  const WorkspaceSessionSelected(this.sessionId);

  final String sessionId;
}

final class WorkspaceNewSessionRequested extends WorkspaceEvent {
  const WorkspaceNewSessionRequested(this.cwd);

  final String cwd;
}

final class WorkspacePromptSubmitted extends WorkspaceEvent {
  const WorkspacePromptSubmitted(this.message);

  final String message;
}

final class WorkspaceAgentStopped extends WorkspaceEvent {
  const WorkspaceAgentStopped();
}

final class _WorkspaceStreamEventReceived extends WorkspaceEvent {
  const _WorkspaceStreamEventReceived({
    required this.sessionId,
    required this.generation,
    required this.payload,
  });

  final String sessionId;
  final int generation;
  final Map<String, dynamic> payload;
}

final class _WorkspaceStreamFailed extends WorkspaceEvent {
  const _WorkspaceStreamFailed({
    required this.sessionId,
    required this.generation,
    required this.error,
  });

  final String sessionId;
  final int generation;
  final Object error;
}

final class _WorkspaceStreamClosed extends WorkspaceEvent {
  const _WorkspaceStreamClosed({
    required this.sessionId,
    required this.generation,
  });

  final String sessionId;
  final int generation;
}

final class _WorkspaceStreamStatusChanged extends WorkspaceEvent {
  const _WorkspaceStreamStatusChanged(this.status);

  final WorkspaceStreamStatus status;
}
