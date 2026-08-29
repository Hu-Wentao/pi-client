// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$PiSessionModelToJson(PiSessionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'cwd': instance.cwd,
      'name': instance.name,
      'created': instance.created,
      'modified': instance.modified,
      'messageCount': instance.messageCount,
      'firstMessage': instance.firstMessage,
      'running': instance.running,
      'title': instance.title,
    };

Map<String, dynamic> _$PiMessageModelToJson(PiMessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'role': _$PiMessageRoleEnumMap[instance.role]!,
      'text': instance.text,
      'isError': instance.isError,
      'timestampMs': instance.timestampMs,
      'streaming': instance.streaming,
    };

const _$PiMessageRoleEnumMap = {
  PiMessageRole.user: 'user',
  PiMessageRole.assistant: 'assistant',
  PiMessageRole.tool: 'tool',
  PiMessageRole.custom: 'custom',
  PiMessageRole.bash: 'bash',
};

Map<String, dynamic> _$WorkspaceModelToJson(_WorkspaceModel instance) =>
    <String, dynamic>{
      'baseUrl': instance.baseUrl,
      'connectionStatus':
          _$WorkspaceConnectionStatusEnumMap[instance.connectionStatus]!,
      'streamStatus': _$WorkspaceStreamStatusEnumMap[instance.streamStatus]!,
      'sessions': instance.sessions,
      'selectedSessionId': instance.selectedSessionId,
      'messages': instance.messages,
      'sessionsLoading': instance.sessionsLoading,
      'conversationLoading': instance.conversationLoading,
      'creatingSession': instance.creatingSession,
      'sending': instance.sending,
      'streaming': instance.streaming,
      'error': instance.error,
      'statusMessage': instance.statusMessage,
    };

const _$WorkspaceConnectionStatusEnumMap = {
  WorkspaceConnectionStatus.disconnected: 'disconnected',
  WorkspaceConnectionStatus.connecting: 'connecting',
  WorkspaceConnectionStatus.connected: 'connected',
  WorkspaceConnectionStatus.error: 'error',
};

const _$WorkspaceStreamStatusEnumMap = {
  WorkspaceStreamStatus.idle: 'idle',
  WorkspaceStreamStatus.connecting: 'connecting',
  WorkspaceStreamStatus.connected: 'connected',
  WorkspaceStreamStatus.reconnecting: 'reconnecting',
  WorkspaceStreamStatus.error: 'error',
};
