// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$WorkspaceModelToJson(
  _WorkspaceModel instance,
) => <String, dynamic>{
  'nodeAvailability':
      _$PiNodeCompositionAvailabilityEnumMap[instance.nodeAvailability]!,
  'eventStatus': _$WorkspaceEventStatusEnumMap[instance.eventStatus]!,
  'promptAdmissionStatus':
      _$WorkspacePromptAdmissionStatusEnumMap[instance.promptAdmissionStatus]!,
  'projectLoading': instance.projectLoading,
  'projectBrowsing': instance.projectBrowsing,
  'projectValidating': instance.projectValidating,
  'projectTrustApproving': instance.projectTrustApproving,
  'sessionsLoading': instance.sessionsLoading,
  'conversationLoading': instance.conversationLoading,
  'creatingSession': instance.creatingSession,
  'sending': instance.sending,
  'stopping': instance.stopping,
  'nodeError': instance.nodeError,
  'projectError': instance.projectError,
  'sessionError': instance.sessionError,
  'conversationError': instance.conversationError,
  'promptError': instance.promptError,
  'statusMessage': instance.statusMessage,
};

const _$PiNodeCompositionAvailabilityEnumMap = {
  PiNodeCompositionAvailability.localHost: 'localHost',
  PiNodeCompositionAvailability.externalNode: 'externalNode',
  PiNodeCompositionAvailability.remoteNodeRequired: 'remoteNodeRequired',
  PiNodeCompositionAvailability.unsupported: 'unsupported',
};

const _$WorkspaceEventStatusEnumMap = {
  WorkspaceEventStatus.idle: 'idle',
  WorkspaceEventStatus.listening: 'listening',
  WorkspaceEventStatus.recovering: 'recovering',
  WorkspaceEventStatus.error: 'error',
};

const _$WorkspacePromptAdmissionStatusEnumMap = {
  WorkspacePromptAdmissionStatus.idle: 'idle',
  WorkspacePromptAdmissionStatus.accepted: 'accepted',
  WorkspacePromptAdmissionStatus.rejected: 'rejected',
  WorkspacePromptAdmissionStatus.uncertain: 'uncertain',
};
