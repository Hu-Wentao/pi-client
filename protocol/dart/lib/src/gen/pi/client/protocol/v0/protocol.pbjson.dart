// This is a generated file - do not edit.
//
// Generated from pi/client/protocol/v0/protocol.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use capabilityDescriptor instead')
const Capability$json = {
  '1': 'Capability',
  '2': [
    {'1': 'CAPABILITY_UNSPECIFIED', '2': 0},
    {'1': 'CAPABILITY_SESSION_READ', '2': 1},
    {'1': 'CAPABILITY_SESSION_CREATE', '2': 2},
    {'1': 'CAPABILITY_PROMPT_COMMAND', '2': 3},
    {'1': 'CAPABILITY_ABORT_COMMAND', '2': 4},
    {'1': 'CAPABILITY_SESSION_EVENTS', '2': 5},
    {'1': 'CAPABILITY_HEALTH', '2': 6},
    {'1': 'CAPABILITY_CANCELLATION', '2': 7},
    {'1': 'CAPABILITY_FLOW_CONTROL', '2': 8},
    {'1': 'CAPABILITY_TRANSFER', '2': 9},
    {'1': 'CAPABILITY_PROJECT_DISCOVERY', '2': 10},
    {'1': 'CAPABILITY_PROJECT_TRUST', '2': 11},
    {'1': 'CAPABILITY_SESSION_ADMIN', '2': 12},
  ],
};

/// Descriptor for `Capability`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List capabilityDescriptor = $convert.base64Decode(
    'CgpDYXBhYmlsaXR5EhoKFkNBUEFCSUxJVFlfVU5TUEVDSUZJRUQQABIbChdDQVBBQklMSVRZX1'
    'NFU1NJT05fUkVBRBABEh0KGUNBUEFCSUxJVFlfU0VTU0lPTl9DUkVBVEUQAhIdChlDQVBBQklM'
    'SVRZX1BST01QVF9DT01NQU5EEAMSHAoYQ0FQQUJJTElUWV9BQk9SVF9DT01NQU5EEAQSHQoZQ0'
    'FQQUJJTElUWV9TRVNTSU9OX0VWRU5UUxAFEhUKEUNBUEFCSUxJVFlfSEVBTFRIEAYSGwoXQ0FQ'
    'QUJJTElUWV9DQU5DRUxMQVRJT04QBxIbChdDQVBBQklMSVRZX0ZMT1dfQ09OVFJPTBAIEhcKE0'
    'NBUEFCSUxJVFlfVFJBTlNGRVIQCRIgChxDQVBBQklMSVRZX1BST0pFQ1RfRElTQ09WRVJZEAoS'
    'HAoYQ0FQQUJJTElUWV9QUk9KRUNUX1RSVVNUEAsSHAoYQ0FQQUJJTElUWV9TRVNTSU9OX0FETU'
    'lOEAw=');

@$core.Deprecated('Use healthStatusDescriptor instead')
const HealthStatus$json = {
  '1': 'HealthStatus',
  '2': [
    {'1': 'HEALTH_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'HEALTH_STATUS_STARTING', '2': 1},
    {'1': 'HEALTH_STATUS_SERVING', '2': 2},
    {'1': 'HEALTH_STATUS_DEGRADED', '2': 3},
    {'1': 'HEALTH_STATUS_STOPPING', '2': 4},
  ],
};

/// Descriptor for `HealthStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List healthStatusDescriptor = $convert.base64Decode(
    'CgxIZWFsdGhTdGF0dXMSHQoZSEVBTFRIX1NUQVRVU19VTlNQRUNJRklFRBAAEhoKFkhFQUxUSF'
    '9TVEFUVVNfU1RBUlRJTkcQARIZChVIRUFMVEhfU1RBVFVTX1NFUlZJTkcQAhIaChZIRUFMVEhf'
    'U1RBVFVTX0RFR1JBREVEEAMSGgoWSEVBTFRIX1NUQVRVU19TVE9QUElORxAE');

@$core.Deprecated('Use projectTrustStatusDescriptor instead')
const ProjectTrustStatus$json = {
  '1': 'ProjectTrustStatus',
  '2': [
    {'1': 'PROJECT_TRUST_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'PROJECT_TRUST_STATUS_NOT_REQUIRED', '2': 1},
    {'1': 'PROJECT_TRUST_STATUS_TRUSTED', '2': 2},
    {'1': 'PROJECT_TRUST_STATUS_APPROVAL_REQUIRED', '2': 3},
    {'1': 'PROJECT_TRUST_STATUS_DENIED', '2': 4},
  ],
};

/// Descriptor for `ProjectTrustStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List projectTrustStatusDescriptor = $convert.base64Decode(
    'ChJQcm9qZWN0VHJ1c3RTdGF0dXMSJAogUFJPSkVDVF9UUlVTVF9TVEFUVVNfVU5TUEVDSUZJRU'
    'QQABIlCiFQUk9KRUNUX1RSVVNUX1NUQVRVU19OT1RfUkVRVUlSRUQQARIgChxQUk9KRUNUX1RS'
    'VVNUX1NUQVRVU19UUlVTVEVEEAISKgomUFJPSkVDVF9UUlVTVF9TVEFUVVNfQVBQUk9WQUxfUk'
    'VRVUlSRUQQAxIfChtQUk9KRUNUX1RSVVNUX1NUQVRVU19ERU5JRUQQBA==');

@$core.Deprecated('Use projectTrustReasonDescriptor instead')
const ProjectTrustReason$json = {
  '1': 'ProjectTrustReason',
  '2': [
    {'1': 'PROJECT_TRUST_REASON_UNSPECIFIED', '2': 0},
    {'1': 'PROJECT_TRUST_REASON_PI_SETTINGS', '2': 1},
    {'1': 'PROJECT_TRUST_REASON_PI_EXTENSIONS', '2': 2},
    {'1': 'PROJECT_TRUST_REASON_PI_SKILLS', '2': 3},
    {'1': 'PROJECT_TRUST_REASON_PI_PROMPTS', '2': 4},
    {'1': 'PROJECT_TRUST_REASON_PI_THEMES', '2': 5},
    {'1': 'PROJECT_TRUST_REASON_PI_SYSTEM_PROMPT', '2': 6},
    {'1': 'PROJECT_TRUST_REASON_AGENT_SKILLS', '2': 7},
    {'1': 'PROJECT_TRUST_REASON_SAVED_APPROVAL', '2': 8},
    {'1': 'PROJECT_TRUST_REASON_SAVED_DENIAL', '2': 9},
  ],
};

/// Descriptor for `ProjectTrustReason`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List projectTrustReasonDescriptor = $convert.base64Decode(
    'ChJQcm9qZWN0VHJ1c3RSZWFzb24SJAogUFJPSkVDVF9UUlVTVF9SRUFTT05fVU5TUEVDSUZJRU'
    'QQABIkCiBQUk9KRUNUX1RSVVNUX1JFQVNPTl9QSV9TRVRUSU5HUxABEiYKIlBST0pFQ1RfVFJV'
    'U1RfUkVBU09OX1BJX0VYVEVOU0lPTlMQAhIiCh5QUk9KRUNUX1RSVVNUX1JFQVNPTl9QSV9TS0'
    'lMTFMQAxIjCh9QUk9KRUNUX1RSVVNUX1JFQVNPTl9QSV9QUk9NUFRTEAQSIgoeUFJPSkVDVF9U'
    'UlVTVF9SRUFTT05fUElfVEhFTUVTEAUSKQolUFJPSkVDVF9UUlVTVF9SRUFTT05fUElfU1lTVE'
    'VNX1BST01QVBAGEiUKIVBST0pFQ1RfVFJVU1RfUkVBU09OX0FHRU5UX1NLSUxMUxAHEicKI1BS'
    'T0pFQ1RfVFJVU1RfUkVBU09OX1NBVkVEX0FQUFJPVkFMEAgSJQohUFJPSkVDVF9UUlVTVF9SRU'
    'FTT05fU0FWRURfREVOSUFMEAk=');

@$core.Deprecated('Use sessionAdminOperationDescriptor instead')
const SessionAdminOperation$json = {
  '1': 'SessionAdminOperation',
  '2': [
    {'1': 'SESSION_ADMIN_OPERATION_UNSPECIFIED', '2': 0},
    {'1': 'SESSION_ADMIN_OPERATION_RENAME', '2': 1},
    {'1': 'SESSION_ADMIN_OPERATION_CLEAR_NAME', '2': 2},
    {'1': 'SESSION_ADMIN_OPERATION_AUTO_NAME', '2': 3},
    {'1': 'SESSION_ADMIN_OPERATION_DELETE', '2': 4},
  ],
};

/// Descriptor for `SessionAdminOperation`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List sessionAdminOperationDescriptor = $convert.base64Decode(
    'ChVTZXNzaW9uQWRtaW5PcGVyYXRpb24SJwojU0VTU0lPTl9BRE1JTl9PUEVSQVRJT05fVU5TUE'
    'VDSUZJRUQQABIiCh5TRVNTSU9OX0FETUlOX09QRVJBVElPTl9SRU5BTUUQARImCiJTRVNTSU9O'
    'X0FETUlOX09QRVJBVElPTl9DTEVBUl9OQU1FEAISJQohU0VTU0lPTl9BRE1JTl9PUEVSQVRJT0'
    '5fQVVUT19OQU1FEAMSIgoeU0VTU0lPTl9BRE1JTl9PUEVSQVRJT05fREVMRVRFEAQ=');

@$core.Deprecated('Use messageRoleDescriptor instead')
const MessageRole$json = {
  '1': 'MessageRole',
  '2': [
    {'1': 'MESSAGE_ROLE_UNSPECIFIED', '2': 0},
    {'1': 'MESSAGE_ROLE_USER', '2': 1},
    {'1': 'MESSAGE_ROLE_ASSISTANT', '2': 2},
    {'1': 'MESSAGE_ROLE_TOOL', '2': 3},
    {'1': 'MESSAGE_ROLE_SYSTEM', '2': 4},
  ],
};

/// Descriptor for `MessageRole`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List messageRoleDescriptor = $convert.base64Decode(
    'CgtNZXNzYWdlUm9sZRIcChhNRVNTQUdFX1JPTEVfVU5TUEVDSUZJRUQQABIVChFNRVNTQUdFX1'
    'JPTEVfVVNFUhABEhoKFk1FU1NBR0VfUk9MRV9BU1NJU1RBTlQQAhIVChFNRVNTQUdFX1JPTEVf'
    'VE9PTBADEhcKE01FU1NBR0VfUk9MRV9TWVNURU0QBA==');

@$core.Deprecated('Use transferDirectionDescriptor instead')
const TransferDirection$json = {
  '1': 'TransferDirection',
  '2': [
    {'1': 'TRANSFER_DIRECTION_UNSPECIFIED', '2': 0},
    {'1': 'TRANSFER_DIRECTION_UPLOAD', '2': 1},
    {'1': 'TRANSFER_DIRECTION_DOWNLOAD', '2': 2},
  ],
};

/// Descriptor for `TransferDirection`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List transferDirectionDescriptor = $convert.base64Decode(
    'ChFUcmFuc2ZlckRpcmVjdGlvbhIiCh5UUkFOU0ZFUl9ESVJFQ1RJT05fVU5TUEVDSUZJRUQQAB'
    'IdChlUUkFOU0ZFUl9ESVJFQ1RJT05fVVBMT0FEEAESHwobVFJBTlNGRVJfRElSRUNUSU9OX0RP'
    'V05MT0FEEAI=');

@$core.Deprecated('Use transferPurposeDescriptor instead')
const TransferPurpose$json = {
  '1': 'TransferPurpose',
  '2': [
    {'1': 'TRANSFER_PURPOSE_UNSPECIFIED', '2': 0},
    {'1': 'TRANSFER_PURPOSE_FILE', '2': 1},
    {'1': 'TRANSFER_PURPOSE_ATTACHMENT', '2': 2},
    {'1': 'TRANSFER_PURPOSE_EXPORT', '2': 3},
  ],
};

/// Descriptor for `TransferPurpose`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List transferPurposeDescriptor = $convert.base64Decode(
    'Cg9UcmFuc2ZlclB1cnBvc2USIAocVFJBTlNGRVJfUFVSUE9TRV9VTlNQRUNJRklFRBAAEhkKFV'
    'RSQU5TRkVSX1BVUlBPU0VfRklMRRABEh8KG1RSQU5TRkVSX1BVUlBPU0VfQVRUQUNITUVOVBAC'
    'EhsKF1RSQU5TRkVSX1BVUlBPU0VfRVhQT1JUEAM=');

@$core.Deprecated('Use errorCodeDescriptor instead')
const ErrorCode$json = {
  '1': 'ErrorCode',
  '2': [
    {'1': 'ERROR_CODE_UNSPECIFIED', '2': 0},
    {'1': 'ERROR_CODE_AUTHENTICATION_REQUIRED', '2': 1},
    {'1': 'ERROR_CODE_PERMISSION_DENIED', '2': 2},
    {'1': 'ERROR_CODE_NOT_FOUND', '2': 3},
    {'1': 'ERROR_CODE_INVALID_REQUEST', '2': 4},
    {'1': 'ERROR_CODE_CONFLICT', '2': 5},
    {'1': 'ERROR_CODE_NODE_BUSY', '2': 6},
    {'1': 'ERROR_CODE_PROTOCOL_VERSION_UNSUPPORTED', '2': 7},
    {'1': 'ERROR_CODE_CANCELLED', '2': 8},
    {'1': 'ERROR_CODE_DEADLINE_EXCEEDED', '2': 9},
    {'1': 'ERROR_CODE_UNAVAILABLE', '2': 10},
    {'1': 'ERROR_CODE_DATA_LOSS', '2': 11},
    {'1': 'ERROR_CODE_INTERNAL', '2': 12},
    {'1': 'ERROR_CODE_PROTOCOL_VIOLATION', '2': 13},
    {'1': 'ERROR_CODE_RESOURCE_EXHAUSTED', '2': 14},
    {'1': 'ERROR_CODE_ALREADY_EXISTS', '2': 15},
    {'1': 'ERROR_CODE_FAILED_PRECONDITION', '2': 16},
  ],
};

