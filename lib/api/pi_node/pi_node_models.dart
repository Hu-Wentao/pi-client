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

enum PiNodeConnectionStatus {
  disconnected,
  connecting,
  connected,
  closing,
  closed,
}

final class PiNodeConnectionSnapshot {
  const PiNodeConnectionSnapshot._(this.status, this.negotiatedVersion);

  const PiNodeConnectionSnapshot.disconnected()
    : this._(PiNodeConnectionStatus.disconnected, null);

  const PiNodeConnectionSnapshot.connecting()
    : this._(PiNodeConnectionStatus.connecting, null);

  PiNodeConnectionSnapshot.connected(PiProtocolVersion negotiatedVersion)
    : this._(PiNodeConnectionStatus.connected, negotiatedVersion);

  const PiNodeConnectionSnapshot.closing()
    : this._(PiNodeConnectionStatus.closing, null);

  const PiNodeConnectionSnapshot.closed()
    : this._(PiNodeConnectionStatus.closed, null);

  final PiNodeConnectionStatus status;
  final PiProtocolVersion? negotiatedVersion;

  @override
  bool operator ==(Object other) =>
      other is PiNodeConnectionSnapshot &&
      status == other.status &&
      negotiatedVersion == other.negotiatedVersion;

  @override
  int get hashCode => Object.hash(status, negotiatedVersion);

  @override
  String toString() =>
      'PiNodeConnectionSnapshot(status: $status, '
      'protocol: ${negotiatedVersion ?? '<none>'})';
}

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

  @override
  bool operator ==(Object other) =>
      other is PiSessionSummary &&
      id == other.id &&
      title == other.title &&
      workingDirectory == other.workingDirectory &&
      createdAt == other.createdAt &&
      updatedAt == other.updatedAt &&
      isRunning == other.isRunning &&
      hasUnread == other.hasUnread;

  @override
  int get hashCode => Object.hash(
    id,
    title,
    workingDirectory,
    createdAt,
    updatedAt,
    isRunning,
    hasUnread,
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

final class PiCreateSessionRequest {
  PiCreateSessionRequest({required String workingDirectory})
    : workingDirectory = _validatedPath(workingDirectory);

  final String workingDirectory;

  @override
  String toString() => 'PiCreateSessionRequest(<redacted>)';
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