/// Descriptor for `ErrorCode`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List errorCodeDescriptor = $convert.base64Decode(
    'CglFcnJvckNvZGUSGgoWRVJST1JfQ09ERV9VTlNQRUNJRklFRBAAEiYKIkVSUk9SX0NPREVfQV'
    'VUSEVOVElDQVRJT05fUkVRVUlSRUQQARIgChxFUlJPUl9DT0RFX1BFUk1JU1NJT05fREVOSUVE'
    'EAISGAoURVJST1JfQ09ERV9OT1RfRk9VTkQQAxIeChpFUlJPUl9DT0RFX0lOVkFMSURfUkVRVU'
    'VTVBAEEhcKE0VSUk9SX0NPREVfQ09ORkxJQ1QQBRIYChRFUlJPUl9DT0RFX05PREVfQlVTWRAG'
    'EisKJ0VSUk9SX0NPREVfUFJPVE9DT0xfVkVSU0lPTl9VTlNVUFBPUlRFRBAHEhgKFEVSUk9SX0'
    'NPREVfQ0FOQ0VMTEVEEAgSIAocRVJST1JfQ09ERV9ERUFETElORV9FWENFRURFRBAJEhoKFkVS'
    'Uk9SX0NPREVfVU5BVkFJTEFCTEUQChIYChRFUlJPUl9DT0RFX0RBVEFfTE9TUxALEhcKE0VSUk'
    '9SX0NPREVfSU5URVJOQUwQDBIhCh1FUlJPUl9DT0RFX1BST1RPQ09MX1ZJT0xBVElPThANEiEK'
    'HUVSUk9SX0NPREVfUkVTT1VSQ0VfRVhIQVVTVEVEEA4SHQoZRVJST1JfQ09ERV9BTFJFQURZX0'
    'VYSVNUUxAPEiIKHkVSUk9SX0NPREVfRkFJTEVEX1BSRUNPTkRJVElPThAQ');

@$core.Deprecated('Use piTransportFrameDescriptor instead')
const PiTransportFrame$json = {
  '1': 'PiTransportFrame',
  '2': [
    {'1': 'frame_sequence', '3': 1, '4': 1, '5': 4, '10': 'frameSequence'},
    {
      '1': 'client_protocol_offer',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.ClientProtocolOffer',
      '9': 0,
      '10': 'clientProtocolOffer'
    },
    {
      '1': 'server_handshake_accepted',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.ServerHandshakeAccepted',
      '9': 0,
      '10': 'serverHandshakeAccepted'
    },
    {
      '1': 'server_handshake_rejected',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.ServerHandshakeRejected',
      '9': 0,
      '10': 'serverHandshakeRejected'
    },
    {
      '1': 'health_request',
      '3': 20,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.HealthRequest',
      '9': 0,
      '10': 'healthRequest'
    },
    {
      '1': 'health_response',
      '3': 21,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.HealthResponse',
      '9': 0,
      '10': 'healthResponse'
    },
    {
      '1': 'get_project_bootstrap_request',
      '3': 22,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.GetProjectBootstrapRequest',
      '9': 0,
      '10': 'getProjectBootstrapRequest'
    },
    {
      '1': 'get_project_bootstrap_response',
      '3': 23,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.GetProjectBootstrapResponse',
      '9': 0,
      '10': 'getProjectBootstrapResponse'
    },
    {
      '1': 'browse_directory_request',
      '3': 24,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.BrowseDirectoryRequest',
      '9': 0,
      '10': 'browseDirectoryRequest'
    },
    {
      '1': 'browse_directory_response',
      '3': 25,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.BrowseDirectoryResponse',
      '9': 0,
      '10': 'browseDirectoryResponse'
    },
    {
      '1': 'validate_project_request',
      '3': 26,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.ValidateProjectRequest',
      '9': 0,
      '10': 'validateProjectRequest'
    },
    {
      '1': 'validate_project_response',
      '3': 27,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.ValidateProjectResponse',
      '9': 0,
      '10': 'validateProjectResponse'
    },
    {
      '1': 'list_known_projects_request',
      '3': 28,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.ListKnownProjectsRequest',
      '9': 0,
      '10': 'listKnownProjectsRequest'
    },
    {
      '1': 'list_known_projects_response',
      '3': 29,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.ListKnownProjectsResponse',
      '9': 0,
      '10': 'listKnownProjectsResponse'
    },
    {
      '1': 'list_sessions_request',
      '3': 30,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.ListSessionsRequest',
      '9': 0,
      '10': 'listSessionsRequest'
    },
    {
      '1': 'list_sessions_response',
      '3': 31,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.ListSessionsResponse',
      '9': 0,
      '10': 'listSessionsResponse'
    },
    {
      '1': 'get_session_request',
      '3': 32,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.GetSessionRequest',
      '9': 0,
      '10': 'getSessionRequest'
    },
    {
      '1': 'get_session_response',
      '3': 33,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.GetSessionResponse',
      '9': 0,
      '10': 'getSessionResponse'
    },
    {
      '1': 'create_session_request',
      '3': 34,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.CreateSessionRequest',
      '9': 0,
      '10': 'createSessionRequest'
    },
    {
      '1': 'create_session_response',
      '3': 35,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.CreateSessionResponse',
      '9': 0,
      '10': 'createSessionResponse'
    },
    {
      '1': 'prompt_command',
      '3': 36,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.PromptCommand',
      '9': 0,
      '10': 'promptCommand'
    },
    {
      '1': 'abort_command',
      '3': 37,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.AbortCommand',
      '9': 0,
      '10': 'abortCommand'
    },
    {
      '1': 'request_rejected',
      '3': 38,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.RequestRejected',
      '9': 0,
      '10': 'requestRejected'
    },
    {
      '1': 'command_accepted',
      '3': 39,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.CommandAccepted',
      '9': 0,
      '10': 'commandAccepted'
    },
    {
      '1': 'command_rejected',
      '3': 40,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.CommandRejected',
      '9': 0,
      '10': 'commandRejected'
    },
    {
      '1': 'approve_project_trust_request',
      '3': 41,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.ApproveProjectTrustRequest',
      '9': 0,
      '10': 'approveProjectTrustRequest'
    },
    {
      '1': 'approve_project_trust_response',
      '3': 42,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.ApproveProjectTrustResponse',
      '9': 0,
      '10': 'approveProjectTrustResponse'
    },
    {
      '1': 'rename_session_command',
      '3': 43,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.RenameSessionCommand',
      '9': 0,
      '10': 'renameSessionCommand'
    },
    {
      '1': 'clear_session_name_command',
      '3': 44,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.ClearSessionNameCommand',
      '9': 0,
      '10': 'clearSessionNameCommand'
    },
    {
      '1': 'auto_name_session_command',
      '3': 45,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.AutoNameSessionCommand',
      '9': 0,
      '10': 'autoNameSessionCommand'
    },
    {
      '1': 'delete_session_command',
      '3': 46,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.DeleteSessionCommand',
      '9': 0,
      '10': 'deleteSessionCommand'
    },
    {
      '1': 'session_admin_command_outcome',
      '3': 47,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.SessionAdminCommandOutcome',
      '9': 0,
      '10': 'sessionAdminCommandOutcome'
    },
    {
      '1': 'session_event_stream',
      '3': 50,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.SessionEventStreamEnvelope',
      '9': 0,
      '10': 'sessionEventStream'
    },
    {
      '1': 'event_stream',
      '3': 51,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.EventStreamEnvelope',
      '9': 0,
      '10': 'eventStream'
    },
    {
      '1': 'cancel',
      '3': 60,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.Cancel',
      '9': 0,
      '10': 'cancel'
    },
    {
      '1': 'window_update',
      '3': 61,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.WindowUpdate',
      '9': 0,
      '10': 'windowUpdate'
    },
    {
      '1': 'transfer_open',
      '3': 70,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.TransferOpen',
      '9': 0,
      '10': 'transferOpen'
    },
    {
      '1': 'transfer_chunk',
      '3': 71,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.TransferChunk',
      '9': 0,
      '10': 'transferChunk'
    },
    {
      '1': 'transfer_ack',
      '3': 72,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.TransferAck',
      '9': 0,
      '10': 'transferAck'
    },
    {
      '1': 'transfer_complete',
      '3': 73,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.TransferComplete',
      '9': 0,
      '10': 'transferComplete'
    },
    {
      '1': 'transfer_abort',
      '3': 74,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.TransferAbort',
      '9': 0,
      '10': 'transferAbort'
    },
    {
      '1': 'error',
      '3': 80,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.ErrorEnvelope',
      '9': 0,
      '10': 'error'
    },
  ],
  '8': [
    {'1': 'operation'},
  ],
  '9': [
    {'1': 2, '2': 10},
    {'1': 13, '2': 20},
    {'1': 48, '2': 50},
    {'1': 52, '2': 60},
    {'1': 62, '2': 70},
    {'1': 75, '2': 80},
    {'1': 81, '2': 100},
  ],
};

/// Descriptor for `PiTransportFrame`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List piTransportFrameDescriptor = $convert.base64Decode(
    'ChBQaVRyYW5zcG9ydEZyYW1lEiUKDmZyYW1lX3NlcXVlbmNlGAEgASgEUg1mcmFtZVNlcXVlbm'
    'NlEmAKFWNsaWVudF9wcm90b2NvbF9vZmZlchgKIAEoCzIqLnBpLmNsaWVudC5wcm90b2NvbC52'
    'MC5DbGllbnRQcm90b2NvbE9mZmVySABSE2NsaWVudFByb3RvY29sT2ZmZXISbAoZc2VydmVyX2'
    'hhbmRzaGFrZV9hY2NlcHRlZBgLIAEoCzIuLnBpLmNsaWVudC5wcm90b2NvbC52MC5TZXJ2ZXJI'
    'YW5kc2hha2VBY2NlcHRlZEgAUhdzZXJ2ZXJIYW5kc2hha2VBY2NlcHRlZBJsChlzZXJ2ZXJfaG'
    'FuZHNoYWtlX3JlamVjdGVkGAwgASgLMi4ucGkuY2xpZW50LnByb3RvY29sLnYwLlNlcnZlckhh'
    'bmRzaGFrZVJlamVjdGVkSABSF3NlcnZlckhhbmRzaGFrZVJlamVjdGVkEk0KDmhlYWx0aF9yZX'
    'F1ZXN0GBQgASgLMiQucGkuY2xpZW50LnByb3RvY29sLnYwLkhlYWx0aFJlcXVlc3RIAFINaGVh'
    'bHRoUmVxdWVzdBJQCg9oZWFsdGhfcmVzcG9uc2UYFSABKAsyJS5waS5jbGllbnQucHJvdG9jb2'
    'wudjAuSGVhbHRoUmVzcG9uc2VIAFIOaGVhbHRoUmVzcG9uc2USdgodZ2V0X3Byb2plY3RfYm9v'
    'dHN0cmFwX3JlcXVlc3QYFiABKAsyMS5waS5jbGllbnQucHJvdG9jb2wudjAuR2V0UHJvamVjdE'
    'Jvb3RzdHJhcFJlcXVlc3RIAFIaZ2V0UHJvamVjdEJvb3RzdHJhcFJlcXVlc3QSeQoeZ2V0X3By'
    'b2plY3RfYm9vdHN0cmFwX3Jlc3BvbnNlGBcgASgLMjIucGkuY2xpZW50LnByb3RvY29sLnYwLk'
    'dldFByb2plY3RCb290c3RyYXBSZXNwb25zZUgAUhtnZXRQcm9qZWN0Qm9vdHN0cmFwUmVzcG9u'
    'c2USaQoYYnJvd3NlX2RpcmVjdG9yeV9yZXF1ZXN0GBggASgLMi0ucGkuY2xpZW50LnByb3RvY2'
    '9sLnYwLkJyb3dzZURpcmVjdG9yeVJlcXVlc3RIAFIWYnJvd3NlRGlyZWN0b3J5UmVxdWVzdBJs'
    'Chlicm93c2VfZGlyZWN0b3J5X3Jlc3BvbnNlGBkgASgLMi4ucGkuY2xpZW50LnByb3RvY29sLn'
    'YwLkJyb3dzZURpcmVjdG9yeVJlc3BvbnNlSABSF2Jyb3dzZURpcmVjdG9yeVJlc3BvbnNlEmkK'
    'GHZhbGlkYXRlX3Byb2plY3RfcmVxdWVzdBgaIAEoCzItLnBpLmNsaWVudC5wcm90b2NvbC52MC'
    '5WYWxpZGF0ZVByb2plY3RSZXF1ZXN0SABSFnZhbGlkYXRlUHJvamVjdFJlcXVlc3QSbAoZdmFs'
    'aWRhdGVfcHJvamVjdF9yZXNwb25zZRgbIAEoCzIuLnBpLmNsaWVudC5wcm90b2NvbC52MC5WYW'
    'xpZGF0ZVByb2plY3RSZXNwb25zZUgAUhd2YWxpZGF0ZVByb2plY3RSZXNwb25zZRJwChtsaXN0'
    'X2tub3duX3Byb2plY3RzX3JlcXVlc3QYHCABKAsyLy5waS5jbGllbnQucHJvdG9jb2wudjAuTG'
    'lzdEtub3duUHJvamVjdHNSZXF1ZXN0SABSGGxpc3RLbm93blByb2plY3RzUmVxdWVzdBJzChxs'
    'aXN0X2tub3duX3Byb2plY3RzX3Jlc3BvbnNlGB0gASgLMjAucGkuY2xpZW50LnByb3RvY29sLn'
    'YwLkxpc3RLbm93blByb2plY3RzUmVzcG9uc2VIAFIZbGlzdEtub3duUHJvamVjdHNSZXNwb25z'
    'ZRJgChVsaXN0X3Nlc3Npb25zX3JlcXVlc3QYHiABKAsyKi5waS5jbGllbnQucHJvdG9jb2wudj'
    'AuTGlzdFNlc3Npb25zUmVxdWVzdEgAUhNsaXN0U2Vzc2lvbnNSZXF1ZXN0EmMKFmxpc3Rfc2Vz'
    'c2lvbnNfcmVzcG9uc2UYHyABKAsyKy5waS5jbGllbnQucHJvdG9jb2wudjAuTGlzdFNlc3Npb2'
    '5zUmVzcG9uc2VIAFIUbGlzdFNlc3Npb25zUmVzcG9uc2USWgoTZ2V0X3Nlc3Npb25fcmVxdWVz'
    'dBggIAEoCzIoLnBpLmNsaWVudC5wcm90b2NvbC52MC5HZXRTZXNzaW9uUmVxdWVzdEgAUhFnZX'
    'RTZXNzaW9uUmVxdWVzdBJdChRnZXRfc2Vzc2lvbl9yZXNwb25zZRghIAEoCzIpLnBpLmNsaWVu'
    'dC5wcm90b2NvbC52MC5HZXRTZXNzaW9uUmVzcG9uc2VIAFISZ2V0U2Vzc2lvblJlc3BvbnNlEm'
    'MKFmNyZWF0ZV9zZXNzaW9uX3JlcXVlc3QYIiABKAsyKy5waS5jbGllbnQucHJvdG9jb2wudjAu'
    'Q3JlYXRlU2Vzc2lvblJlcXVlc3RIAFIUY3JlYXRlU2Vzc2lvblJlcXVlc3QSZgoXY3JlYXRlX3'
    'Nlc3Npb25fcmVzcG9uc2UYIyABKAsyLC5waS5jbGllbnQucHJvdG9jb2wudjAuQ3JlYXRlU2Vz'
    'c2lvblJlc3BvbnNlSABSFWNyZWF0ZVNlc3Npb25SZXNwb25zZRJNCg5wcm9tcHRfY29tbWFuZB'
    'gkIAEoCzIkLnBpLmNsaWVudC5wcm90b2NvbC52MC5Qcm9tcHRDb21tYW5kSABSDXByb21wdENv'
    'bW1hbmQSSgoNYWJvcnRfY29tbWFuZBglIAEoCzIjLnBpLmNsaWVudC5wcm90b2NvbC52MC5BYm'
    '9ydENvbW1hbmRIAFIMYWJvcnRDb21tYW5kElMKEHJlcXVlc3RfcmVqZWN0ZWQYJiABKAsyJi5w'
    'aS5jbGllbnQucHJvdG9jb2wudjAuUmVxdWVzdFJlamVjdGVkSABSD3JlcXVlc3RSZWplY3RlZB'
    'JTChBjb21tYW5kX2FjY2VwdGVkGCcgASgLMiYucGkuY2xpZW50LnByb3RvY29sLnYwLkNvbW1h'
    'bmRBY2NlcHRlZEgAUg9jb21tYW5kQWNjZXB0ZWQSUwoQY29tbWFuZF9yZWplY3RlZBgoIAEoCz'
    'ImLnBpLmNsaWVudC5wcm90b2NvbC52MC5Db21tYW5kUmVqZWN0ZWRIAFIPY29tbWFuZFJlamVj'
    'dGVkEnYKHWFwcHJvdmVfcHJvamVjdF90cnVzdF9yZXF1ZXN0GCkgASgLMjEucGkuY2xpZW50Ln'
    'Byb3RvY29sLnYwLkFwcHJvdmVQcm9qZWN0VHJ1c3RSZXF1ZXN0SABSGmFwcHJvdmVQcm9qZWN0'
    'VHJ1c3RSZXF1ZXN0EnkKHmFwcHJvdmVfcHJvamVjdF90cnVzdF9yZXNwb25zZRgqIAEoCzIyLn'
    'BpLmNsaWVudC5wcm90b2NvbC52MC5BcHByb3ZlUHJvamVjdFRydXN0UmVzcG9uc2VIAFIbYXBw'
    'cm92ZVByb2plY3RUcnVzdFJlc3BvbnNlEmMKFnJlbmFtZV9zZXNzaW9uX2NvbW1hbmQYKyABKA'
    'syKy5waS5jbGllbnQucHJvdG9jb2wudjAuUmVuYW1lU2Vzc2lvbkNvbW1hbmRIAFIUcmVuYW1l'
    'U2Vzc2lvbkNvbW1hbmQSbQoaY2xlYXJfc2Vzc2lvbl9uYW1lX2NvbW1hbmQYLCABKAsyLi5waS'
    '5jbGllbnQucHJvdG9jb2wudjAuQ2xlYXJTZXNzaW9uTmFtZUNvbW1hbmRIAFIXY2xlYXJTZXNz'
    'aW9uTmFtZUNvbW1hbmQSagoZYXV0b19uYW1lX3Nlc3Npb25fY29tbWFuZBgtIAEoCzItLnBpLm'
    'NsaWVudC5wcm90b2NvbC52MC5BdXRvTmFtZVNlc3Npb25Db21tYW5kSABSFmF1dG9OYW1lU2Vz'
    'c2lvbkNvbW1hbmQSYwoWZGVsZXRlX3Nlc3Npb25fY29tbWFuZBguIAEoCzIrLnBpLmNsaWVudC'
    '5wcm90b2NvbC52MC5EZWxldGVTZXNzaW9uQ29tbWFuZEgAUhRkZWxldGVTZXNzaW9uQ29tbWFu'
    'ZBJ2Ch1zZXNzaW9uX2FkbWluX2NvbW1hbmRfb3V0Y29tZRgvIAEoCzIxLnBpLmNsaWVudC5wcm'
    '90b2NvbC52MC5TZXNzaW9uQWRtaW5Db21tYW5kT3V0Y29tZUgAUhpzZXNzaW9uQWRtaW5Db21t'
    'YW5kT3V0Y29tZRJlChRzZXNzaW9uX2V2ZW50X3N0cmVhbRgyIAEoCzIxLnBpLmNsaWVudC5wcm'
    '90b2NvbC52MC5TZXNzaW9uRXZlbnRTdHJlYW1FbnZlbG9wZUgAUhJzZXNzaW9uRXZlbnRTdHJl'
    'YW0STwoMZXZlbnRfc3RyZWFtGDMgASgLMioucGkuY2xpZW50LnByb3RvY29sLnYwLkV2ZW50U3'
    'RyZWFtRW52ZWxvcGVIAFILZXZlbnRTdHJlYW0SNwoGY2FuY2VsGDwgASgLMh0ucGkuY2xpZW50'
    'LnByb3RvY29sLnYwLkNhbmNlbEgAUgZjYW5jZWwSSgoNd2luZG93X3VwZGF0ZRg9IAEoCzIjLn'
    'BpLmNsaWVudC5wcm90b2NvbC52MC5XaW5kb3dVcGRhdGVIAFIMd2luZG93VXBkYXRlEkoKDXRy'
    'YW5zZmVyX29wZW4YRiABKAsyIy5waS5jbGllbnQucHJvdG9jb2wudjAuVHJhbnNmZXJPcGVuSA'
    'BSDHRyYW5zZmVyT3BlbhJNCg50cmFuc2Zlcl9jaHVuaxhHIAEoCzIkLnBpLmNsaWVudC5wcm90'
    'b2NvbC52MC5UcmFuc2ZlckNodW5rSABSDXRyYW5zZmVyQ2h1bmsSRwoMdHJhbnNmZXJfYWNrGE'
    'ggASgLMiIucGkuY2xpZW50LnByb3RvY29sLnYwLlRyYW5zZmVyQWNrSABSC3RyYW5zZmVyQWNr'
    'ElYKEXRyYW5zZmVyX2NvbXBsZXRlGEkgASgLMicucGkuY2xpZW50LnByb3RvY29sLnYwLlRyYW'
    '5zZmVyQ29tcGxldGVIAFIQdHJhbnNmZXJDb21wbGV0ZRJNCg50cmFuc2Zlcl9hYm9ydBhKIAEo'
    'CzIkLnBpLmNsaWVudC5wcm90b2NvbC52MC5UcmFuc2ZlckFib3J0SABSDXRyYW5zZmVyQWJvcn'
    'QSPAoFZXJyb3IYUCABKAsyJC5waS5jbGllbnQucHJvdG9jb2wudjAuRXJyb3JFbnZlbG9wZUgA'
    'UgVlcnJvckILCglvcGVyYXRpb25KBAgCEApKBAgNEBRKBAgwEDJKBAg0EDxKBAg+EEZKBAhLEF'
    'BKBAhREGQ=');

@$core.Deprecated('Use protocolVersionDescriptor instead')
const ProtocolVersion$json = {
  '1': 'ProtocolVersion',
  '2': [
    {'1': 'major', '3': 1, '4': 1, '5': 13, '10': 'major'},
    {'1': 'minor', '3': 2, '4': 1, '5': 13, '10': 'minor'},
    {'1': 'patch', '3': 3, '4': 1, '5': 13, '10': 'patch'},
  ],
};

/// Descriptor for `ProtocolVersion`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List protocolVersionDescriptor = $convert.base64Decode(
    'Cg9Qcm90b2NvbFZlcnNpb24SFAoFbWFqb3IYASABKA1SBW1ham9yEhQKBW1pbm9yGAIgASgNUg'
    'VtaW5vchIUCgVwYXRjaBgDIAEoDVIFcGF0Y2g=');

@$core.Deprecated('Use clientProtocolOfferDescriptor instead')
const ClientProtocolOffer$json = {
  '1': 'ClientProtocolOffer',
  '2': [
    {
      '1': 'protocol_versions',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.pi.client.protocol.v0.ProtocolVersion',
      '10': 'protocolVersions'
    },
    {
      '1': 'capabilities',
      '3': 2,
      '4': 3,
      '5': 14,
      '6': '.pi.client.protocol.v0.Capability',
      '10': 'capabilities'
    },
    {
      '1': 'client_instance_id',
      '3': 3,
      '4': 1,
      '5': 9,
      '10': 'clientInstanceId'
    },
    {
      '1': 'implementation_name',
      '3': 4,
      '4': 1,
      '5': 9,
      '10': 'implementationName'
    },
    {
      '1': 'implementation_version',
      '3': 5,
      '4': 1,
      '5': 9,
      '10': 'implementationVersion'
    },
    {'1': 'max_frame_bytes', '3': 6, '4': 1, '5': 13, '10': 'maxFrameBytes'},
    {
      '1': 'max_transfer_chunk_bytes',
      '3': 7,
      '4': 1,
      '5': 13,
      '10': 'maxTransferChunkBytes'
    },
  ],
};

/// Descriptor for `ClientProtocolOffer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clientProtocolOfferDescriptor = $convert.base64Decode(
    'ChNDbGllbnRQcm90b2NvbE9mZmVyElMKEXByb3RvY29sX3ZlcnNpb25zGAEgAygLMiYucGkuY2'
    'xpZW50LnByb3RvY29sLnYwLlByb3RvY29sVmVyc2lvblIQcHJvdG9jb2xWZXJzaW9ucxJFCgxj'
    'YXBhYmlsaXRpZXMYAiADKA4yIS5waS5jbGllbnQucHJvdG9jb2wudjAuQ2FwYWJpbGl0eVIMY2'
    'FwYWJpbGl0aWVzEiwKEmNsaWVudF9pbnN0YW5jZV9pZBgDIAEoCVIQY2xpZW50SW5zdGFuY2VJ'
    'ZBIvChNpbXBsZW1lbnRhdGlvbl9uYW1lGAQgASgJUhJpbXBsZW1lbnRhdGlvbk5hbWUSNQoWaW'
    '1wbGVtZW50YXRpb25fdmVyc2lvbhgFIAEoCVIVaW1wbGVtZW50YXRpb25WZXJzaW9uEiYKD21h'
    'eF9mcmFtZV9ieXRlcxgGIAEoDVINbWF4RnJhbWVCeXRlcxI3ChhtYXhfdHJhbnNmZXJfY2h1bm'
    'tfYnl0ZXMYByABKA1SFW1heFRyYW5zZmVyQ2h1bmtCeXRlcw==');

@$core.Deprecated('Use serverHandshakeAcceptedDescriptor instead')
const ServerHandshakeAccepted$json = {
  '1': 'ServerHandshakeAccepted',
  '2': [
    {
      '1': 'selected_protocol_version',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.ProtocolVersion',
      '10': 'selectedProtocolVersion'
    },
    {
      '1': 'capabilities',
      '3': 2,
      '4': 3,
      '5': 14,
      '6': '.pi.client.protocol.v0.Capability',
      '10': 'capabilities'
    },
    {'1': 'node_instance_id', '3': 3, '4': 1, '5': 9, '10': 'nodeInstanceId'},
    {
      '1': 'implementation_name',
      '3': 4,
      '4': 1,
      '5': 9,
      '10': 'implementationName'
    },
    {
      '1': 'implementation_version',
      '3': 5,
      '4': 1,
      '5': 9,
      '10': 'implementationVersion'
    },
    {'1': 'max_frame_bytes', '3': 6, '4': 1, '5': 13, '10': 'maxFrameBytes'},
    {
      '1': 'max_transfer_chunk_bytes',
      '3': 7,
      '4': 1,
      '5': 13,
      '10': 'maxTransferChunkBytes'
    },
  ],
};

/// Descriptor for `ServerHandshakeAccepted`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List serverHandshakeAcceptedDescriptor = $convert.base64Decode(
    'ChdTZXJ2ZXJIYW5kc2hha2VBY2NlcHRlZBJiChlzZWxlY3RlZF9wcm90b2NvbF92ZXJzaW9uGA'
    'EgASgLMiYucGkuY2xpZW50LnByb3RvY29sLnYwLlByb3RvY29sVmVyc2lvblIXc2VsZWN0ZWRQ'
    'cm90b2NvbFZlcnNpb24SRQoMY2FwYWJpbGl0aWVzGAIgAygOMiEucGkuY2xpZW50LnByb3RvY2'
    '9sLnYwLkNhcGFiaWxpdHlSDGNhcGFiaWxpdGllcxIoChBub2RlX2luc3RhbmNlX2lkGAMgASgJ'
    'Ug5ub2RlSW5zdGFuY2VJZBIvChNpbXBsZW1lbnRhdGlvbl9uYW1lGAQgASgJUhJpbXBsZW1lbn'
    'RhdGlvbk5hbWUSNQoWaW1wbGVtZW50YXRpb25fdmVyc2lvbhgFIAEoCVIVaW1wbGVtZW50YXRp'
    'b25WZXJzaW9uEiYKD21heF9mcmFtZV9ieXRlcxgGIAEoDVINbWF4RnJhbWVCeXRlcxI3ChhtYX'
    'hfdHJhbnNmZXJfY2h1bmtfYnl0ZXMYByABKA1SFW1heFRyYW5zZmVyQ2h1bmtCeXRlcw==');

@$core.Deprecated('Use serverHandshakeRejectedDescriptor instead')
const ServerHandshakeRejected$json = {
  '1': 'ServerHandshakeRejected',
  '2': [
    {
      '1': 'error',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.StableError',
      '10': 'error'
    },
    {
      '1': 'supported_protocol_versions',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.pi.client.protocol.v0.ProtocolVersion',
      '10': 'supportedProtocolVersions'
    },
  ],
};

/// Descriptor for `ServerHandshakeRejected`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List serverHandshakeRejectedDescriptor = $convert.base64Decode(
    'ChdTZXJ2ZXJIYW5kc2hha2VSZWplY3RlZBI4CgVlcnJvchgBIAEoCzIiLnBpLmNsaWVudC5wcm'
    '90b2NvbC52MC5TdGFibGVFcnJvclIFZXJyb3ISZgobc3VwcG9ydGVkX3Byb3RvY29sX3ZlcnNp'
    'b25zGAIgAygLMiYucGkuY2xpZW50LnByb3RvY29sLnYwLlByb3RvY29sVmVyc2lvblIZc3VwcG'
    '9ydGVkUHJvdG9jb2xWZXJzaW9ucw==');

@$core.Deprecated('Use healthRequestDescriptor instead')
const HealthRequest$json = {
  '1': 'HealthRequest',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 4, '10': 'requestId'},
    {
      '1': 'include_build_info',
      '3': 2,
      '4': 1,
      '5': 8,
      '10': 'includeBuildInfo'
    },
  ],
};

/// Descriptor for `HealthRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List healthRequestDescriptor = $convert.base64Decode(
    'Cg1IZWFsdGhSZXF1ZXN0Eh0KCnJlcXVlc3RfaWQYASABKARSCXJlcXVlc3RJZBIsChJpbmNsdW'
    'RlX2J1aWxkX2luZm8YAiABKAhSEGluY2x1ZGVCdWlsZEluZm8=');

@$core.Deprecated('Use healthResponseDescriptor instead')
const HealthResponse$json = {
  '1': 'HealthResponse',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 4, '10': 'requestId'},
    {
      '1': 'status',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.pi.client.protocol.v0.HealthStatus',
      '10': 'status'
    },
    {'1': 'node_version', '3': 3, '4': 1, '5': 9, '10': 'nodeVersion'},
    {'1': 'uptime_millis', '3': 4, '4': 1, '5': 4, '10': 'uptimeMillis'},
  ],
};

/// Descriptor for `HealthResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List healthResponseDescriptor = $convert.base64Decode(
    'Cg5IZWFsdGhSZXNwb25zZRIdCgpyZXF1ZXN0X2lkGAEgASgEUglyZXF1ZXN0SWQSOwoGc3RhdH'
    'VzGAIgASgOMiMucGkuY2xpZW50LnByb3RvY29sLnYwLkhlYWx0aFN0YXR1c1IGc3RhdHVzEiEK'
    'DG5vZGVfdmVyc2lvbhgDIAEoCVILbm9kZVZlcnNpb24SIwoNdXB0aW1lX21pbGxpcxgEIAEoBF'
    'IMdXB0aW1lTWlsbGlz');

@$core.Deprecated('Use getProjectBootstrapRequestDescriptor instead')
const GetProjectBootstrapRequest$json = {
  '1': 'GetProjectBootstrapRequest',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 4, '10': 'requestId'},
  ],
};

/// Descriptor for `GetProjectBootstrapRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getProjectBootstrapRequestDescriptor =
    $convert.base64Decode(
        'ChpHZXRQcm9qZWN0Qm9vdHN0cmFwUmVxdWVzdBIdCgpyZXF1ZXN0X2lkGAEgASgEUglyZXF1ZX'
        'N0SWQ=');

@$core.Deprecated('Use getProjectBootstrapResponseDescriptor instead')
const GetProjectBootstrapResponse$json = {
  '1': 'GetProjectBootstrapResponse',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 4, '10': 'requestId'},
    {'1': 'home_directory', '3': 2, '4': 1, '5': 9, '10': 'homeDirectory'},
    {
      '1': 'default_project',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.ProjectSnapshot',
      '10': 'defaultProject'
    },
  ],
};

/// Descriptor for `GetProjectBootstrapResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getProjectBootstrapResponseDescriptor = $convert.base64Decode(
    'ChtHZXRQcm9qZWN0Qm9vdHN0cmFwUmVzcG9uc2USHQoKcmVxdWVzdF9pZBgBIAEoBFIJcmVxdW'
    'VzdElkEiUKDmhvbWVfZGlyZWN0b3J5GAIgASgJUg1ob21lRGlyZWN0b3J5Ek8KD2RlZmF1bHRf'
    'cHJvamVjdBgDIAEoCzImLnBpLmNsaWVudC5wcm90b2NvbC52MC5Qcm9qZWN0U25hcHNob3RSDm'
    'RlZmF1bHRQcm9qZWN0');

@$core.Deprecated('Use browseDirectoryRequestDescriptor instead')
const BrowseDirectoryRequest$json = {
  '1': 'BrowseDirectoryRequest',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 4, '10': 'requestId'},
    {'1': 'directory', '3': 2, '4': 1, '5': 9, '10': 'directory'},
    {'1': 'max_children', '3': 3, '4': 1, '5': 13, '10': 'maxChildren'},
  ],
};

/// Descriptor for `BrowseDirectoryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List browseDirectoryRequestDescriptor = $convert.base64Decode(
    'ChZCcm93c2VEaXJlY3RvcnlSZXF1ZXN0Eh0KCnJlcXVlc3RfaWQYASABKARSCXJlcXVlc3RJZB'
    'IcCglkaXJlY3RvcnkYAiABKAlSCWRpcmVjdG9yeRIhCgxtYXhfY2hpbGRyZW4YAyABKA1SC21h'
    'eENoaWxkcmVu');

@$core.Deprecated('Use browseDirectoryResponseDescriptor instead')
const BrowseDirectoryResponse$json = {
  '1': 'BrowseDirectoryResponse',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 4, '10': 'requestId'},
    {
      '1': 'directory',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.DirectoryListingSnapshot',
      '10': 'directory'
    },
  ],
};

/// Descriptor for `BrowseDirectoryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List browseDirectoryResponseDescriptor = $convert.base64Decode(
    'ChdCcm93c2VEaXJlY3RvcnlSZXNwb25zZRIdCgpyZXF1ZXN0X2lkGAEgASgEUglyZXF1ZXN0SW'
    'QSTQoJZGlyZWN0b3J5GAIgASgLMi8ucGkuY2xpZW50LnByb3RvY29sLnYwLkRpcmVjdG9yeUxp'
    'c3RpbmdTbmFwc2hvdFIJZGlyZWN0b3J5');

@$core.Deprecated('Use validateProjectRequestDescriptor instead')
const ValidateProjectRequest$json = {
  '1': 'ValidateProjectRequest',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 4, '10': 'requestId'},
    {
      '1': 'candidate_directory',
      '3': 2,
      '4': 1,
      '5': 9,
      '10': 'candidateDirectory'
    },
  ],
};

/// Descriptor for `ValidateProjectRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List validateProjectRequestDescriptor =
    $convert.base64Decode(
        'ChZWYWxpZGF0ZVByb2plY3RSZXF1ZXN0Eh0KCnJlcXVlc3RfaWQYASABKARSCXJlcXVlc3RJZB'
        'IvChNjYW5kaWRhdGVfZGlyZWN0b3J5GAIgASgJUhJjYW5kaWRhdGVEaXJlY3Rvcnk=');

@$core.Deprecated('Use validateProjectResponseDescriptor instead')
const ValidateProjectResponse$json = {
  '1': 'ValidateProjectResponse',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 4, '10': 'requestId'},
    {
      '1': 'project',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.ProjectSnapshot',
      '10': 'project'
    },
  ],
};

/// Descriptor for `ValidateProjectResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List validateProjectResponseDescriptor = $convert.base64Decode(
    'ChdWYWxpZGF0ZVByb2plY3RSZXNwb25zZRIdCgpyZXF1ZXN0X2lkGAEgASgEUglyZXF1ZXN0SW'
    'QSQAoHcHJvamVjdBgCIAEoCzImLnBpLmNsaWVudC5wcm90b2NvbC52MC5Qcm9qZWN0U25hcHNo'
    'b3RSB3Byb2plY3Q=');

@$core.Deprecated('Use listKnownProjectsRequestDescriptor instead')
const ListKnownProjectsRequest$json = {
  '1': 'ListKnownProjectsRequest',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 4, '10': 'requestId'},
    {'1': 'max_projects', '3': 2, '4': 1, '5': 13, '10': 'maxProjects'},
  ],
};

/// Descriptor for `ListKnownProjectsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listKnownProjectsRequestDescriptor =
    $convert.base64Decode(
        'ChhMaXN0S25vd25Qcm9qZWN0c1JlcXVlc3QSHQoKcmVxdWVzdF9pZBgBIAEoBFIJcmVxdWVzdE'
        'lkEiEKDG1heF9wcm9qZWN0cxgCIAEoDVILbWF4UHJvamVjdHM=');

@$core.Deprecated('Use listKnownProjectsResponseDescriptor instead')
const ListKnownProjectsResponse$json = {
  '1': 'ListKnownProjectsResponse',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 4, '10': 'requestId'},
    {
      '1': 'projects',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.pi.client.protocol.v0.KnownProjectSnapshot',
      '10': 'projects'
    },
  ],
};

/// Descriptor for `ListKnownProjectsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listKnownProjectsResponseDescriptor = $convert.base64Decode(
    'ChlMaXN0S25vd25Qcm9qZWN0c1Jlc3BvbnNlEh0KCnJlcXVlc3RfaWQYASABKARSCXJlcXVlc3'
    'RJZBJHCghwcm9qZWN0cxgCIAMoCzIrLnBpLmNsaWVudC5wcm90b2NvbC52MC5Lbm93blByb2pl'
    'Y3RTbmFwc2hvdFIIcHJvamVjdHM=');

@$core.Deprecated('Use approveProjectTrustRequestDescriptor instead')
const ApproveProjectTrustRequest$json = {
  '1': 'ApproveProjectTrustRequest',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 4, '10': 'requestId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'trust_revision', '3': 3, '4': 1, '5': 9, '10': 'trustRevision'},
  ],
};

/// Descriptor for `ApproveProjectTrustRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List approveProjectTrustRequestDescriptor =
    $convert.base64Decode(
        'ChpBcHByb3ZlUHJvamVjdFRydXN0UmVxdWVzdBIdCgpyZXF1ZXN0X2lkGAEgASgEUglyZXF1ZX'
        'N0SWQSHQoKcHJvamVjdF9pZBgCIAEoCVIJcHJvamVjdElkEiUKDnRydXN0X3JldmlzaW9uGAMg'
        'ASgJUg10cnVzdFJldmlzaW9u');

@$core.Deprecated('Use approveProjectTrustResponseDescriptor instead')
const ApproveProjectTrustResponse$json = {
  '1': 'ApproveProjectTrustResponse',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 4, '10': 'requestId'},
    {
      '1': 'project',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.ProjectSnapshot',
      '10': 'project'
    },
  ],
};

/// Descriptor for `ApproveProjectTrustResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List approveProjectTrustResponseDescriptor =
    $convert.base64Decode(
        'ChtBcHByb3ZlUHJvamVjdFRydXN0UmVzcG9uc2USHQoKcmVxdWVzdF9pZBgBIAEoBFIJcmVxdW'
        'VzdElkEkAKB3Byb2plY3QYAiABKAsyJi5waS5jbGllbnQucHJvdG9jb2wudjAuUHJvamVjdFNu'
        'YXBzaG90Ugdwcm9qZWN0');

@$core.Deprecated('Use directoryListingSnapshotDescriptor instead')
const DirectoryListingSnapshot$json = {
  '1': 'DirectoryListingSnapshot',
  '2': [
    {
      '1': 'canonical_directory',
      '3': 1,
      '4': 1,
      '5': 9,
      '10': 'canonicalDirectory'
    },
    {'1': 'parent_directory', '3': 2, '4': 1, '5': 9, '10': 'parentDirectory'},
    {
      '1': 'children',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.pi.client.protocol.v0.DirectoryEntrySnapshot',
      '10': 'children'
    },
    {'1': 'truncated', '3': 4, '4': 1, '5': 8, '10': 'truncated'},
  ],
};

/// Descriptor for `DirectoryListingSnapshot`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List directoryListingSnapshotDescriptor = $convert.base64Decode(
    'ChhEaXJlY3RvcnlMaXN0aW5nU25hcHNob3QSLwoTY2Fub25pY2FsX2RpcmVjdG9yeRgBIAEoCV'
    'ISY2Fub25pY2FsRGlyZWN0b3J5EikKEHBhcmVudF9kaXJlY3RvcnkYAiABKAlSD3BhcmVudERp'
    'cmVjdG9yeRJJCghjaGlsZHJlbhgDIAMoCzItLnBpLmNsaWVudC5wcm90b2NvbC52MC5EaXJlY3'
    'RvcnlFbnRyeVNuYXBzaG90UghjaGlsZHJlbhIcCgl0cnVuY2F0ZWQYBCABKAhSCXRydW5jYXRl'
    'ZA==');

@$core.Deprecated('Use directoryEntrySnapshotDescriptor instead')
const DirectoryEntrySnapshot$json = {
  '1': 'DirectoryEntrySnapshot',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'canonical_path', '3': 2, '4': 1, '5': 9, '10': 'canonicalPath'},
    {'1': 'is_symbolic_link', '3': 3, '4': 1, '5': 8, '10': 'isSymbolicLink'},
  ],
};

/// Descriptor for `DirectoryEntrySnapshot`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List directoryEntrySnapshotDescriptor = $convert.base64Decode(
    'ChZEaXJlY3RvcnlFbnRyeVNuYXBzaG90EhIKBG5hbWUYASABKAlSBG5hbWUSJQoOY2Fub25pY2'
    'FsX3BhdGgYAiABKAlSDWNhbm9uaWNhbFBhdGgSKAoQaXNfc3ltYm9saWNfbGluaxgDIAEoCFIO'
    'aXNTeW1ib2xpY0xpbms=');

@$core.Deprecated('Use projectTrustSnapshotDescriptor instead')
const ProjectTrustSnapshot$json = {
  '1': 'ProjectTrustSnapshot',
  '2': [
    {
      '1': 'status',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.pi.client.protocol.v0.ProjectTrustStatus',
      '10': 'status'
    },
    {
      '1': 'reasons',
      '3': 2,
      '4': 3,
      '5': 14,
      '6': '.pi.client.protocol.v0.ProjectTrustReason',
      '10': 'reasons'
    },
    {'1': 'revision', '3': 3, '4': 1, '5': 9, '10': 'revision'},
  ],
};

/// Descriptor for `ProjectTrustSnapshot`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List projectTrustSnapshotDescriptor = $convert.base64Decode(
    'ChRQcm9qZWN0VHJ1c3RTbmFwc2hvdBJBCgZzdGF0dXMYASABKA4yKS5waS5jbGllbnQucHJvdG'
    '9jb2wudjAuUHJvamVjdFRydXN0U3RhdHVzUgZzdGF0dXMSQwoHcmVhc29ucxgCIAMoDjIpLnBp'
    'LmNsaWVudC5wcm90b2NvbC52MC5Qcm9qZWN0VHJ1c3RSZWFzb25SB3JlYXNvbnMSGgoIcmV2aX'
    'Npb24YAyABKAlSCHJldmlzaW9u');

@$core.Deprecated('Use projectIdentitySnapshotDescriptor instead')
const ProjectIdentitySnapshot$json = {
  '1': 'ProjectIdentitySnapshot',
  '2': [
    {'1': 'project_id', '3': 1, '4': 1, '5': 9, '10': 'projectId'},
    {
      '1': 'canonical_working_directory',
      '3': 2,
      '4': 1,
      '5': 9,
      '10': 'canonicalWorkingDirectory'
    },
    {'1': 'is_git_repository', '3': 3, '4': 1, '5': 8, '10': 'isGitRepository'},
    {'1': 'git_root', '3': 4, '4': 1, '5': 9, '10': 'gitRoot'},
    {
      '1': 'main_worktree_root',
      '3': 5,
      '4': 1,
      '5': 9,
      '10': 'mainWorktreeRoot'
    },
    {'1': 'branch', '3': 6, '4': 1, '5': 9, '10': 'branch'},
    {
      '1': 'is_linked_worktree',
      '3': 7,
      '4': 1,
      '5': 8,
      '10': 'isLinkedWorktree'
    },
    {'1': 'is_detached_head', '3': 8, '4': 1, '5': 8, '10': 'isDetachedHead'},
    {'1': 'worktree_id', '3': 9, '4': 1, '5': 9, '10': 'worktreeId'},
    {'1': 'main_project_id', '3': 10, '4': 1, '5': 9, '10': 'mainProjectId'},
  ],
};

/// Descriptor for `ProjectIdentitySnapshot`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List projectIdentitySnapshotDescriptor = $convert.base64Decode(
    'ChdQcm9qZWN0SWRlbnRpdHlTbmFwc2hvdBIdCgpwcm9qZWN0X2lkGAEgASgJUglwcm9qZWN0SW'
    'QSPgobY2Fub25pY2FsX3dvcmtpbmdfZGlyZWN0b3J5GAIgASgJUhljYW5vbmljYWxXb3JraW5n'
    'RGlyZWN0b3J5EioKEWlzX2dpdF9yZXBvc2l0b3J5GAMgASgIUg9pc0dpdFJlcG9zaXRvcnkSGQ'
    'oIZ2l0X3Jvb3QYBCABKAlSB2dpdFJvb3QSLAoSbWFpbl93b3JrdHJlZV9yb290GAUgASgJUhBt'
    'YWluV29ya3RyZWVSb290EhYKBmJyYW5jaBgGIAEoCVIGYnJhbmNoEiwKEmlzX2xpbmtlZF93b3'
    'JrdHJlZRgHIAEoCFIQaXNMaW5rZWRXb3JrdHJlZRIoChBpc19kZXRhY2hlZF9oZWFkGAggASgI'
    'Ug5pc0RldGFjaGVkSGVhZBIfCgt3b3JrdHJlZV9pZBgJIAEoCVIKd29ya3RyZWVJZBImCg9tYW'
    'luX3Byb2plY3RfaWQYCiABKAlSDW1haW5Qcm9qZWN0SWQ=');

@$core.Deprecated('Use projectSnapshotDescriptor instead')
const ProjectSnapshot$json = {
  '1': 'ProjectSnapshot',
  '2': [
    {
      '1': 'identity',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.ProjectIdentitySnapshot',
      '10': 'identity'
    },
    {
      '1': 'trust',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.ProjectTrustSnapshot',
      '10': 'trust'
    },
  ],
};

/// Descriptor for `ProjectSnapshot`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List projectSnapshotDescriptor = $convert.base64Decode(
    'Cg9Qcm9qZWN0U25hcHNob3QSSgoIaWRlbnRpdHkYASABKAsyLi5waS5jbGllbnQucHJvdG9jb2'
    'wudjAuUHJvamVjdElkZW50aXR5U25hcHNob3RSCGlkZW50aXR5EkEKBXRydXN0GAIgASgLMisu'
    'cGkuY2xpZW50LnByb3RvY29sLnYwLlByb2plY3RUcnVzdFNuYXBzaG90UgV0cnVzdA==');

@$core.Deprecated('Use knownProjectSnapshotDescriptor instead')
const KnownProjectSnapshot$json = {
  '1': 'KnownProjectSnapshot',
  '2': [
    {
      '1': 'project',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.ProjectSnapshot',
      '10': 'project'
    },
    {
      '1': 'last_session_at_unix_millis',
      '3': 2,
      '4': 1,
      '5': 4,
      '10': 'lastSessionAtUnixMillis'
    },
    {'1': 'session_count', '3': 3, '4': 1, '5': 13, '10': 'sessionCount'},
  ],
};

/// Descriptor for `KnownProjectSnapshot`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List knownProjectSnapshotDescriptor = $convert.base64Decode(
    'ChRLbm93blByb2plY3RTbmFwc2hvdBJACgdwcm9qZWN0GAEgASgLMiYucGkuY2xpZW50LnByb3'
    'RvY29sLnYwLlByb2plY3RTbmFwc2hvdFIHcHJvamVjdBI8ChtsYXN0X3Nlc3Npb25fYXRfdW5p'
    'eF9taWxsaXMYAiABKARSF2xhc3RTZXNzaW9uQXRVbml4TWlsbGlzEiMKDXNlc3Npb25fY291bn'
    'QYAyABKA1SDHNlc3Npb25Db3VudA==');

@$core.Deprecated('Use listSessionsRequestDescriptor instead')
const ListSessionsRequest$json = {
  '1': 'ListSessionsRequest',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 4, '10': 'requestId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
  ],
};

/// Descriptor for `ListSessionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listSessionsRequestDescriptor = $convert.base64Decode(
    'ChNMaXN0U2Vzc2lvbnNSZXF1ZXN0Eh0KCnJlcXVlc3RfaWQYASABKARSCXJlcXVlc3RJZBIdCg'
    'pwcm9qZWN0X2lkGAIgASgJUglwcm9qZWN0SWQ=');

@$core.Deprecated('Use listSessionsResponseDescriptor instead')
const ListSessionsResponse$json = {
  '1': 'ListSessionsResponse',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 4, '10': 'requestId'},
    {
      '1': 'sessions',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.pi.client.protocol.v0.SessionSummarySnapshot',
      '10': 'sessions'
    },
  ],
};

/// Descriptor for `ListSessionsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listSessionsResponseDescriptor = $convert.base64Decode(
    'ChRMaXN0U2Vzc2lvbnNSZXNwb25zZRIdCgpyZXF1ZXN0X2lkGAEgASgEUglyZXF1ZXN0SWQSSQ'
    'oIc2Vzc2lvbnMYAiADKAsyLS5waS5jbGllbnQucHJvdG9jb2wudjAuU2Vzc2lvblN1bW1hcnlT'
    'bmFwc2hvdFIIc2Vzc2lvbnM=');

@$core.Deprecated('Use getSessionRequestDescriptor instead')
const GetSessionRequest$json = {
  '1': 'GetSessionRequest',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 4, '10': 'requestId'},
    {'1': 'session_id', '3': 2, '4': 1, '5': 9, '10': 'sessionId'},
    {'1': 'project_id', '3': 3, '4': 1, '5': 9, '10': 'projectId'},
  ],
};

/// Descriptor for `GetSessionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSessionRequestDescriptor = $convert.base64Decode(
    'ChFHZXRTZXNzaW9uUmVxdWVzdBIdCgpyZXF1ZXN0X2lkGAEgASgEUglyZXF1ZXN0SWQSHQoKc2'
    'Vzc2lvbl9pZBgCIAEoCVIJc2Vzc2lvbklkEh0KCnByb2plY3RfaWQYAyABKAlSCXByb2plY3RJ'
    'ZA==');

@$core.Deprecated('Use getSessionResponseDescriptor instead')
const GetSessionResponse$json = {
  '1': 'GetSessionResponse',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 4, '10': 'requestId'},
    {
      '1': 'session',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.SessionDetailSnapshot',
      '10': 'session'
    },
  ],
};

/// Descriptor for `GetSessionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSessionResponseDescriptor = $convert.base64Decode(
    'ChJHZXRTZXNzaW9uUmVzcG9uc2USHQoKcmVxdWVzdF9pZBgBIAEoBFIJcmVxdWVzdElkEkYKB3'
    'Nlc3Npb24YAiABKAsyLC5waS5jbGllbnQucHJvdG9jb2wudjAuU2Vzc2lvbkRldGFpbFNuYXBz'
    'aG90UgdzZXNzaW9u');

@$core.Deprecated('Use createSessionRequestDescriptor instead')
const CreateSessionRequest$json = {
  '1': 'CreateSessionRequest',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 4, '10': 'requestId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
  ],
};

/// Descriptor for `CreateSessionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createSessionRequestDescriptor = $convert.base64Decode(
    'ChRDcmVhdGVTZXNzaW9uUmVxdWVzdBIdCgpyZXF1ZXN0X2lkGAEgASgEUglyZXF1ZXN0SWQSHQ'
    'oKcHJvamVjdF9pZBgCIAEoCVIJcHJvamVjdElk');

@$core.Deprecated('Use createSessionResponseDescriptor instead')
const CreateSessionResponse$json = {
  '1': 'CreateSessionResponse',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 4, '10': 'requestId'},
    {
      '1': 'session',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.SessionDetailSnapshot',
      '10': 'session'
    },
  ],
};

/// Descriptor for `CreateSessionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createSessionResponseDescriptor = $convert.base64Decode(
    'ChVDcmVhdGVTZXNzaW9uUmVzcG9uc2USHQoKcmVxdWVzdF9pZBgBIAEoBFIJcmVxdWVzdElkEk'
    'YKB3Nlc3Npb24YAiABKAsyLC5waS5jbGllbnQucHJvdG9jb2wudjAuU2Vzc2lvbkRldGFpbFNu'
    'YXBzaG90UgdzZXNzaW9u');

@$core.Deprecated('Use promptCommandDescriptor instead')
const PromptCommand$json = {
  '1': 'PromptCommand',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 4, '10': 'requestId'},
    {'1': 'command_id', '3': 2, '4': 1, '5': 9, '10': 'commandId'},
    {'1': 'session_id', '3': 3, '4': 1, '5': 9, '10': 'sessionId'},
    {'1': 'prompt', '3': 4, '4': 1, '5': 9, '10': 'prompt'},
  ],
};

/// Descriptor for `PromptCommand`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List promptCommandDescriptor = $convert.base64Decode(
    'Cg1Qcm9tcHRDb21tYW5kEh0KCnJlcXVlc3RfaWQYASABKARSCXJlcXVlc3RJZBIdCgpjb21tYW'
    '5kX2lkGAIgASgJUgljb21tYW5kSWQSHQoKc2Vzc2lvbl9pZBgDIAEoCVIJc2Vzc2lvbklkEhYK'
    'BnByb21wdBgEIAEoCVIGcHJvbXB0');

@$core.Deprecated('Use abortCommandDescriptor instead')
const AbortCommand$json = {
  '1': 'AbortCommand',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 4, '10': 'requestId'},
    {'1': 'command_id', '3': 2, '4': 1, '5': 9, '10': 'commandId'},
    {'1': 'session_id', '3': 3, '4': 1, '5': 9, '10': 'sessionId'},
  ],
};

/// Descriptor for `AbortCommand`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List abortCommandDescriptor = $convert.base64Decode(
    'CgxBYm9ydENvbW1hbmQSHQoKcmVxdWVzdF9pZBgBIAEoBFIJcmVxdWVzdElkEh0KCmNvbW1hbm'
    'RfaWQYAiABKAlSCWNvbW1hbmRJZBIdCgpzZXNzaW9uX2lkGAMgASgJUglzZXNzaW9uSWQ=');

@$core.Deprecated('Use renameSessionCommandDescriptor instead')
const RenameSessionCommand$json = {
  '1': 'RenameSessionCommand',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 4, '10': 'requestId'},
    {'1': 'command_id', '3': 2, '4': 1, '5': 9, '10': 'commandId'},
    {'1': 'project_id', '3': 3, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'session_id', '3': 4, '4': 1, '5': 9, '10': 'sessionId'},
    {'1': 'name', '3': 5, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `RenameSessionCommand`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List renameSessionCommandDescriptor = $convert.base64Decode(
    'ChRSZW5hbWVTZXNzaW9uQ29tbWFuZBIdCgpyZXF1ZXN0X2lkGAEgASgEUglyZXF1ZXN0SWQSHQ'
    'oKY29tbWFuZF9pZBgCIAEoCVIJY29tbWFuZElkEh0KCnByb2plY3RfaWQYAyABKAlSCXByb2pl'
    'Y3RJZBIdCgpzZXNzaW9uX2lkGAQgASgJUglzZXNzaW9uSWQSEgoEbmFtZRgFIAEoCVIEbmFtZQ'
    '==');

@$core.Deprecated('Use clearSessionNameCommandDescriptor instead')
const ClearSessionNameCommand$json = {
  '1': 'ClearSessionNameCommand',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 4, '10': 'requestId'},
    {'1': 'command_id', '3': 2, '4': 1, '5': 9, '10': 'commandId'},
    {'1': 'project_id', '3': 3, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'session_id', '3': 4, '4': 1, '5': 9, '10': 'sessionId'},
  ],
};

/// Descriptor for `ClearSessionNameCommand`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clearSessionNameCommandDescriptor = $convert.base64Decode(
    'ChdDbGVhclNlc3Npb25OYW1lQ29tbWFuZBIdCgpyZXF1ZXN0X2lkGAEgASgEUglyZXF1ZXN0SW'
    'QSHQoKY29tbWFuZF9pZBgCIAEoCVIJY29tbWFuZElkEh0KCnByb2plY3RfaWQYAyABKAlSCXBy'
    'b2plY3RJZBIdCgpzZXNzaW9uX2lkGAQgASgJUglzZXNzaW9uSWQ=');

@$core.Deprecated('Use autoNameSessionCommandDescriptor instead')
const AutoNameSessionCommand$json = {
  '1': 'AutoNameSessionCommand',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 4, '10': 'requestId'},
    {'1': 'command_id', '3': 2, '4': 1, '5': 9, '10': 'commandId'},
    {'1': 'project_id', '3': 3, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'session_id', '3': 4, '4': 1, '5': 9, '10': 'sessionId'},
    {'1': 'timeout_millis', '3': 5, '4': 1, '5': 13, '10': 'timeoutMillis'},
  ],
};

/// Descriptor for `AutoNameSessionCommand`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List autoNameSessionCommandDescriptor = $convert.base64Decode(
    'ChZBdXRvTmFtZVNlc3Npb25Db21tYW5kEh0KCnJlcXVlc3RfaWQYASABKARSCXJlcXVlc3RJZB'
    'IdCgpjb21tYW5kX2lkGAIgASgJUgljb21tYW5kSWQSHQoKcHJvamVjdF9pZBgDIAEoCVIJcHJv'
    'amVjdElkEh0KCnNlc3Npb25faWQYBCABKAlSCXNlc3Npb25JZBIlCg50aW1lb3V0X21pbGxpcx'
    'gFIAEoDVINdGltZW91dE1pbGxpcw==');

@$core.Deprecated('Use deleteSessionConfirmationEvidenceDescriptor instead')
const DeleteSessionConfirmationEvidence$json = {
  '1': 'DeleteSessionConfirmationEvidence',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
    {'1': 'admin_revision', '3': 2, '4': 1, '5': 9, '10': 'adminRevision'},
    {'1': 'displayed_title', '3': 3, '4': 1, '5': 9, '10': 'displayedTitle'},
    {
      '1': 'destructive_action_acknowledged',
      '3': 4,
      '4': 1,
      '5': 8,
      '10': 'destructiveActionAcknowledged'
    },
  ],
};

/// Descriptor for `DeleteSessionConfirmationEvidence`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteSessionConfirmationEvidenceDescriptor =
    $convert.base64Decode(
        'CiFEZWxldGVTZXNzaW9uQ29uZmlybWF0aW9uRXZpZGVuY2USHQoKc2Vzc2lvbl9pZBgBIAEoCV'
        'IJc2Vzc2lvbklkEiUKDmFkbWluX3JldmlzaW9uGAIgASgJUg1hZG1pblJldmlzaW9uEicKD2Rp'
        'c3BsYXllZF90aXRsZRgDIAEoCVIOZGlzcGxheWVkVGl0bGUSRgofZGVzdHJ1Y3RpdmVfYWN0aW'
        '9uX2Fja25vd2xlZGdlZBgEIAEoCFIdZGVzdHJ1Y3RpdmVBY3Rpb25BY2tub3dsZWRnZWQ=');

@$core.Deprecated('Use deleteSessionCommandDescriptor instead')
const DeleteSessionCommand$json = {
  '1': 'DeleteSessionCommand',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 4, '10': 'requestId'},
    {'1': 'command_id', '3': 2, '4': 1, '5': 9, '10': 'commandId'},
    {'1': 'project_id', '3': 3, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'session_id', '3': 4, '4': 1, '5': 9, '10': 'sessionId'},
    {
      '1': 'confirmation',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.DeleteSessionConfirmationEvidence',
      '10': 'confirmation'
    },
  ],
};

/// Descriptor for `DeleteSessionCommand`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteSessionCommandDescriptor = $convert.base64Decode(
    'ChREZWxldGVTZXNzaW9uQ29tbWFuZBIdCgpyZXF1ZXN0X2lkGAEgASgEUglyZXF1ZXN0SWQSHQ'
    'oKY29tbWFuZF9pZBgCIAEoCVIJY29tbWFuZElkEh0KCnByb2plY3RfaWQYAyABKAlSCXByb2pl'
    'Y3RJZBIdCgpzZXNzaW9uX2lkGAQgASgJUglzZXNzaW9uSWQSXAoMY29uZmlybWF0aW9uGAUgAS'
    'gLMjgucGkuY2xpZW50LnByb3RvY29sLnYwLkRlbGV0ZVNlc3Npb25Db25maXJtYXRpb25Fdmlk'
    'ZW5jZVIMY29uZmlybWF0aW9u');

@$core.Deprecated('Use deleteSessionOutcomeDescriptor instead')
const DeleteSessionOutcome$json = {
  '1': 'DeleteSessionOutcome',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
    {
      '1': 'reparented_child_count',
      '3': 2,
      '4': 1,
      '5': 13,
      '10': 'reparentedChildCount'
    },
  ],
};

/// Descriptor for `DeleteSessionOutcome`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteSessionOutcomeDescriptor = $convert.base64Decode(
    'ChREZWxldGVTZXNzaW9uT3V0Y29tZRIdCgpzZXNzaW9uX2lkGAEgASgJUglzZXNzaW9uSWQSNA'
    'oWcmVwYXJlbnRlZF9jaGlsZF9jb3VudBgCIAEoDVIUcmVwYXJlbnRlZENoaWxkQ291bnQ=');

@$core.Deprecated('Use sessionAdminCommandOutcomeDescriptor instead')
const SessionAdminCommandOutcome$json = {
  '1': 'SessionAdminCommandOutcome',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 4, '10': 'requestId'},
    {'1': 'command_id', '3': 2, '4': 1, '5': 9, '10': 'commandId'},
    {
      '1': 'operation',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.pi.client.protocol.v0.SessionAdminOperation',
      '10': 'operation'
    },
    {
      '1': 'session',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.SessionSummarySnapshot',
      '9': 0,
      '10': 'session'
    },
    {
      '1': 'deletion',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.DeleteSessionOutcome',
      '9': 0,
      '10': 'deletion'
    },
    {
      '1': 'error',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.StableError',
      '9': 0,
      '10': 'error'
    },
  ],
  '8': [
    {'1': 'outcome'},
  ],
  '9': [
    {'1': 4, '2': 10},
  ],
};

/// Descriptor for `SessionAdminCommandOutcome`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sessionAdminCommandOutcomeDescriptor = $convert.base64Decode(
    'ChpTZXNzaW9uQWRtaW5Db21tYW5kT3V0Y29tZRIdCgpyZXF1ZXN0X2lkGAEgASgEUglyZXF1ZX'
    'N0SWQSHQoKY29tbWFuZF9pZBgCIAEoCVIJY29tbWFuZElkEkoKCW9wZXJhdGlvbhgDIAEoDjIs'
    'LnBpLmNsaWVudC5wcm90b2NvbC52MC5TZXNzaW9uQWRtaW5PcGVyYXRpb25SCW9wZXJhdGlvbh'
    'JJCgdzZXNzaW9uGAogASgLMi0ucGkuY2xpZW50LnByb3RvY29sLnYwLlNlc3Npb25TdW1tYXJ5'
    'U25hcHNob3RIAFIHc2Vzc2lvbhJJCghkZWxldGlvbhgLIAEoCzIrLnBpLmNsaWVudC5wcm90b2'
    'NvbC52MC5EZWxldGVTZXNzaW9uT3V0Y29tZUgAUghkZWxldGlvbhI6CgVlcnJvchgMIAEoCzIi'
    'LnBpLmNsaWVudC5wcm90b2NvbC52MC5TdGFibGVFcnJvckgAUgVlcnJvckIJCgdvdXRjb21lSg'
    'QIBBAK');

@$core.Deprecated('Use requestRejectedDescriptor instead')
const RequestRejected$json = {
  '1': 'RequestRejected',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 4, '10': 'requestId'},
    {
      '1': 'error',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.StableError',
      '10': 'error'
    },
  ],
};

/// Descriptor for `RequestRejected`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List requestRejectedDescriptor = $convert.base64Decode(
    'Cg9SZXF1ZXN0UmVqZWN0ZWQSHQoKcmVxdWVzdF9pZBgBIAEoBFIJcmVxdWVzdElkEjgKBWVycm'
    '9yGAIgASgLMiIucGkuY2xpZW50LnByb3RvY29sLnYwLlN0YWJsZUVycm9yUgVlcnJvcg==');

@$core.Deprecated('Use commandAcceptedDescriptor instead')
const CommandAccepted$json = {
  '1': 'CommandAccepted',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 4, '10': 'requestId'},
    {'1': 'command_id', '3': 2, '4': 1, '5': 9, '10': 'commandId'},
  ],
};

/// Descriptor for `CommandAccepted`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commandAcceptedDescriptor = $convert.base64Decode(
    'Cg9Db21tYW5kQWNjZXB0ZWQSHQoKcmVxdWVzdF9pZBgBIAEoBFIJcmVxdWVzdElkEh0KCmNvbW'
    '1hbmRfaWQYAiABKAlSCWNvbW1hbmRJZA==');

@$core.Deprecated('Use commandRejectedDescriptor instead')
const CommandRejected$json = {
  '1': 'CommandRejected',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 4, '10': 'requestId'},
    {'1': 'command_id', '3': 2, '4': 1, '5': 9, '10': 'commandId'},
    {
      '1': 'error',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.StableError',
      '10': 'error'
    },
  ],
};

/// Descriptor for `CommandRejected`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commandRejectedDescriptor = $convert.base64Decode(
    'Cg9Db21tYW5kUmVqZWN0ZWQSHQoKcmVxdWVzdF9pZBgBIAEoBFIJcmVxdWVzdElkEh0KCmNvbW'
    '1hbmRfaWQYAiABKAlSCWNvbW1hbmRJZBI4CgVlcnJvchgDIAEoCzIiLnBpLmNsaWVudC5wcm90'
    'b2NvbC52MC5TdGFibGVFcnJvclIFZXJyb3I=');

@$core.Deprecated('Use sessionSummarySnapshotDescriptor instead')
const SessionSummarySnapshot$json = {
  '1': 'SessionSummarySnapshot',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
    {'1': 'title', '3': 2, '4': 1, '5': 9, '10': 'title'},
    {
      '1': 'working_directory',
      '3': 3,
      '4': 1,
      '5': 9,
      '10': 'workingDirectory'
    },
    {
      '1': 'created_at_unix_millis',
      '3': 4,
      '4': 1,
      '5': 4,
      '10': 'createdAtUnixMillis'
    },
    {
      '1': 'updated_at_unix_millis',
      '3': 5,
      '4': 1,
      '5': 4,
      '10': 'updatedAtUnixMillis'
    },
    {'1': 'is_running', '3': 6, '4': 1, '5': 8, '10': 'isRunning'},
    {'1': 'has_unread', '3': 7, '4': 1, '5': 8, '10': 'hasUnread'},
    {'1': 'admin_revision', '3': 8, '4': 1, '5': 9, '10': 'adminRevision'},
    {'1': 'has_custom_name', '3': 9, '4': 1, '5': 8, '10': 'hasCustomName'},
  ],
};

/// Descriptor for `SessionSummarySnapshot`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sessionSummarySnapshotDescriptor = $convert.base64Decode(
    'ChZTZXNzaW9uU3VtbWFyeVNuYXBzaG90Eh0KCnNlc3Npb25faWQYASABKAlSCXNlc3Npb25JZB'
    'IUCgV0aXRsZRgCIAEoCVIFdGl0bGUSKwoRd29ya2luZ19kaXJlY3RvcnkYAyABKAlSEHdvcmtp'
    'bmdEaXJlY3RvcnkSMwoWY3JlYXRlZF9hdF91bml4X21pbGxpcxgEIAEoBFITY3JlYXRlZEF0VW'
    '5peE1pbGxpcxIzChZ1cGRhdGVkX2F0X3VuaXhfbWlsbGlzGAUgASgEUhN1cGRhdGVkQXRVbml4'
    'TWlsbGlzEh0KCmlzX3J1bm5pbmcYBiABKAhSCWlzUnVubmluZxIdCgpoYXNfdW5yZWFkGAcgAS'
    'gIUgloYXNVbnJlYWQSJQoOYWRtaW5fcmV2aXNpb24YCCABKAlSDWFkbWluUmV2aXNpb24SJgoP'
    'aGFzX2N1c3RvbV9uYW1lGAkgASgIUg1oYXNDdXN0b21OYW1l');

@$core.Deprecated('Use sessionDetailSnapshotDescriptor instead')
const SessionDetailSnapshot$json = {
  '1': 'SessionDetailSnapshot',
  '2': [
    {
      '1': 'summary',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.SessionSummarySnapshot',
      '10': 'summary'
    },
    {
      '1': 'messages',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.pi.client.protocol.v0.MessageSnapshot',
      '10': 'messages'
    },
  ],
};

/// Descriptor for `SessionDetailSnapshot`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sessionDetailSnapshotDescriptor = $convert.base64Decode(
    'ChVTZXNzaW9uRGV0YWlsU25hcHNob3QSRwoHc3VtbWFyeRgBIAEoCzItLnBpLmNsaWVudC5wcm'
    '90b2NvbC52MC5TZXNzaW9uU3VtbWFyeVNuYXBzaG90UgdzdW1tYXJ5EkIKCG1lc3NhZ2VzGAIg'
    'AygLMiYucGkuY2xpZW50LnByb3RvY29sLnYwLk1lc3NhZ2VTbmFwc2hvdFIIbWVzc2FnZXM=');

@$core.Deprecated('Use messageSnapshotDescriptor instead')
const MessageSnapshot$json = {
  '1': 'MessageSnapshot',
  '2': [
    {'1': 'message_id', '3': 1, '4': 1, '5': 9, '10': 'messageId'},
    {
      '1': 'role',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.pi.client.protocol.v0.MessageRole',
      '10': 'role'
    },
    {'1': 'text', '3': 3, '4': 1, '5': 9, '10': 'text'},
    {
      '1': 'created_at_unix_millis',
      '3': 4,
      '4': 1,
      '5': 4,
      '10': 'createdAtUnixMillis'
    },
    {'1': 'is_streaming', '3': 5, '4': 1, '5': 8, '10': 'isStreaming'},
  ],
};

/// Descriptor for `MessageSnapshot`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageSnapshotDescriptor = $convert.base64Decode(
    'Cg9NZXNzYWdlU25hcHNob3QSHQoKbWVzc2FnZV9pZBgBIAEoCVIJbWVzc2FnZUlkEjYKBHJvbG'
    'UYAiABKA4yIi5waS5jbGllbnQucHJvdG9jb2wudjAuTWVzc2FnZVJvbGVSBHJvbGUSEgoEdGV4'
    'dBgDIAEoCVIEdGV4dBIzChZjcmVhdGVkX2F0X3VuaXhfbWlsbGlzGAQgASgEUhNjcmVhdGVkQX'
    'RVbml4TWlsbGlzEiEKDGlzX3N0cmVhbWluZxgFIAEoCFILaXNTdHJlYW1pbmc=');

@$core.Deprecated('Use sessionEventStreamEnvelopeDescriptor instead')
const SessionEventStreamEnvelope$json = {
  '1': 'SessionEventStreamEnvelope',
  '2': [
    {'1': 'stream_id', '3': 1, '4': 1, '5': 9, '10': 'streamId'},
    {'1': 'session_id', '3': 2, '4': 1, '5': 9, '10': 'sessionId'},
    {'1': 'event_sequence', '3': 3, '4': 1, '5': 4, '10': 'eventSequence'},
    {
      '1': 'message_added',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.MessageAddedEvent',
      '9': 0,
      '10': 'messageAdded'
    },
    {
      '1': 'message_delta',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.MessageDeltaEvent',
      '9': 0,
      '10': 'messageDelta'
    },
    {
      '1': 'running_changed',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.SessionRunningChangedEvent',
      '9': 0,
      '10': 'runningChanged'
    },
    {
      '1': 'command_completed',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.CommandCompletedEvent',
      '9': 0,
      '10': 'commandCompleted'
    },
    {
      '1': 'stream_closed',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.StreamClosedEvent',
      '9': 0,
      '10': 'streamClosed'
    },
  ],
  '8': [
    {'1': 'event'},
  ],
  '9': [
    {'1': 4, '2': 10},
  ],
};

/// Descriptor for `SessionEventStreamEnvelope`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sessionEventStreamEnvelopeDescriptor = $convert.base64Decode(
    'ChpTZXNzaW9uRXZlbnRTdHJlYW1FbnZlbG9wZRIbCglzdHJlYW1faWQYASABKAlSCHN0cmVhbU'
    'lkEh0KCnNlc3Npb25faWQYAiABKAlSCXNlc3Npb25JZBIlCg5ldmVudF9zZXF1ZW5jZRgDIAEo'
    'BFINZXZlbnRTZXF1ZW5jZRJPCg1tZXNzYWdlX2FkZGVkGAogASgLMigucGkuY2xpZW50LnByb3'
    'RvY29sLnYwLk1lc3NhZ2VBZGRlZEV2ZW50SABSDG1lc3NhZ2VBZGRlZBJPCg1tZXNzYWdlX2Rl'
    'bHRhGAsgASgLMigucGkuY2xpZW50LnByb3RvY29sLnYwLk1lc3NhZ2VEZWx0YUV2ZW50SABSDG'
    '1lc3NhZ2VEZWx0YRJcCg9ydW5uaW5nX2NoYW5nZWQYDCABKAsyMS5waS5jbGllbnQucHJvdG9j'
    'b2wudjAuU2Vzc2lvblJ1bm5pbmdDaGFuZ2VkRXZlbnRIAFIOcnVubmluZ0NoYW5nZWQSWwoRY2'
    '9tbWFuZF9jb21wbGV0ZWQYDSABKAsyLC5waS5jbGllbnQucHJvdG9jb2wudjAuQ29tbWFuZENv'
    'bXBsZXRlZEV2ZW50SABSEGNvbW1hbmRDb21wbGV0ZWQSTwoNc3RyZWFtX2Nsb3NlZBgOIAEoCz'
    'IoLnBpLmNsaWVudC5wcm90b2NvbC52MC5TdHJlYW1DbG9zZWRFdmVudEgAUgxzdHJlYW1DbG9z'
    'ZWRCBwoFZXZlbnRKBAgEEAo=');

@$core.Deprecated('Use messageAddedEventDescriptor instead')
const MessageAddedEvent$json = {
  '1': 'MessageAddedEvent',
  '2': [
    {
      '1': 'message',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.MessageSnapshot',
      '10': 'message'
    },
  ],
};

/// Descriptor for `MessageAddedEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageAddedEventDescriptor = $convert.base64Decode(
    'ChFNZXNzYWdlQWRkZWRFdmVudBJACgdtZXNzYWdlGAEgASgLMiYucGkuY2xpZW50LnByb3RvY2'
    '9sLnYwLk1lc3NhZ2VTbmFwc2hvdFIHbWVzc2FnZQ==');

@$core.Deprecated('Use messageDeltaEventDescriptor instead')
const MessageDeltaEvent$json = {
  '1': 'MessageDeltaEvent',
  '2': [
    {'1': 'message_id', '3': 1, '4': 1, '5': 9, '10': 'messageId'},
    {'1': 'delta', '3': 2, '4': 1, '5': 9, '10': 'delta'},
  ],
};

/// Descriptor for `MessageDeltaEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageDeltaEventDescriptor = $convert.base64Decode(
    'ChFNZXNzYWdlRGVsdGFFdmVudBIdCgptZXNzYWdlX2lkGAEgASgJUgltZXNzYWdlSWQSFAoFZG'
    'VsdGEYAiABKAlSBWRlbHRh');

@$core.Deprecated('Use sessionRunningChangedEventDescriptor instead')
const SessionRunningChangedEvent$json = {
  '1': 'SessionRunningChangedEvent',
  '2': [
    {'1': 'is_running', '3': 1, '4': 1, '5': 8, '10': 'isRunning'},
  ],
};

/// Descriptor for `SessionRunningChangedEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sessionRunningChangedEventDescriptor =
    $convert.base64Decode(
        'ChpTZXNzaW9uUnVubmluZ0NoYW5nZWRFdmVudBIdCgppc19ydW5uaW5nGAEgASgIUglpc1J1bm'
        '5pbmc=');

@$core.Deprecated('Use commandCompletedEventDescriptor instead')
const CommandCompletedEvent$json = {
  '1': 'CommandCompletedEvent',
  '2': [
    {'1': 'command_id', '3': 1, '4': 1, '5': 9, '10': 'commandId'},
    {'1': 'succeeded', '3': 2, '4': 1, '5': 8, '10': 'succeeded'},
    {
      '1': 'error',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.StableError',
      '10': 'error'
    },
  ],
};

/// Descriptor for `CommandCompletedEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commandCompletedEventDescriptor = $convert.base64Decode(
    'ChVDb21tYW5kQ29tcGxldGVkRXZlbnQSHQoKY29tbWFuZF9pZBgBIAEoCVIJY29tbWFuZElkEh'
    'wKCXN1Y2NlZWRlZBgCIAEoCFIJc3VjY2VlZGVkEjgKBWVycm9yGAMgASgLMiIucGkuY2xpZW50'
    'LnByb3RvY29sLnYwLlN0YWJsZUVycm9yUgVlcnJvcg==');

@$core.Deprecated('Use eventStreamEnvelopeDescriptor instead')
const EventStreamEnvelope$json = {
  '1': 'EventStreamEnvelope',
  '2': [
    {'1': 'stream_id', '3': 1, '4': 1, '5': 9, '10': 'streamId'},
    {'1': 'event_sequence', '3': 2, '4': 1, '5': 4, '10': 'eventSequence'},
    {
      '1': 'heartbeat',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.HeartbeatEvent',
      '9': 0,
      '10': 'heartbeat'
    },
    {
      '1': 'health_status_changed',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.HealthStatusChangedEvent',
      '9': 0,
      '10': 'healthStatusChanged'
    },
    {
      '1': 'stream_closed',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.StreamClosedEvent',
      '9': 0,
      '10': 'streamClosed'
    },
  ],
  '8': [
    {'1': 'event'},
  ],
  '9': [
    {'1': 3, '2': 10},
  ],
};

/// Descriptor for `EventStreamEnvelope`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List eventStreamEnvelopeDescriptor = $convert.base64Decode(
    'ChNFdmVudFN0cmVhbUVudmVsb3BlEhsKCXN0cmVhbV9pZBgBIAEoCVIIc3RyZWFtSWQSJQoOZX'
    'ZlbnRfc2VxdWVuY2UYAiABKARSDWV2ZW50U2VxdWVuY2USRQoJaGVhcnRiZWF0GAogASgLMiUu'
    'cGkuY2xpZW50LnByb3RvY29sLnYwLkhlYXJ0YmVhdEV2ZW50SABSCWhlYXJ0YmVhdBJlChVoZW'
    'FsdGhfc3RhdHVzX2NoYW5nZWQYCyABKAsyLy5waS5jbGllbnQucHJvdG9jb2wudjAuSGVhbHRo'
    'U3RhdHVzQ2hhbmdlZEV2ZW50SABSE2hlYWx0aFN0YXR1c0NoYW5nZWQSTwoNc3RyZWFtX2Nsb3'
    'NlZBgMIAEoCzIoLnBpLmNsaWVudC5wcm90b2NvbC52MC5TdHJlYW1DbG9zZWRFdmVudEgAUgxz'
    'dHJlYW1DbG9zZWRCBwoFZXZlbnRKBAgDEAo=');

@$core.Deprecated('Use heartbeatEventDescriptor instead')
const HeartbeatEvent$json = {
  '1': 'HeartbeatEvent',
  '2': [
    {
      '1': 'observed_unix_millis',
      '3': 1,
      '4': 1,
      '5': 4,
      '10': 'observedUnixMillis'
    },
  ],
};

/// Descriptor for `HeartbeatEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List heartbeatEventDescriptor = $convert.base64Decode(
    'Cg5IZWFydGJlYXRFdmVudBIwChRvYnNlcnZlZF91bml4X21pbGxpcxgBIAEoBFISb2JzZXJ2ZW'
    'RVbml4TWlsbGlz');

@$core.Deprecated('Use healthStatusChangedEventDescriptor instead')
const HealthStatusChangedEvent$json = {
  '1': 'HealthStatusChangedEvent',
  '2': [
    {
      '1': 'status',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.pi.client.protocol.v0.HealthStatus',
      '10': 'status'
    },
    {'1': 'summary', '3': 2, '4': 1, '5': 9, '10': 'summary'},
  ],
};

/// Descriptor for `HealthStatusChangedEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List healthStatusChangedEventDescriptor = $convert.base64Decode(
    'ChhIZWFsdGhTdGF0dXNDaGFuZ2VkRXZlbnQSOwoGc3RhdHVzGAEgASgOMiMucGkuY2xpZW50Ln'
    'Byb3RvY29sLnYwLkhlYWx0aFN0YXR1c1IGc3RhdHVzEhgKB3N1bW1hcnkYAiABKAlSB3N1bW1h'
    'cnk=');

@$core.Deprecated('Use streamClosedEventDescriptor instead')
const StreamClosedEvent$json = {
  '1': 'StreamClosedEvent',
  '2': [
    {'1': 'graceful', '3': 1, '4': 1, '5': 8, '10': 'graceful'},
    {
      '1': 'error',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.StableError',
      '10': 'error'
    },
  ],
};

/// Descriptor for `StreamClosedEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamClosedEventDescriptor = $convert.base64Decode(
    'ChFTdHJlYW1DbG9zZWRFdmVudBIaCghncmFjZWZ1bBgBIAEoCFIIZ3JhY2VmdWwSOAoFZXJyb3'
    'IYAiABKAsyIi5waS5jbGllbnQucHJvdG9jb2wudjAuU3RhYmxlRXJyb3JSBWVycm9y');

@$core.Deprecated('Use cancelDescriptor instead')
const Cancel$json = {
  '1': 'Cancel',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 4, '9': 0, '10': 'requestId'},
    {'1': 'stream_id', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'streamId'},
    {'1': 'transfer_id', '3': 3, '4': 1, '5': 9, '9': 0, '10': 'transferId'},
    {'1': 'reason', '3': 4, '4': 1, '5': 9, '10': 'reason'},
  ],
  '8': [
    {'1': 'target'},
  ],
};

/// Descriptor for `Cancel`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cancelDescriptor = $convert.base64Decode(
    'CgZDYW5jZWwSHwoKcmVxdWVzdF9pZBgBIAEoBEgAUglyZXF1ZXN0SWQSHQoJc3RyZWFtX2lkGA'
    'IgASgJSABSCHN0cmVhbUlkEiEKC3RyYW5zZmVyX2lkGAMgASgJSABSCnRyYW5zZmVySWQSFgoG'
    'cmVhc29uGAQgASgJUgZyZWFzb25CCAoGdGFyZ2V0');

@$core.Deprecated('Use windowUpdateDescriptor instead')
const WindowUpdate$json = {
  '1': 'WindowUpdate',
  '2': [
    {'1': 'stream_id', '3': 1, '4': 1, '5': 9, '9': 0, '10': 'streamId'},
    {'1': 'transfer_id', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'transferId'},
    {'1': 'credit_messages', '3': 3, '4': 1, '5': 13, '10': 'creditMessages'},
    {'1': 'credit_bytes', '3': 4, '4': 1, '5': 4, '10': 'creditBytes'},
  ],
  '8': [
    {'1': 'target'},
  ],
};

/// Descriptor for `WindowUpdate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List windowUpdateDescriptor = $convert.base64Decode(
    'CgxXaW5kb3dVcGRhdGUSHQoJc3RyZWFtX2lkGAEgASgJSABSCHN0cmVhbUlkEiEKC3RyYW5zZm'
    'VyX2lkGAIgASgJSABSCnRyYW5zZmVySWQSJwoPY3JlZGl0X21lc3NhZ2VzGAMgASgNUg5jcmVk'
    'aXRNZXNzYWdlcxIhCgxjcmVkaXRfYnl0ZXMYBCABKARSC2NyZWRpdEJ5dGVzQggKBnRhcmdldA'
    '==');

@$core.Deprecated('Use transferOpenDescriptor instead')
const TransferOpen$json = {
  '1': 'TransferOpen',
  '2': [
    {'1': 'transfer_id', '3': 1, '4': 1, '5': 9, '10': 'transferId'},
    {
      '1': 'direction',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.pi.client.protocol.v0.TransferDirection',
      '10': 'direction'
    },
    {
      '1': 'purpose',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.pi.client.protocol.v0.TransferPurpose',
      '10': 'purpose'
    },
    {'1': 'content_type', '3': 4, '4': 1, '5': 9, '10': 'contentType'},
    {'1': 'file_name', '3': 5, '4': 1, '5': 9, '10': 'fileName'},
    {'1': 'total_bytes', '3': 6, '4': 1, '5': 4, '10': 'totalBytes'},
    {'1': 'chunk_bytes', '3': 7, '4': 1, '5': 13, '10': 'chunkBytes'},
    {'1': 'sha256', '3': 8, '4': 1, '5': 12, '10': 'sha256'},
  ],
};

/// Descriptor for `TransferOpen`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transferOpenDescriptor = $convert.base64Decode(
    'CgxUcmFuc2Zlck9wZW4SHwoLdHJhbnNmZXJfaWQYASABKAlSCnRyYW5zZmVySWQSRgoJZGlyZW'
    'N0aW9uGAIgASgOMigucGkuY2xpZW50LnByb3RvY29sLnYwLlRyYW5zZmVyRGlyZWN0aW9uUglk'
    'aXJlY3Rpb24SQAoHcHVycG9zZRgDIAEoDjImLnBpLmNsaWVudC5wcm90b2NvbC52MC5UcmFuc2'
    'ZlclB1cnBvc2VSB3B1cnBvc2USIQoMY29udGVudF90eXBlGAQgASgJUgtjb250ZW50VHlwZRIb'
    'CglmaWxlX25hbWUYBSABKAlSCGZpbGVOYW1lEh8KC3RvdGFsX2J5dGVzGAYgASgEUgp0b3RhbE'
    'J5dGVzEh8KC2NodW5rX2J5dGVzGAcgASgNUgpjaHVua0J5dGVzEhYKBnNoYTI1NhgIIAEoDFIG'
    'c2hhMjU2');

@$core.Deprecated('Use transferChunkDescriptor instead')
const TransferChunk$json = {
  '1': 'TransferChunk',
  '2': [
    {'1': 'transfer_id', '3': 1, '4': 1, '5': 9, '10': 'transferId'},
    {'1': 'chunk_sequence', '3': 2, '4': 1, '5': 4, '10': 'chunkSequence'},
    {'1': 'offset', '3': 3, '4': 1, '5': 4, '10': 'offset'},
    {'1': 'data', '3': 4, '4': 1, '5': 12, '10': 'data'},
  ],
};

/// Descriptor for `TransferChunk`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transferChunkDescriptor = $convert.base64Decode(
    'Cg1UcmFuc2ZlckNodW5rEh8KC3RyYW5zZmVyX2lkGAEgASgJUgp0cmFuc2ZlcklkEiUKDmNodW'
    '5rX3NlcXVlbmNlGAIgASgEUg1jaHVua1NlcXVlbmNlEhYKBm9mZnNldBgDIAEoBFIGb2Zmc2V0'
    'EhIKBGRhdGEYBCABKAxSBGRhdGE=');

@$core.Deprecated('Use transferAckDescriptor instead')
const TransferAck$json = {
  '1': 'TransferAck',
  '2': [
    {'1': 'transfer_id', '3': 1, '4': 1, '5': 9, '10': 'transferId'},
    {
      '1': 'acknowledged_sequence',
      '3': 2,
      '4': 1,
      '5': 4,
      '10': 'acknowledgedSequence'
    },
    {'1': 'committed_bytes', '3': 3, '4': 1, '5': 4, '10': 'committedBytes'},
  ],
};

/// Descriptor for `TransferAck`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transferAckDescriptor = $convert.base64Decode(
    'CgtUcmFuc2ZlckFjaxIfCgt0cmFuc2Zlcl9pZBgBIAEoCVIKdHJhbnNmZXJJZBIzChVhY2tub3'
    'dsZWRnZWRfc2VxdWVuY2UYAiABKARSFGFja25vd2xlZGdlZFNlcXVlbmNlEicKD2NvbW1pdHRl'
    'ZF9ieXRlcxgDIAEoBFIOY29tbWl0dGVkQnl0ZXM=');

@$core.Deprecated('Use transferCompleteDescriptor instead')
const TransferComplete$json = {
  '1': 'TransferComplete',
  '2': [
    {'1': 'transfer_id', '3': 1, '4': 1, '5': 9, '10': 'transferId'},
    {'1': 'total_bytes', '3': 2, '4': 1, '5': 4, '10': 'totalBytes'},
    {'1': 'sha256', '3': 3, '4': 1, '5': 12, '10': 'sha256'},
  ],
};

/// Descriptor for `TransferComplete`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transferCompleteDescriptor = $convert.base64Decode(
    'ChBUcmFuc2ZlckNvbXBsZXRlEh8KC3RyYW5zZmVyX2lkGAEgASgJUgp0cmFuc2ZlcklkEh8KC3'
    'RvdGFsX2J5dGVzGAIgASgEUgp0b3RhbEJ5dGVzEhYKBnNoYTI1NhgDIAEoDFIGc2hhMjU2');

@$core.Deprecated('Use transferAbortDescriptor instead')
const TransferAbort$json = {
  '1': 'TransferAbort',
  '2': [
    {'1': 'transfer_id', '3': 1, '4': 1, '5': 9, '10': 'transferId'},
    {
      '1': 'error',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.StableError',
      '10': 'error'
    },
  ],
};

/// Descriptor for `TransferAbort`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transferAbortDescriptor = $convert.base64Decode(
    'Cg1UcmFuc2ZlckFib3J0Eh8KC3RyYW5zZmVyX2lkGAEgASgJUgp0cmFuc2ZlcklkEjgKBWVycm'
    '9yGAIgASgLMiIucGkuY2xpZW50LnByb3RvY29sLnYwLlN0YWJsZUVycm9yUgVlcnJvcg==');

@$core.Deprecated('Use stableErrorDescriptor instead')
const StableError$json = {
  '1': 'StableError',
  '2': [
    {
      '1': 'code',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.pi.client.protocol.v0.ErrorCode',
      '10': 'code'
    },
    {'1': 'retryable', '3': 2, '4': 1, '5': 8, '10': 'retryable'},
    {
      '1': 'retry_after_millis',
      '3': 3,
      '4': 1,
      '5': 13,
      '10': 'retryAfterMillis'
    },
    {'1': 'safe_message', '3': 4, '4': 1, '5': 9, '10': 'safeMessage'},
  ],
};

/// Descriptor for `StableError`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List stableErrorDescriptor = $convert.base64Decode(
    'CgtTdGFibGVFcnJvchI0CgRjb2RlGAEgASgOMiAucGkuY2xpZW50LnByb3RvY29sLnYwLkVycm'
    '9yQ29kZVIEY29kZRIcCglyZXRyeWFibGUYAiABKAhSCXJldHJ5YWJsZRIsChJyZXRyeV9hZnRl'
    'cl9taWxsaXMYAyABKA1SEHJldHJ5QWZ0ZXJNaWxsaXMSIQoMc2FmZV9tZXNzYWdlGAQgASgJUg'
    'tzYWZlTWVzc2FnZQ==');

@$core.Deprecated('Use errorEnvelopeDescriptor instead')
const ErrorEnvelope$json = {
  '1': 'ErrorEnvelope',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 4, '9': 0, '10': 'requestId'},
    {'1': 'stream_id', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'streamId'},
    {'1': 'transfer_id', '3': 3, '4': 1, '5': 9, '9': 0, '10': 'transferId'},
    {
      '1': 'error',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.StableError',
      '10': 'error'
    },
  ],
  '8': [
    {'1': 'correlation'},
  ],
};

/// Descriptor for `ErrorEnvelope`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List errorEnvelopeDescriptor = $convert.base64Decode(
    'Cg1FcnJvckVudmVsb3BlEh8KCnJlcXVlc3RfaWQYASABKARIAFIJcmVxdWVzdElkEh0KCXN0cm'
    'VhbV9pZBgCIAEoCUgAUghzdHJlYW1JZBIhCgt0cmFuc2Zlcl9pZBgDIAEoCUgAUgp0cmFuc2Zl'
    'cklkEjgKBWVycm9yGAQgASgLMiIucGkuY2xpZW50LnByb3RvY29sLnYwLlN0YWJsZUVycm9yUg'
    'VlcnJvckINCgtjb3JyZWxhdGlvbg==');
