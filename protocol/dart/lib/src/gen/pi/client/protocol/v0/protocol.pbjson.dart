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
    {'1': 'CAPABILITY_SESSION_TREE', '2': 13},
    {'1': 'CAPABILITY_SESSION_HISTORY', '2': 14},
    {'1': 'CAPABILITY_SESSION_STATS', '2': 15},
    {'1': 'CAPABILITY_SESSION_EXPORT', '2': 16},
    {'1': 'CAPABILITY_RICH_CONVERSATION', '2': 17},
    {'1': 'CAPABILITY_MESSAGE_CONTENT', '2': 18},
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
    'lOEAwSGwoXQ0FQQUJJTElUWV9TRVNTSU9OX1RSRUUQDRIeChpDQVBBQklMSVRZX1NFU1NJT05f'
    'SElTVE9SWRAOEhwKGENBUEFCSUxJVFlfU0VTU0lPTl9TVEFUUxAPEh0KGUNBUEFCSUxJVFlfU0'
    'VTU0lPTl9FWFBPUlQQEBIgChxDQVBBQklMSVRZX1JJQ0hfQ09OVkVSU0FUSU9OEBESHgoaQ0FQ'
    'QUJJTElUWV9NRVNTQUdFX0NPTlRFTlQQEg==');

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

@$core.Deprecated('Use sessionTreeMutationOperationDescriptor instead')
const SessionTreeMutationOperation$json = {
  '1': 'SessionTreeMutationOperation',
  '2': [
    {'1': 'SESSION_TREE_MUTATION_OPERATION_UNSPECIFIED', '2': 0},
    {'1': 'SESSION_TREE_MUTATION_OPERATION_NAVIGATE', '2': 1},
    {'1': 'SESSION_TREE_MUTATION_OPERATION_FORK', '2': 2},
    {'1': 'SESSION_TREE_MUTATION_OPERATION_CLONE', '2': 3},
  ],
};

/// Descriptor for `SessionTreeMutationOperation`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List sessionTreeMutationOperationDescriptor = $convert.base64Decode(
    'ChxTZXNzaW9uVHJlZU11dGF0aW9uT3BlcmF0aW9uEi8KK1NFU1NJT05fVFJFRV9NVVRBVElPTl'
    '9PUEVSQVRJT05fVU5TUEVDSUZJRUQQABIsCihTRVNTSU9OX1RSRUVfTVVUQVRJT05fT1BFUkFU'
    'SU9OX05BVklHQVRFEAESKAokU0VTU0lPTl9UUkVFX01VVEFUSU9OX09QRVJBVElPTl9GT1JLEA'
    'ISKQolU0VTU0lPTl9UUkVFX01VVEFUSU9OX09QRVJBVElPTl9DTE9ORRAD');

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

@$core.Deprecated('Use sessionTreeEntryKindDescriptor instead')
const SessionTreeEntryKind$json = {
  '1': 'SessionTreeEntryKind',
  '2': [
    {'1': 'SESSION_TREE_ENTRY_KIND_UNSPECIFIED', '2': 0},
    {'1': 'SESSION_TREE_ENTRY_KIND_USER_MESSAGE', '2': 1},
    {'1': 'SESSION_TREE_ENTRY_KIND_ASSISTANT_MESSAGE', '2': 2},
    {'1': 'SESSION_TREE_ENTRY_KIND_TOOL_MESSAGE', '2': 3},
    {'1': 'SESSION_TREE_ENTRY_KIND_CUSTOM_MESSAGE', '2': 4},
    {'1': 'SESSION_TREE_ENTRY_KIND_THINKING_LEVEL', '2': 5},
    {'1': 'SESSION_TREE_ENTRY_KIND_MODEL_CHANGE', '2': 6},
    {'1': 'SESSION_TREE_ENTRY_KIND_COMPACTION', '2': 7},
    {'1': 'SESSION_TREE_ENTRY_KIND_BRANCH_SUMMARY', '2': 8},
    {'1': 'SESSION_TREE_ENTRY_KIND_CUSTOM', '2': 9},
    {'1': 'SESSION_TREE_ENTRY_KIND_LABEL', '2': 10},
    {'1': 'SESSION_TREE_ENTRY_KIND_SESSION_INFO', '2': 11},
  ],
};

/// Descriptor for `SessionTreeEntryKind`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List sessionTreeEntryKindDescriptor = $convert.base64Decode(
    'ChRTZXNzaW9uVHJlZUVudHJ5S2luZBInCiNTRVNTSU9OX1RSRUVfRU5UUllfS0lORF9VTlNQRU'
    'NJRklFRBAAEigKJFNFU1NJT05fVFJFRV9FTlRSWV9LSU5EX1VTRVJfTUVTU0FHRRABEi0KKVNF'
    'U1NJT05fVFJFRV9FTlRSWV9LSU5EX0FTU0lTVEFOVF9NRVNTQUdFEAISKAokU0VTU0lPTl9UUk'
    'VFX0VOVFJZX0tJTkRfVE9PTF9NRVNTQUdFEAMSKgomU0VTU0lPTl9UUkVFX0VOVFJZX0tJTkRf'
    'Q1VTVE9NX01FU1NBR0UQBBIqCiZTRVNTSU9OX1RSRUVfRU5UUllfS0lORF9USElOS0lOR19MRV'
    'ZFTBAFEigKJFNFU1NJT05fVFJFRV9FTlRSWV9LSU5EX01PREVMX0NIQU5HRRAGEiYKIlNFU1NJ'
    'T05fVFJFRV9FTlRSWV9LSU5EX0NPTVBBQ1RJT04QBxIqCiZTRVNTSU9OX1RSRUVfRU5UUllfS0'
    'lORF9CUkFOQ0hfU1VNTUFSWRAIEiIKHlNFU1NJT05fVFJFRV9FTlRSWV9LSU5EX0NVU1RPTRAJ'
    'EiEKHVNFU1NJT05fVFJFRV9FTlRSWV9LSU5EX0xBQkVMEAoSKAokU0VTU0lPTl9UUkVFX0VOVF'
    'JZX0tJTkRfU0VTU0lPTl9JTkZPEAs=');

@$core.Deprecated('Use conversationIdentityScopeDescriptor instead')
const ConversationIdentityScope$json = {
  '1': 'ConversationIdentityScope',
  '2': [
    {'1': 'CONVERSATION_IDENTITY_SCOPE_UNSPECIFIED', '2': 0},
    {'1': 'CONVERSATION_IDENTITY_SCOPE_PERSISTENT', '2': 1},
    {'1': 'CONVERSATION_IDENTITY_SCOPE_RUNTIME', '2': 2},
  ],
};

/// Descriptor for `ConversationIdentityScope`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List conversationIdentityScopeDescriptor = $convert.base64Decode(
    'ChlDb252ZXJzYXRpb25JZGVudGl0eVNjb3BlEisKJ0NPTlZFUlNBVElPTl9JREVOVElUWV9TQ0'
    '9QRV9VTlNQRUNJRklFRBAAEioKJkNPTlZFUlNBVElPTl9JREVOVElUWV9TQ09QRV9QRVJTSVNU'
    'RU5UEAESJwojQ09OVkVSU0FUSU9OX0lERU5USVRZX1NDT1BFX1JVTlRJTUUQAg==');

@$core.Deprecated('Use markerKindDescriptor instead')
const MarkerKind$json = {
  '1': 'MarkerKind',
  '2': [
    {'1': 'MARKER_KIND_UNSPECIFIED', '2': 0},
    {'1': 'MARKER_KIND_THINKING_LEVEL', '2': 1},
    {'1': 'MARKER_KIND_MODEL_CHANGE', '2': 2},
    {'1': 'MARKER_KIND_LABEL', '2': 3},
    {'1': 'MARKER_KIND_SESSION_INFO', '2': 4},
  ],
};

/// Descriptor for `MarkerKind`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List markerKindDescriptor = $convert.base64Decode(
    'CgpNYXJrZXJLaW5kEhsKF01BUktFUl9LSU5EX1VOU1BFQ0lGSUVEEAASHgoaTUFSS0VSX0tJTk'
    'RfVEhJTktJTkdfTEVWRUwQARIcChhNQVJLRVJfS0lORF9NT0RFTF9DSEFOR0UQAhIVChFNQVJL'
    'RVJfS0lORF9MQUJFTBADEhwKGE1BUktFUl9LSU5EX1NFU1NJT05fSU5GTxAE');

@$core.Deprecated('Use thinkingVisibilityDescriptor instead')
const ThinkingVisibility$json = {
  '1': 'ThinkingVisibility',
  '2': [
    {'1': 'THINKING_VISIBILITY_UNSPECIFIED', '2': 0},
    {'1': 'THINKING_VISIBILITY_VISIBLE', '2': 1},
    {'1': 'THINKING_VISIBILITY_REDACTED', '2': 2},
    {'1': 'THINKING_VISIBILITY_DEFERRED', '2': 3},
  ],
};

/// Descriptor for `ThinkingVisibility`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List thinkingVisibilityDescriptor = $convert.base64Decode(
    'ChJUaGlua2luZ1Zpc2liaWxpdHkSIwofVEhJTktJTkdfVklTSUJJTElUWV9VTlNQRUNJRklFRB'
    'AAEh8KG1RISU5LSU5HX1ZJU0lCSUxJVFlfVklTSUJMRRABEiAKHFRISU5LSU5HX1ZJU0lCSUxJ'
    'VFlfUkVEQUNURUQQAhIgChxUSElOS0lOR19WSVNJQklMSVRZX0RFRkVSUkVEEAM=');

@$core.Deprecated('Use safeValueKindDescriptor instead')
const SafeValueKind$json = {
  '1': 'SafeValueKind',
  '2': [
    {'1': 'SAFE_VALUE_KIND_UNSPECIFIED', '2': 0},
    {'1': 'SAFE_VALUE_KIND_NULL', '2': 1},
    {'1': 'SAFE_VALUE_KIND_REDACTED', '2': 2},
  ],
};

/// Descriptor for `SafeValueKind`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List safeValueKindDescriptor = $convert.base64Decode(
    'Cg1TYWZlVmFsdWVLaW5kEh8KG1NBRkVfVkFMVUVfS0lORF9VTlNQRUNJRklFRBAAEhgKFFNBRk'
    'VfVkFMVUVfS0lORF9OVUxMEAESHAoYU0FGRV9WQUxVRV9LSU5EX1JFREFDVEVEEAI=');

@$core.Deprecated('Use toolActivityStatusDescriptor instead')
const ToolActivityStatus$json = {
  '1': 'ToolActivityStatus',
  '2': [
    {'1': 'TOOL_ACTIVITY_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'TOOL_ACTIVITY_STATUS_PENDING', '2': 1},
    {'1': 'TOOL_ACTIVITY_STATUS_RUNNING', '2': 2},
    {'1': 'TOOL_ACTIVITY_STATUS_SUCCEEDED', '2': 3},
    {'1': 'TOOL_ACTIVITY_STATUS_FAILED', '2': 4},
    {'1': 'TOOL_ACTIVITY_STATUS_CANCELLED', '2': 5},
  ],
};

/// Descriptor for `ToolActivityStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List toolActivityStatusDescriptor = $convert.base64Decode(
    'ChJUb29sQWN0aXZpdHlTdGF0dXMSJAogVE9PTF9BQ1RJVklUWV9TVEFUVVNfVU5TUEVDSUZJRU'
    'QQABIgChxUT09MX0FDVElWSVRZX1NUQVRVU19QRU5ESU5HEAESIAocVE9PTF9BQ1RJVklUWV9T'
    'VEFUVVNfUlVOTklORxACEiIKHlRPT0xfQUNUSVZJVFlfU1RBVFVTX1NVQ0NFRURFRBADEh8KG1'
    'RPT0xfQUNUSVZJVFlfU1RBVFVTX0ZBSUxFRBAEEiIKHlRPT0xfQUNUSVZJVFlfU1RBVFVTX0NB'
    'TkNFTExFRBAF');

@$core.Deprecated('Use sessionExportFormatDescriptor instead')
const SessionExportFormat$json = {
  '1': 'SessionExportFormat',
  '2': [
    {'1': 'SESSION_EXPORT_FORMAT_UNSPECIFIED', '2': 0},
    {'1': 'SESSION_EXPORT_FORMAT_HTML', '2': 1},
    {'1': 'SESSION_EXPORT_FORMAT_JSONL', '2': 2},
  ],
};

/// Descriptor for `SessionExportFormat`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List sessionExportFormatDescriptor = $convert.base64Decode(
    'ChNTZXNzaW9uRXhwb3J0Rm9ybWF0EiUKIVNFU1NJT05fRVhQT1JUX0ZPUk1BVF9VTlNQRUNJRk'
    'lFRBAAEh4KGlNFU1NJT05fRVhQT1JUX0ZPUk1BVF9IVE1MEAESHwobU0VTU0lPTl9FWFBPUlRf'
    'Rk9STUFUX0pTT05MEAI=');

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
    {'1': 'TRANSFER_PURPOSE_MESSAGE_CONTENT', '2': 4},
  ],
};

/// Descriptor for `TransferPurpose`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List transferPurposeDescriptor = $convert.base64Decode(
    'Cg9UcmFuc2ZlclB1cnBvc2USIAocVFJBTlNGRVJfUFVSUE9TRV9VTlNQRUNJRklFRBAAEhkKFV'
    'RSQU5TRkVSX1BVUlBPU0VfRklMRRABEh8KG1RSQU5TRkVSX1BVUlBPU0VfQVRUQUNITUVOVBAC'
    'EhsKF1RSQU5TRkVSX1BVUlBPU0VfRVhQT1JUEAMSJAogVFJBTlNGRVJfUFVSUE9TRV9NRVNTQU'
    'dFX0NPTlRFTlQQBA==');

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
      '1': 'get_session_tree_request',
      '3': 48,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.GetSessionTreeRequest',
      '9': 0,
      '10': 'getSessionTreeRequest'
    },
    {
      '1': 'get_session_tree_response',
      '3': 49,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.GetSessionTreeResponse',
      '9': 0,
      '10': 'getSessionTreeResponse'
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
      '1': 'navigate_session_tree_command',
      '3': 52,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.NavigateSessionTreeCommand',
      '9': 0,
      '10': 'navigateSessionTreeCommand'
    },
    {
      '1': 'fork_session_command',
      '3': 53,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.ForkSessionCommand',
      '9': 0,
      '10': 'forkSessionCommand'
    },
    {
      '1': 'clone_session_command',
      '3': 54,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.CloneSessionCommand',
      '9': 0,
      '10': 'cloneSessionCommand'
    },
    {
      '1': 'session_tree_mutation_outcome',
      '3': 55,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.SessionTreeMutationOutcome',
      '9': 0,
      '10': 'sessionTreeMutationOutcome'
    },
    {
      '1': 'get_session_history_request',
      '3': 56,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.GetSessionHistoryRequest',
      '9': 0,
      '10': 'getSessionHistoryRequest'
    },
    {
      '1': 'get_session_history_response',
      '3': 57,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.GetSessionHistoryResponse',
      '9': 0,
      '10': 'getSessionHistoryResponse'
    },
    {
      '1': 'get_session_stats_request',
      '3': 58,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.GetSessionStatsRequest',
      '9': 0,
      '10': 'getSessionStatsRequest'
    },
    {
      '1': 'get_session_stats_response',
      '3': 59,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.GetSessionStatsResponse',
      '9': 0,
      '10': 'getSessionStatsResponse'
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
      '1': 'export_session_request',
      '3': 62,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.ExportSessionRequest',
      '9': 0,
      '10': 'exportSessionRequest'
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
    {
      '1': 'get_message_content_request',
      '3': 100,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.GetMessageContentRequest',
      '9': 0,
      '10': 'getMessageContentRequest'
    },
  ],
  '8': [
    {'1': 'operation'},
  ],
  '9': [
    {'1': 2, '2': 10},
    {'1': 13, '2': 20},
    {'1': 63, '2': 70},
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
    'YW5kT3V0Y29tZRJnChhnZXRfc2Vzc2lvbl90cmVlX3JlcXVlc3QYMCABKAsyLC5waS5jbGllbn'
    'QucHJvdG9jb2wudjAuR2V0U2Vzc2lvblRyZWVSZXF1ZXN0SABSFWdldFNlc3Npb25UcmVlUmVx'
    'dWVzdBJqChlnZXRfc2Vzc2lvbl90cmVlX3Jlc3BvbnNlGDEgASgLMi0ucGkuY2xpZW50LnByb3'
    'RvY29sLnYwLkdldFNlc3Npb25UcmVlUmVzcG9uc2VIAFIWZ2V0U2Vzc2lvblRyZWVSZXNwb25z'
    'ZRJlChRzZXNzaW9uX2V2ZW50X3N0cmVhbRgyIAEoCzIxLnBpLmNsaWVudC5wcm90b2NvbC52MC'
    '5TZXNzaW9uRXZlbnRTdHJlYW1FbnZlbG9wZUgAUhJzZXNzaW9uRXZlbnRTdHJlYW0STwoMZXZl'
    'bnRfc3RyZWFtGDMgASgLMioucGkuY2xpZW50LnByb3RvY29sLnYwLkV2ZW50U3RyZWFtRW52ZW'
    'xvcGVIAFILZXZlbnRTdHJlYW0SdgodbmF2aWdhdGVfc2Vzc2lvbl90cmVlX2NvbW1hbmQYNCAB'
    'KAsyMS5waS5jbGllbnQucHJvdG9jb2wudjAuTmF2aWdhdGVTZXNzaW9uVHJlZUNvbW1hbmRIAF'
    'IabmF2aWdhdGVTZXNzaW9uVHJlZUNvbW1hbmQSXQoUZm9ya19zZXNzaW9uX2NvbW1hbmQYNSAB'
    'KAsyKS5waS5jbGllbnQucHJvdG9jb2wudjAuRm9ya1Nlc3Npb25Db21tYW5kSABSEmZvcmtTZX'
    'NzaW9uQ29tbWFuZBJgChVjbG9uZV9zZXNzaW9uX2NvbW1hbmQYNiABKAsyKi5waS5jbGllbnQu'
    'cHJvdG9jb2wudjAuQ2xvbmVTZXNzaW9uQ29tbWFuZEgAUhNjbG9uZVNlc3Npb25Db21tYW5kEn'
    'YKHXNlc3Npb25fdHJlZV9tdXRhdGlvbl9vdXRjb21lGDcgASgLMjEucGkuY2xpZW50LnByb3Rv'
    'Y29sLnYwLlNlc3Npb25UcmVlTXV0YXRpb25PdXRjb21lSABSGnNlc3Npb25UcmVlTXV0YXRpb2'
    '5PdXRjb21lEnAKG2dldF9zZXNzaW9uX2hpc3RvcnlfcmVxdWVzdBg4IAEoCzIvLnBpLmNsaWVu'
    'dC5wcm90b2NvbC52MC5HZXRTZXNzaW9uSGlzdG9yeVJlcXVlc3RIAFIYZ2V0U2Vzc2lvbkhpc3'
    'RvcnlSZXF1ZXN0EnMKHGdldF9zZXNzaW9uX2hpc3RvcnlfcmVzcG9uc2UYOSABKAsyMC5waS5j'
    'bGllbnQucHJvdG9jb2wudjAuR2V0U2Vzc2lvbkhpc3RvcnlSZXNwb25zZUgAUhlnZXRTZXNzaW'
    '9uSGlzdG9yeVJlc3BvbnNlEmoKGWdldF9zZXNzaW9uX3N0YXRzX3JlcXVlc3QYOiABKAsyLS5w'
    'aS5jbGllbnQucHJvdG9jb2wudjAuR2V0U2Vzc2lvblN0YXRzUmVxdWVzdEgAUhZnZXRTZXNzaW'
    '9uU3RhdHNSZXF1ZXN0Em0KGmdldF9zZXNzaW9uX3N0YXRzX3Jlc3BvbnNlGDsgASgLMi4ucGku'
    'Y2xpZW50LnByb3RvY29sLnYwLkdldFNlc3Npb25TdGF0c1Jlc3BvbnNlSABSF2dldFNlc3Npb2'
    '5TdGF0c1Jlc3BvbnNlEjcKBmNhbmNlbBg8IAEoCzIdLnBpLmNsaWVudC5wcm90b2NvbC52MC5D'
    'YW5jZWxIAFIGY2FuY2VsEkoKDXdpbmRvd191cGRhdGUYPSABKAsyIy5waS5jbGllbnQucHJvdG'
    '9jb2wudjAuV2luZG93VXBkYXRlSABSDHdpbmRvd1VwZGF0ZRJjChZleHBvcnRfc2Vzc2lvbl9y'
    'ZXF1ZXN0GD4gASgLMisucGkuY2xpZW50LnByb3RvY29sLnYwLkV4cG9ydFNlc3Npb25SZXF1ZX'
    'N0SABSFGV4cG9ydFNlc3Npb25SZXF1ZXN0EkoKDXRyYW5zZmVyX29wZW4YRiABKAsyIy5waS5j'
    'bGllbnQucHJvdG9jb2wudjAuVHJhbnNmZXJPcGVuSABSDHRyYW5zZmVyT3BlbhJNCg50cmFuc2'
    'Zlcl9jaHVuaxhHIAEoCzIkLnBpLmNsaWVudC5wcm90b2NvbC52MC5UcmFuc2ZlckNodW5rSABS'
    'DXRyYW5zZmVyQ2h1bmsSRwoMdHJhbnNmZXJfYWNrGEggASgLMiIucGkuY2xpZW50LnByb3RvY2'
    '9sLnYwLlRyYW5zZmVyQWNrSABSC3RyYW5zZmVyQWNrElYKEXRyYW5zZmVyX2NvbXBsZXRlGEkg'
    'ASgLMicucGkuY2xpZW50LnByb3RvY29sLnYwLlRyYW5zZmVyQ29tcGxldGVIAFIQdHJhbnNmZX'
    'JDb21wbGV0ZRJNCg50cmFuc2Zlcl9hYm9ydBhKIAEoCzIkLnBpLmNsaWVudC5wcm90b2NvbC52'
    'MC5UcmFuc2ZlckFib3J0SABSDXRyYW5zZmVyQWJvcnQSPAoFZXJyb3IYUCABKAsyJC5waS5jbG'
    'llbnQucHJvdG9jb2wudjAuRXJyb3JFbnZlbG9wZUgAUgVlcnJvchJwChtnZXRfbWVzc2FnZV9j'
    'b250ZW50X3JlcXVlc3QYZCABKAsyLy5waS5jbGllbnQucHJvdG9jb2wudjAuR2V0TWVzc2FnZU'
    'NvbnRlbnRSZXF1ZXN0SABSGGdldE1lc3NhZ2VDb250ZW50UmVxdWVzdEILCglvcGVyYXRpb25K'
    'BAgCEApKBAgNEBRKBAg/EEZKBAhLEFBKBAhREGQ=');

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

@$core.Deprecated('Use getSessionTreeRequestDescriptor instead')
const GetSessionTreeRequest$json = {
  '1': 'GetSessionTreeRequest',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 4, '10': 'requestId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'session_id', '3': 3, '4': 1, '5': 9, '10': 'sessionId'},
  ],
};

/// Descriptor for `GetSessionTreeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSessionTreeRequestDescriptor = $convert.base64Decode(
    'ChVHZXRTZXNzaW9uVHJlZVJlcXVlc3QSHQoKcmVxdWVzdF9pZBgBIAEoBFIJcmVxdWVzdElkEh'
    '0KCnByb2plY3RfaWQYAiABKAlSCXByb2plY3RJZBIdCgpzZXNzaW9uX2lkGAMgASgJUglzZXNz'
    'aW9uSWQ=');

@$core.Deprecated('Use getSessionTreeResponseDescriptor instead')
const GetSessionTreeResponse$json = {
  '1': 'GetSessionTreeResponse',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 4, '10': 'requestId'},
    {
      '1': 'tree',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.SessionTreeSnapshot',
      '10': 'tree'
    },
  ],
};

/// Descriptor for `GetSessionTreeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSessionTreeResponseDescriptor = $convert.base64Decode(
    'ChZHZXRTZXNzaW9uVHJlZVJlc3BvbnNlEh0KCnJlcXVlc3RfaWQYASABKARSCXJlcXVlc3RJZB'
    'I+CgR0cmVlGAIgASgLMioucGkuY2xpZW50LnByb3RvY29sLnYwLlNlc3Npb25UcmVlU25hcHNo'
    'b3RSBHRyZWU=');

@$core.Deprecated('Use navigateSessionTreeCommandDescriptor instead')
const NavigateSessionTreeCommand$json = {
  '1': 'NavigateSessionTreeCommand',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 4, '10': 'requestId'},
    {'1': 'command_id', '3': 2, '4': 1, '5': 9, '10': 'commandId'},
    {'1': 'project_id', '3': 3, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'session_id', '3': 4, '4': 1, '5': 9, '10': 'sessionId'},
    {'1': 'entry_id', '3': 5, '4': 1, '5': 9, '10': 'entryId'},
    {
      '1': 'expected_admin_revision',
      '3': 6,
      '4': 1,
      '5': 9,
      '10': 'expectedAdminRevision'
    },
  ],
};

/// Descriptor for `NavigateSessionTreeCommand`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List navigateSessionTreeCommandDescriptor = $convert.base64Decode(
    'ChpOYXZpZ2F0ZVNlc3Npb25UcmVlQ29tbWFuZBIdCgpyZXF1ZXN0X2lkGAEgASgEUglyZXF1ZX'
    'N0SWQSHQoKY29tbWFuZF9pZBgCIAEoCVIJY29tbWFuZElkEh0KCnByb2plY3RfaWQYAyABKAlS'
    'CXByb2plY3RJZBIdCgpzZXNzaW9uX2lkGAQgASgJUglzZXNzaW9uSWQSGQoIZW50cnlfaWQYBS'
    'ABKAlSB2VudHJ5SWQSNgoXZXhwZWN0ZWRfYWRtaW5fcmV2aXNpb24YBiABKAlSFWV4cGVjdGVk'
    'QWRtaW5SZXZpc2lvbg==');

@$core.Deprecated('Use forkSessionCommandDescriptor instead')
const ForkSessionCommand$json = {
  '1': 'ForkSessionCommand',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 4, '10': 'requestId'},
    {'1': 'command_id', '3': 2, '4': 1, '5': 9, '10': 'commandId'},
    {'1': 'project_id', '3': 3, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'session_id', '3': 4, '4': 1, '5': 9, '10': 'sessionId'},
    {'1': 'user_entry_id', '3': 5, '4': 1, '5': 9, '10': 'userEntryId'},
    {
      '1': 'expected_admin_revision',
      '3': 6,
      '4': 1,
      '5': 9,
      '10': 'expectedAdminRevision'
    },
  ],
};

/// Descriptor for `ForkSessionCommand`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List forkSessionCommandDescriptor = $convert.base64Decode(
    'ChJGb3JrU2Vzc2lvbkNvbW1hbmQSHQoKcmVxdWVzdF9pZBgBIAEoBFIJcmVxdWVzdElkEh0KCm'
    'NvbW1hbmRfaWQYAiABKAlSCWNvbW1hbmRJZBIdCgpwcm9qZWN0X2lkGAMgASgJUglwcm9qZWN0'
    'SWQSHQoKc2Vzc2lvbl9pZBgEIAEoCVIJc2Vzc2lvbklkEiIKDXVzZXJfZW50cnlfaWQYBSABKA'
    'lSC3VzZXJFbnRyeUlkEjYKF2V4cGVjdGVkX2FkbWluX3JldmlzaW9uGAYgASgJUhVleHBlY3Rl'
    'ZEFkbWluUmV2aXNpb24=');

@$core.Deprecated('Use cloneSessionCommandDescriptor instead')
const CloneSessionCommand$json = {
  '1': 'CloneSessionCommand',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 4, '10': 'requestId'},
    {'1': 'command_id', '3': 2, '4': 1, '5': 9, '10': 'commandId'},
    {'1': 'project_id', '3': 3, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'session_id', '3': 4, '4': 1, '5': 9, '10': 'sessionId'},
    {
      '1': 'expected_admin_revision',
      '3': 5,
      '4': 1,
      '5': 9,
      '10': 'expectedAdminRevision'
    },
  ],
};

/// Descriptor for `CloneSessionCommand`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cloneSessionCommandDescriptor = $convert.base64Decode(
    'ChNDbG9uZVNlc3Npb25Db21tYW5kEh0KCnJlcXVlc3RfaWQYASABKARSCXJlcXVlc3RJZBIdCg'
    'pjb21tYW5kX2lkGAIgASgJUgljb21tYW5kSWQSHQoKcHJvamVjdF9pZBgDIAEoCVIJcHJvamVj'
    'dElkEh0KCnNlc3Npb25faWQYBCABKAlSCXNlc3Npb25JZBI2ChdleHBlY3RlZF9hZG1pbl9yZX'
    'Zpc2lvbhgFIAEoCVIVZXhwZWN0ZWRBZG1pblJldmlzaW9u');

@$core.Deprecated('Use sessionTreeMutationResultDescriptor instead')
const SessionTreeMutationResult$json = {
  '1': 'SessionTreeMutationResult',
  '2': [
    {
      '1': 'session',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.SessionDetailSnapshot',
      '10': 'session'
    },
    {
      '1': 'tree',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.SessionTreeSnapshot',
      '10': 'tree'
    },
    {'1': 'editor_text', '3': 3, '4': 1, '5': 9, '10': 'editorText'},
  ],
};

/// Descriptor for `SessionTreeMutationResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sessionTreeMutationResultDescriptor = $convert.base64Decode(
    'ChlTZXNzaW9uVHJlZU11dGF0aW9uUmVzdWx0EkYKB3Nlc3Npb24YASABKAsyLC5waS5jbGllbn'
    'QucHJvdG9jb2wudjAuU2Vzc2lvbkRldGFpbFNuYXBzaG90UgdzZXNzaW9uEj4KBHRyZWUYAiAB'
    'KAsyKi5waS5jbGllbnQucHJvdG9jb2wudjAuU2Vzc2lvblRyZWVTbmFwc2hvdFIEdHJlZRIfCg'
    'tlZGl0b3JfdGV4dBgDIAEoCVIKZWRpdG9yVGV4dA==');

@$core.Deprecated('Use sessionTreeMutationOutcomeDescriptor instead')
const SessionTreeMutationOutcome$json = {
  '1': 'SessionTreeMutationOutcome',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 4, '10': 'requestId'},
    {'1': 'command_id', '3': 2, '4': 1, '5': 9, '10': 'commandId'},
    {
      '1': 'operation',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.pi.client.protocol.v0.SessionTreeMutationOperation',
      '10': 'operation'
    },
    {
      '1': 'result',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.SessionTreeMutationResult',
      '9': 0,
      '10': 'result'
    },
    {
      '1': 'error',
      '3': 11,
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

/// Descriptor for `SessionTreeMutationOutcome`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sessionTreeMutationOutcomeDescriptor = $convert.base64Decode(
    'ChpTZXNzaW9uVHJlZU11dGF0aW9uT3V0Y29tZRIdCgpyZXF1ZXN0X2lkGAEgASgEUglyZXF1ZX'
    'N0SWQSHQoKY29tbWFuZF9pZBgCIAEoCVIJY29tbWFuZElkElEKCW9wZXJhdGlvbhgDIAEoDjIz'
    'LnBpLmNsaWVudC5wcm90b2NvbC52MC5TZXNzaW9uVHJlZU11dGF0aW9uT3BlcmF0aW9uUglvcG'
    'VyYXRpb24SSgoGcmVzdWx0GAogASgLMjAucGkuY2xpZW50LnByb3RvY29sLnYwLlNlc3Npb25U'
    'cmVlTXV0YXRpb25SZXN1bHRIAFIGcmVzdWx0EjoKBWVycm9yGAsgASgLMiIucGkuY2xpZW50Ln'
    'Byb3RvY29sLnYwLlN0YWJsZUVycm9ySABSBWVycm9yQgkKB291dGNvbWVKBAgEEAo=');

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
    {
      '1': 'parent_session_id',
      '3': 10,
      '4': 1,
      '5': 9,
      '10': 'parentSessionId'
    },
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
    'aGFzX2N1c3RvbV9uYW1lGAkgASgIUg1oYXNDdXN0b21OYW1lEioKEXBhcmVudF9zZXNzaW9uX2'
    'lkGAogASgJUg9wYXJlbnRTZXNzaW9uSWQ=');

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
      '1': 'conversation',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.ConversationSnapshot',
      '10': 'conversation'
    },
  ],
  '9': [
    {'1': 2, '2': 3},
  ],
};

/// Descriptor for `SessionDetailSnapshot`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sessionDetailSnapshotDescriptor = $convert.base64Decode(
    'ChVTZXNzaW9uRGV0YWlsU25hcHNob3QSRwoHc3VtbWFyeRgBIAEoCzItLnBpLmNsaWVudC5wcm'
    '90b2NvbC52MC5TZXNzaW9uU3VtbWFyeVNuYXBzaG90UgdzdW1tYXJ5Ek8KDGNvbnZlcnNhdGlv'
    'bhgDIAEoCzIrLnBpLmNsaWVudC5wcm90b2NvbC52MC5Db252ZXJzYXRpb25TbmFwc2hvdFIMY2'
    '9udmVyc2F0aW9uSgQIAhAD');

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
  '7': {'3': true},
};

/// Descriptor for `MessageSnapshot`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageSnapshotDescriptor = $convert.base64Decode(
    'Cg9NZXNzYWdlU25hcHNob3QSHQoKbWVzc2FnZV9pZBgBIAEoCVIJbWVzc2FnZUlkEjYKBHJvbG'
    'UYAiABKA4yIi5waS5jbGllbnQucHJvdG9jb2wudjAuTWVzc2FnZVJvbGVSBHJvbGUSEgoEdGV4'
    'dBgDIAEoCVIEdGV4dBIzChZjcmVhdGVkX2F0X3VuaXhfbWlsbGlzGAQgASgEUhNjcmVhdGVkQX'
    'RVbml4TWlsbGlzEiEKDGlzX3N0cmVhbWluZxgFIAEoCFILaXNTdHJlYW1pbmc6AhgB');

@$core.Deprecated('Use sessionTreeNodeSnapshotDescriptor instead')
const SessionTreeNodeSnapshot$json = {
  '1': 'SessionTreeNodeSnapshot',
  '2': [
    {'1': 'entry_id', '3': 1, '4': 1, '5': 9, '10': 'entryId'},
    {'1': 'parent_entry_id', '3': 2, '4': 1, '5': 9, '10': 'parentEntryId'},
    {
      '1': 'kind',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.pi.client.protocol.v0.SessionTreeEntryKind',
      '10': 'kind'
    },
    {'1': 'text', '3': 4, '4': 1, '5': 9, '10': 'text'},
    {
      '1': 'created_at_unix_millis',
      '3': 5,
      '4': 1,
      '5': 4,
      '10': 'createdAtUnixMillis'
    },
    {'1': 'label', '3': 6, '4': 1, '5': 9, '10': 'label'},
    {'1': 'depth', '3': 7, '4': 1, '5': 13, '10': 'depth'},
    {'1': 'is_on_active_path', '3': 8, '4': 1, '5': 8, '10': 'isOnActivePath'},
    {'1': 'has_children', '3': 9, '4': 1, '5': 8, '10': 'hasChildren'},
    {
      '1': 'can_edit_from_here',
      '3': 10,
      '4': 1,
      '5': 8,
      '10': 'canEditFromHere'
    },
    {'1': 'can_fork', '3': 11, '4': 1, '5': 8, '10': 'canFork'},
  ],
};

/// Descriptor for `SessionTreeNodeSnapshot`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sessionTreeNodeSnapshotDescriptor = $convert.base64Decode(
    'ChdTZXNzaW9uVHJlZU5vZGVTbmFwc2hvdBIZCghlbnRyeV9pZBgBIAEoCVIHZW50cnlJZBImCg'
    '9wYXJlbnRfZW50cnlfaWQYAiABKAlSDXBhcmVudEVudHJ5SWQSPwoEa2luZBgDIAEoDjIrLnBp'
    'LmNsaWVudC5wcm90b2NvbC52MC5TZXNzaW9uVHJlZUVudHJ5S2luZFIEa2luZBISCgR0ZXh0GA'
    'QgASgJUgR0ZXh0EjMKFmNyZWF0ZWRfYXRfdW5peF9taWxsaXMYBSABKARSE2NyZWF0ZWRBdFVu'
    'aXhNaWxsaXMSFAoFbGFiZWwYBiABKAlSBWxhYmVsEhQKBWRlcHRoGAcgASgNUgVkZXB0aBIpCh'
    'Fpc19vbl9hY3RpdmVfcGF0aBgIIAEoCFIOaXNPbkFjdGl2ZVBhdGgSIQoMaGFzX2NoaWxkcmVu'
    'GAkgASgIUgtoYXNDaGlsZHJlbhIrChJjYW5fZWRpdF9mcm9tX2hlcmUYCiABKAhSD2NhbkVkaX'
    'RGcm9tSGVyZRIZCghjYW5fZm9yaxgLIAEoCFIHY2FuRm9yaw==');

@$core.Deprecated('Use sessionTreeSnapshotDescriptor instead')
const SessionTreeSnapshot$json = {
  '1': 'SessionTreeSnapshot',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
    {
      '1': 'nodes',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.pi.client.protocol.v0.SessionTreeNodeSnapshot',
      '10': 'nodes'
    },
    {
      '1': 'active_path_entry_ids',
      '3': 3,
      '4': 3,
      '5': 9,
      '10': 'activePathEntryIds'
    },
    {
      '1': 'active_leaf_entry_id',
      '3': 4,
      '4': 1,
      '5': 9,
      '10': 'activeLeafEntryId'
    },
    {
      '1': 'can_clone_active_branch',
      '3': 5,
      '4': 1,
      '5': 8,
      '10': 'canCloneActiveBranch'
    },
    {'1': 'admin_revision', '3': 6, '4': 1, '5': 9, '10': 'adminRevision'},
  ],
};

/// Descriptor for `SessionTreeSnapshot`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sessionTreeSnapshotDescriptor = $convert.base64Decode(
    'ChNTZXNzaW9uVHJlZVNuYXBzaG90Eh0KCnNlc3Npb25faWQYASABKAlSCXNlc3Npb25JZBJECg'
    'Vub2RlcxgCIAMoCzIuLnBpLmNsaWVudC5wcm90b2NvbC52MC5TZXNzaW9uVHJlZU5vZGVTbmFw'
    'c2hvdFIFbm9kZXMSMQoVYWN0aXZlX3BhdGhfZW50cnlfaWRzGAMgAygJUhJhY3RpdmVQYXRoRW'
    '50cnlJZHMSLwoUYWN0aXZlX2xlYWZfZW50cnlfaWQYBCABKAlSEWFjdGl2ZUxlYWZFbnRyeUlk'
    'EjUKF2Nhbl9jbG9uZV9hY3RpdmVfYnJhbmNoGAUgASgIUhRjYW5DbG9uZUFjdGl2ZUJyYW5jaB'
    'IlCg5hZG1pbl9yZXZpc2lvbhgGIAEoCVINYWRtaW5SZXZpc2lvbg==');

@$core.Deprecated('Use getSessionHistoryRequestDescriptor instead')
const GetSessionHistoryRequest$json = {
  '1': 'GetSessionHistoryRequest',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 4, '10': 'requestId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'session_id', '3': 3, '4': 1, '5': 9, '10': 'sessionId'},
    {'1': 'cursor', '3': 4, '4': 1, '5': 9, '10': 'cursor'},
    {'1': 'limit', '3': 5, '4': 1, '5': 13, '10': 'limit'},
    {
      '1': 'expected_active_branch_revision',
      '3': 6,
      '4': 1,
      '5': 9,
      '10': 'expectedActiveBranchRevision'
    },
    {
      '1': 'expected_tree_revision',
      '3': 7,
      '4': 1,
      '5': 9,
      '10': 'expectedTreeRevision'
    },
  ],
};

/// Descriptor for `GetSessionHistoryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSessionHistoryRequestDescriptor = $convert.base64Decode(
    'ChhHZXRTZXNzaW9uSGlzdG9yeVJlcXVlc3QSHQoKcmVxdWVzdF9pZBgBIAEoBFIJcmVxdWVzdE'
    'lkEh0KCnByb2plY3RfaWQYAiABKAlSCXByb2plY3RJZBIdCgpzZXNzaW9uX2lkGAMgASgJUglz'
    'ZXNzaW9uSWQSFgoGY3Vyc29yGAQgASgJUgZjdXJzb3ISFAoFbGltaXQYBSABKA1SBWxpbWl0Ek'
    'UKH2V4cGVjdGVkX2FjdGl2ZV9icmFuY2hfcmV2aXNpb24YBiABKAlSHGV4cGVjdGVkQWN0aXZl'
    'QnJhbmNoUmV2aXNpb24SNAoWZXhwZWN0ZWRfdHJlZV9yZXZpc2lvbhgHIAEoCVIUZXhwZWN0ZW'
    'RUcmVlUmV2aXNpb24=');

@$core.Deprecated('Use getSessionHistoryResponseDescriptor instead')
const GetSessionHistoryResponse$json = {
  '1': 'GetSessionHistoryResponse',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 4, '10': 'requestId'},
    {
      '1': 'summary',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.SessionSummarySnapshot',
      '10': 'summary'
    },
    {
      '1': 'conversation',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.ConversationPage',
      '10': 'conversation'
    },
  ],
  '9': [
    {'1': 3, '2': 8},
  ],
};

/// Descriptor for `GetSessionHistoryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSessionHistoryResponseDescriptor = $convert.base64Decode(
    'ChlHZXRTZXNzaW9uSGlzdG9yeVJlc3BvbnNlEh0KCnJlcXVlc3RfaWQYASABKARSCXJlcXVlc3'
    'RJZBJHCgdzdW1tYXJ5GAIgASgLMi0ucGkuY2xpZW50LnByb3RvY29sLnYwLlNlc3Npb25TdW1t'
    'YXJ5U25hcHNob3RSB3N1bW1hcnkSSwoMY29udmVyc2F0aW9uGAggASgLMicucGkuY2xpZW50Ln'
    'Byb3RvY29sLnYwLkNvbnZlcnNhdGlvblBhZ2VSDGNvbnZlcnNhdGlvbkoECAMQCA==');

@$core.Deprecated('Use conversationEntryIdentityDescriptor instead')
const ConversationEntryIdentity$json = {
  '1': 'ConversationEntryIdentity',
  '2': [
    {'1': 'entry_id', '3': 1, '4': 1, '5': 9, '10': 'entryId'},
    {
      '1': 'scope',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.pi.client.protocol.v0.ConversationIdentityScope',
      '10': 'scope'
    },
    {'1': 'origin_command_id', '3': 3, '4': 1, '5': 9, '10': 'originCommandId'},
  ],
};

/// Descriptor for `ConversationEntryIdentity`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationEntryIdentityDescriptor = $convert.base64Decode(
    'ChlDb252ZXJzYXRpb25FbnRyeUlkZW50aXR5EhkKCGVudHJ5X2lkGAEgASgJUgdlbnRyeUlkEk'
    'YKBXNjb3BlGAIgASgOMjAucGkuY2xpZW50LnByb3RvY29sLnYwLkNvbnZlcnNhdGlvbklkZW50'
    'aXR5U2NvcGVSBXNjb3BlEioKEW9yaWdpbl9jb21tYW5kX2lkGAMgASgJUg9vcmlnaW5Db21tYW'
    '5kSWQ=');

@$core.Deprecated('Use conversationSnapshotDescriptor instead')
const ConversationSnapshot$json = {
  '1': 'ConversationSnapshot',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
    {
      '1': 'entries',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.pi.client.protocol.v0.ConversationEntry',
      '10': 'entries'
    },
    {
      '1': 'last_event_sequence',
      '3': 3,
      '4': 1,
      '5': 4,
      '10': 'lastEventSequence'
    },
  ],
};

/// Descriptor for `ConversationSnapshot`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationSnapshotDescriptor = $convert.base64Decode(
    'ChRDb252ZXJzYXRpb25TbmFwc2hvdBIdCgpzZXNzaW9uX2lkGAEgASgJUglzZXNzaW9uSWQSQg'
    'oHZW50cmllcxgCIAMoCzIoLnBpLmNsaWVudC5wcm90b2NvbC52MC5Db252ZXJzYXRpb25FbnRy'
    'eVIHZW50cmllcxIuChNsYXN0X2V2ZW50X3NlcXVlbmNlGAMgASgEUhFsYXN0RXZlbnRTZXF1ZW'
    '5jZQ==');

@$core.Deprecated('Use conversationPageDescriptor instead')
const ConversationPage$json = {
  '1': 'ConversationPage',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
    {
      '1': 'entries',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.pi.client.protocol.v0.ConversationEntry',
      '10': 'entries'
    },
    {'1': 'next_cursor', '3': 3, '4': 1, '5': 9, '10': 'nextCursor'},
    {'1': 'has_more', '3': 4, '4': 1, '5': 8, '10': 'hasMore'},
    {
      '1': 'active_branch_revision',
      '3': 5,
      '4': 1,
      '5': 9,
      '10': 'activeBranchRevision'
    },
    {'1': 'tree_revision', '3': 6, '4': 1, '5': 9, '10': 'treeRevision'},
    {
      '1': 'last_event_sequence',
      '3': 7,
      '4': 1,
      '5': 4,
      '10': 'lastEventSequence'
    },
  ],
};

/// Descriptor for `ConversationPage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationPageDescriptor = $convert.base64Decode(
    'ChBDb252ZXJzYXRpb25QYWdlEh0KCnNlc3Npb25faWQYASABKAlSCXNlc3Npb25JZBJCCgdlbn'
    'RyaWVzGAIgAygLMigucGkuY2xpZW50LnByb3RvY29sLnYwLkNvbnZlcnNhdGlvbkVudHJ5Ugdl'
    'bnRyaWVzEh8KC25leHRfY3Vyc29yGAMgASgJUgpuZXh0Q3Vyc29yEhkKCGhhc19tb3JlGAQgAS'
    'gIUgdoYXNNb3JlEjQKFmFjdGl2ZV9icmFuY2hfcmV2aXNpb24YBSABKAlSFGFjdGl2ZUJyYW5j'
    'aFJldmlzaW9uEiMKDXRyZWVfcmV2aXNpb24YBiABKAlSDHRyZWVSZXZpc2lvbhIuChNsYXN0X2'
    'V2ZW50X3NlcXVlbmNlGAcgASgEUhFsYXN0RXZlbnRTZXF1ZW5jZQ==');

@$core.Deprecated('Use conversationEntryDescriptor instead')
const ConversationEntry$json = {
  '1': 'ConversationEntry',
  '2': [
    {
      '1': 'identity',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.ConversationEntryIdentity',
      '10': 'identity'
    },
    {'1': 'revision', '3': 2, '4': 1, '5': 4, '10': 'revision'},
    {
      '1': 'created_at_unix_millis',
      '3': 3,
      '4': 1,
      '5': 4,
      '10': 'createdAtUnixMillis'
    },
    {'1': 'finalized', '3': 4, '4': 1, '5': 8, '10': 'finalized'},
    {
      '1': 'parts',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.pi.client.protocol.v0.ConversationPart',
      '10': 'parts'
    },
    {
      '1': 'tool_activities',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.pi.client.protocol.v0.ToolActivity',
      '10': 'toolActivities'
    },
    {
      '1': 'metrics',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.ConversationMetrics',
      '10': 'metrics'
    },
    {
      '1': 'user',
      '3': 20,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.UserConversationEntry',
      '9': 0,
      '10': 'user'
    },
    {
      '1': 'assistant',
      '3': 21,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.AssistantConversationEntry',
      '9': 0,
      '10': 'assistant'
    },
    {
      '1': 'tool_result',
      '3': 22,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.ToolResultConversationEntry',
      '9': 0,
      '10': 'toolResult'
    },
    {
      '1': 'bash',
      '3': 23,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.BashConversationEntry',
      '9': 0,
      '10': 'bash'
    },
    {
      '1': 'custom',
      '3': 24,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.CustomConversationEntry',
      '9': 0,
      '10': 'custom'
    },
    {
      '1': 'compaction',
      '3': 25,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.CompactionConversationEntry',
      '9': 0,
      '10': 'compaction'
    },
    {
      '1': 'branch_summary',
      '3': 26,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.BranchSummaryConversationEntry',
      '9': 0,
      '10': 'branchSummary'
    },
    {
      '1': 'marker',
      '3': 27,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.MarkerConversationEntry',
      '9': 0,
      '10': 'marker'
    },
    {
      '1': 'unknown',
      '3': 28,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.UnknownConversationEntry',
      '9': 0,
      '10': 'unknown'
    },
  ],
  '8': [
    {'1': 'kind'},
  ],
  '9': [
    {'1': 8, '2': 20},
  ],
};

/// Descriptor for `ConversationEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationEntryDescriptor = $convert.base64Decode(
    'ChFDb252ZXJzYXRpb25FbnRyeRJMCghpZGVudGl0eRgBIAEoCzIwLnBpLmNsaWVudC5wcm90b2'
    'NvbC52MC5Db252ZXJzYXRpb25FbnRyeUlkZW50aXR5UghpZGVudGl0eRIaCghyZXZpc2lvbhgC'
    'IAEoBFIIcmV2aXNpb24SMwoWY3JlYXRlZF9hdF91bml4X21pbGxpcxgDIAEoBFITY3JlYXRlZE'
    'F0VW5peE1pbGxpcxIcCglmaW5hbGl6ZWQYBCABKAhSCWZpbmFsaXplZBI9CgVwYXJ0cxgFIAMo'
    'CzInLnBpLmNsaWVudC5wcm90b2NvbC52MC5Db252ZXJzYXRpb25QYXJ0UgVwYXJ0cxJMCg90b2'
    '9sX2FjdGl2aXRpZXMYBiADKAsyIy5waS5jbGllbnQucHJvdG9jb2wudjAuVG9vbEFjdGl2aXR5'
    'Ug50b29sQWN0aXZpdGllcxJECgdtZXRyaWNzGAcgASgLMioucGkuY2xpZW50LnByb3RvY29sLn'
    'YwLkNvbnZlcnNhdGlvbk1ldHJpY3NSB21ldHJpY3MSQgoEdXNlchgUIAEoCzIsLnBpLmNsaWVu'
    'dC5wcm90b2NvbC52MC5Vc2VyQ29udmVyc2F0aW9uRW50cnlIAFIEdXNlchJRCglhc3Npc3Rhbn'
    'QYFSABKAsyMS5waS5jbGllbnQucHJvdG9jb2wudjAuQXNzaXN0YW50Q29udmVyc2F0aW9uRW50'
    'cnlIAFIJYXNzaXN0YW50ElUKC3Rvb2xfcmVzdWx0GBYgASgLMjIucGkuY2xpZW50LnByb3RvY2'
    '9sLnYwLlRvb2xSZXN1bHRDb252ZXJzYXRpb25FbnRyeUgAUgp0b29sUmVzdWx0EkIKBGJhc2gY'
    'FyABKAsyLC5waS5jbGllbnQucHJvdG9jb2wudjAuQmFzaENvbnZlcnNhdGlvbkVudHJ5SABSBG'
    'Jhc2gSSAoGY3VzdG9tGBggASgLMi4ucGkuY2xpZW50LnByb3RvY29sLnYwLkN1c3RvbUNvbnZl'
    'cnNhdGlvbkVudHJ5SABSBmN1c3RvbRJUCgpjb21wYWN0aW9uGBkgASgLMjIucGkuY2xpZW50Ln'
    'Byb3RvY29sLnYwLkNvbXBhY3Rpb25Db252ZXJzYXRpb25FbnRyeUgAUgpjb21wYWN0aW9uEl4K'
    'DmJyYW5jaF9zdW1tYXJ5GBogASgLMjUucGkuY2xpZW50LnByb3RvY29sLnYwLkJyYW5jaFN1bW'
    '1hcnlDb252ZXJzYXRpb25FbnRyeUgAUg1icmFuY2hTdW1tYXJ5EkgKBm1hcmtlchgbIAEoCzIu'
    'LnBpLmNsaWVudC5wcm90b2NvbC52MC5NYXJrZXJDb252ZXJzYXRpb25FbnRyeUgAUgZtYXJrZX'
    'ISSwoHdW5rbm93bhgcIAEoCzIvLnBpLmNsaWVudC5wcm90b2NvbC52MC5Vbmtub3duQ29udmVy'
    'c2F0aW9uRW50cnlIAFIHdW5rbm93bkIGCgRraW5kSgQICBAU');

@$core.Deprecated('Use userConversationEntryDescriptor instead')
const UserConversationEntry$json = {
  '1': 'UserConversationEntry',
};

/// Descriptor for `UserConversationEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userConversationEntryDescriptor =
    $convert.base64Decode('ChVVc2VyQ29udmVyc2F0aW9uRW50cnk=');

@$core.Deprecated('Use assistantConversationEntryDescriptor instead')
const AssistantConversationEntry$json = {
  '1': 'AssistantConversationEntry',
  '2': [
    {'1': 'provider', '3': 1, '4': 1, '5': 9, '10': 'provider'},
    {'1': 'model', '3': 2, '4': 1, '5': 9, '10': 'model'},
    {'1': 'stop_reason', '3': 3, '4': 1, '5': 9, '10': 'stopReason'},
    {
      '1': 'safe_error_message',
      '3': 4,
      '4': 1,
      '5': 9,
      '10': 'safeErrorMessage'
    },
  ],
};

/// Descriptor for `AssistantConversationEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List assistantConversationEntryDescriptor =
    $convert.base64Decode(
        'ChpBc3Npc3RhbnRDb252ZXJzYXRpb25FbnRyeRIaCghwcm92aWRlchgBIAEoCVIIcHJvdmlkZX'
        'ISFAoFbW9kZWwYAiABKAlSBW1vZGVsEh8KC3N0b3BfcmVhc29uGAMgASgJUgpzdG9wUmVhc29u'
        'EiwKEnNhZmVfZXJyb3JfbWVzc2FnZRgEIAEoCVIQc2FmZUVycm9yTWVzc2FnZQ==');

@$core.Deprecated('Use toolResultConversationEntryDescriptor instead')
const ToolResultConversationEntry$json = {
  '1': 'ToolResultConversationEntry',
  '2': [
    {'1': 'tool_call_id', '3': 1, '4': 1, '5': 9, '10': 'toolCallId'},
    {'1': 'tool_name', '3': 2, '4': 1, '5': 9, '10': 'toolName'},
    {'1': 'is_error', '3': 3, '4': 1, '5': 8, '10': 'isError'},
    {
      '1': 'safe_details',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.SafeValue',
      '10': 'safeDetails'
    },
  ],
};

/// Descriptor for `ToolResultConversationEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List toolResultConversationEntryDescriptor = $convert.base64Decode(
    'ChtUb29sUmVzdWx0Q29udmVyc2F0aW9uRW50cnkSIAoMdG9vbF9jYWxsX2lkGAEgASgJUgp0b2'
    '9sQ2FsbElkEhsKCXRvb2xfbmFtZRgCIAEoCVIIdG9vbE5hbWUSGQoIaXNfZXJyb3IYAyABKAhS'
    'B2lzRXJyb3ISQwoMc2FmZV9kZXRhaWxzGAQgASgLMiAucGkuY2xpZW50LnByb3RvY29sLnYwLl'
    'NhZmVWYWx1ZVILc2FmZURldGFpbHM=');

@$core.Deprecated('Use bashConversationEntryDescriptor instead')
const BashConversationEntry$json = {
  '1': 'BashConversationEntry',
  '2': [
    {'1': 'command', '3': 1, '4': 1, '5': 9, '10': 'command'},
    {
      '1': 'exit_code',
      '3': 2,
      '4': 1,
      '5': 5,
      '9': 0,
      '10': 'exitCode',
      '17': true
    },
    {'1': 'cancelled', '3': 3, '4': 1, '5': 8, '10': 'cancelled'},
    {'1': 'truncated', '3': 4, '4': 1, '5': 8, '10': 'truncated'},
    {
      '1': 'excluded_from_context',
      '3': 5,
      '4': 1,
      '5': 8,
      '10': 'excludedFromContext'
    },
  ],
  '8': [
    {'1': '_exit_code'},
  ],
};

/// Descriptor for `BashConversationEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List bashConversationEntryDescriptor = $convert.base64Decode(
    'ChVCYXNoQ29udmVyc2F0aW9uRW50cnkSGAoHY29tbWFuZBgBIAEoCVIHY29tbWFuZBIgCglleG'
    'l0X2NvZGUYAiABKAVIAFIIZXhpdENvZGWIAQESHAoJY2FuY2VsbGVkGAMgASgIUgljYW5jZWxs'
    'ZWQSHAoJdHJ1bmNhdGVkGAQgASgIUgl0cnVuY2F0ZWQSMgoVZXhjbHVkZWRfZnJvbV9jb250ZX'
    'h0GAUgASgIUhNleGNsdWRlZEZyb21Db250ZXh0QgwKCl9leGl0X2NvZGU=');

@$core.Deprecated('Use customConversationEntryDescriptor instead')
const CustomConversationEntry$json = {
  '1': 'CustomConversationEntry',
  '2': [
    {'1': 'custom_type', '3': 1, '4': 1, '5': 9, '10': 'customType'},
    {'1': 'display', '3': 2, '4': 1, '5': 8, '10': 'display'},
    {
      '1': 'safe_details',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.SafeValue',
      '10': 'safeDetails'
    },
  ],
};

/// Descriptor for `CustomConversationEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List customConversationEntryDescriptor = $convert.base64Decode(
    'ChdDdXN0b21Db252ZXJzYXRpb25FbnRyeRIfCgtjdXN0b21fdHlwZRgBIAEoCVIKY3VzdG9tVH'
    'lwZRIYCgdkaXNwbGF5GAIgASgIUgdkaXNwbGF5EkMKDHNhZmVfZGV0YWlscxgDIAEoCzIgLnBp'
    'LmNsaWVudC5wcm90b2NvbC52MC5TYWZlVmFsdWVSC3NhZmVEZXRhaWxz');

@$core.Deprecated('Use compactionConversationEntryDescriptor instead')
const CompactionConversationEntry$json = {
  '1': 'CompactionConversationEntry',
  '2': [
    {
      '1': 'first_kept_entry_id',
      '3': 1,
      '4': 1,
      '5': 9,
      '10': 'firstKeptEntryId'
    },
    {'1': 'tokens_before', '3': 2, '4': 1, '5': 4, '10': 'tokensBefore'},
    {'1': 'from_hook', '3': 3, '4': 1, '5': 8, '10': 'fromHook'},
    {
      '1': 'safe_details',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.SafeValue',
      '10': 'safeDetails'
    },
  ],
};

/// Descriptor for `CompactionConversationEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List compactionConversationEntryDescriptor = $convert.base64Decode(
    'ChtDb21wYWN0aW9uQ29udmVyc2F0aW9uRW50cnkSLQoTZmlyc3Rfa2VwdF9lbnRyeV9pZBgBIA'
    'EoCVIQZmlyc3RLZXB0RW50cnlJZBIjCg10b2tlbnNfYmVmb3JlGAIgASgEUgx0b2tlbnNCZWZv'
    'cmUSGwoJZnJvbV9ob29rGAMgASgIUghmcm9tSG9vaxJDCgxzYWZlX2RldGFpbHMYBCABKAsyIC'
    '5waS5jbGllbnQucHJvdG9jb2wudjAuU2FmZVZhbHVlUgtzYWZlRGV0YWlscw==');

@$core.Deprecated('Use branchSummaryConversationEntryDescriptor instead')
const BranchSummaryConversationEntry$json = {
  '1': 'BranchSummaryConversationEntry',
  '2': [
    {'1': 'from_entry_id', '3': 1, '4': 1, '5': 9, '10': 'fromEntryId'},
    {'1': 'from_hook', '3': 2, '4': 1, '5': 8, '10': 'fromHook'},
    {
      '1': 'safe_details',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.SafeValue',
      '10': 'safeDetails'
    },
  ],
};

/// Descriptor for `BranchSummaryConversationEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List branchSummaryConversationEntryDescriptor =
    $convert.base64Decode(
        'Ch5CcmFuY2hTdW1tYXJ5Q29udmVyc2F0aW9uRW50cnkSIgoNZnJvbV9lbnRyeV9pZBgBIAEoCV'
        'ILZnJvbUVudHJ5SWQSGwoJZnJvbV9ob29rGAIgASgIUghmcm9tSG9vaxJDCgxzYWZlX2RldGFp'
        'bHMYAyABKAsyIC5waS5jbGllbnQucHJvdG9jb2wudjAuU2FmZVZhbHVlUgtzYWZlRGV0YWlscw'
        '==');

@$core.Deprecated('Use markerConversationEntryDescriptor instead')
const MarkerConversationEntry$json = {
  '1': 'MarkerConversationEntry',
  '2': [
    {
      '1': 'marker_kind',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.pi.client.protocol.v0.MarkerKind',
      '10': 'markerKind'
    },
    {'1': 'target_entry_id', '3': 2, '4': 1, '5': 9, '10': 'targetEntryId'},
    {'1': 'label', '3': 3, '4': 1, '5': 9, '10': 'label'},
    {'1': 'provider', '3': 4, '4': 1, '5': 9, '10': 'provider'},
    {'1': 'model', '3': 5, '4': 1, '5': 9, '10': 'model'},
    {'1': 'thinking_level', '3': 6, '4': 1, '5': 9, '10': 'thinkingLevel'},
  ],
};

/// Descriptor for `MarkerConversationEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List markerConversationEntryDescriptor = $convert.base64Decode(
    'ChdNYXJrZXJDb252ZXJzYXRpb25FbnRyeRJCCgttYXJrZXJfa2luZBgBIAEoDjIhLnBpLmNsaW'
    'VudC5wcm90b2NvbC52MC5NYXJrZXJLaW5kUgptYXJrZXJLaW5kEiYKD3RhcmdldF9lbnRyeV9p'
    'ZBgCIAEoCVINdGFyZ2V0RW50cnlJZBIUCgVsYWJlbBgDIAEoCVIFbGFiZWwSGgoIcHJvdmlkZX'
    'IYBCABKAlSCHByb3ZpZGVyEhQKBW1vZGVsGAUgASgJUgVtb2RlbBIlCg50aGlua2luZ19sZXZl'
    'bBgGIAEoCVINdGhpbmtpbmdMZXZlbA==');

@$core.Deprecated('Use unknownConversationEntryDescriptor instead')
const UnknownConversationEntry$json = {
  '1': 'UnknownConversationEntry',
  '2': [
    {'1': 'source_type', '3': 1, '4': 1, '5': 9, '10': 'sourceType'},
  ],
};

/// Descriptor for `UnknownConversationEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unknownConversationEntryDescriptor =
    $convert.base64Decode(
        'ChhVbmtub3duQ29udmVyc2F0aW9uRW50cnkSHwoLc291cmNlX3R5cGUYASABKAlSCnNvdXJjZV'
        'R5cGU=');

@$core.Deprecated('Use conversationPartDescriptor instead')
const ConversationPart$json = {
  '1': 'ConversationPart',
  '2': [
    {'1': 'part_id', '3': 1, '4': 1, '5': 9, '10': 'partId'},
    {'1': 'revision', '3': 2, '4': 1, '5': 4, '10': 'revision'},
    {
      '1': 'text',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.BoundedTextPart',
      '9': 0,
      '10': 'text'
    },
    {
      '1': 'thinking',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.ThinkingPart',
      '9': 0,
      '10': 'thinking'
    },
    {
      '1': 'image',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.ImagePart',
      '9': 0,
      '10': 'image'
    },
    {
      '1': 'tool_call',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.ToolCallPart',
      '9': 0,
      '10': 'toolCall'
    },
    {
      '1': 'unsupported',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.UnsupportedPart',
      '9': 0,
      '10': 'unsupported'
    },
  ],
  '8': [
    {'1': 'kind'},
  ],
  '9': [
    {'1': 3, '2': 10},
  ],
};

/// Descriptor for `ConversationPart`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationPartDescriptor = $convert.base64Decode(
    'ChBDb252ZXJzYXRpb25QYXJ0EhcKB3BhcnRfaWQYASABKAlSBnBhcnRJZBIaCghyZXZpc2lvbh'
    'gCIAEoBFIIcmV2aXNpb24SPAoEdGV4dBgKIAEoCzImLnBpLmNsaWVudC5wcm90b2NvbC52MC5C'
    'b3VuZGVkVGV4dFBhcnRIAFIEdGV4dBJBCgh0aGlua2luZxgLIAEoCzIjLnBpLmNsaWVudC5wcm'
    '90b2NvbC52MC5UaGlua2luZ1BhcnRIAFIIdGhpbmtpbmcSOAoFaW1hZ2UYDCABKAsyIC5waS5j'
    'bGllbnQucHJvdG9jb2wudjAuSW1hZ2VQYXJ0SABSBWltYWdlEkIKCXRvb2xfY2FsbBgNIAEoCz'
    'IjLnBpLmNsaWVudC5wcm90b2NvbC52MC5Ub29sQ2FsbFBhcnRIAFIIdG9vbENhbGwSSgoLdW5z'
    'dXBwb3J0ZWQYDiABKAsyJi5waS5jbGllbnQucHJvdG9jb2wudjAuVW5zdXBwb3J0ZWRQYXJ0SA'
    'BSC3Vuc3VwcG9ydGVkQgYKBGtpbmRKBAgDEAo=');

@$core.Deprecated('Use boundedTextPartDescriptor instead')
const BoundedTextPart$json = {
  '1': 'BoundedTextPart',
  '2': [
    {'1': 'inline_text', '3': 1, '4': 1, '5': 9, '9': 0, '10': 'inlineText'},
    {
      '1': 'content_reference',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.MessageContentReference',
      '9': 0,
      '10': 'contentReference'
    },
  ],
  '8': [
    {'1': 'content'},
  ],
};

/// Descriptor for `BoundedTextPart`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List boundedTextPartDescriptor = $convert.base64Decode(
    'Cg9Cb3VuZGVkVGV4dFBhcnQSIQoLaW5saW5lX3RleHQYASABKAlIAFIKaW5saW5lVGV4dBJdCh'
    'Fjb250ZW50X3JlZmVyZW5jZRgCIAEoCzIuLnBpLmNsaWVudC5wcm90b2NvbC52MC5NZXNzYWdl'
    'Q29udGVudFJlZmVyZW5jZUgAUhBjb250ZW50UmVmZXJlbmNlQgkKB2NvbnRlbnQ=');

@$core.Deprecated('Use thinkingPartDescriptor instead')
const ThinkingPart$json = {
  '1': 'ThinkingPart',
  '2': [
    {
      '1': 'visibility',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.pi.client.protocol.v0.ThinkingVisibility',
      '10': 'visibility'
    },
    {'1': 'inline_text', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'inlineText'},
    {
      '1': 'content_reference',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.MessageContentReference',
      '9': 0,
      '10': 'contentReference'
    },
  ],
  '8': [
    {'1': 'content'},
  ],
};

/// Descriptor for `ThinkingPart`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List thinkingPartDescriptor = $convert.base64Decode(
    'CgxUaGlua2luZ1BhcnQSSQoKdmlzaWJpbGl0eRgBIAEoDjIpLnBpLmNsaWVudC5wcm90b2NvbC'
    '52MC5UaGlua2luZ1Zpc2liaWxpdHlSCnZpc2liaWxpdHkSIQoLaW5saW5lX3RleHQYAiABKAlI'
    'AFIKaW5saW5lVGV4dBJdChFjb250ZW50X3JlZmVyZW5jZRgDIAEoCzIuLnBpLmNsaWVudC5wcm'
    '90b2NvbC52MC5NZXNzYWdlQ29udGVudFJlZmVyZW5jZUgAUhBjb250ZW50UmVmZXJlbmNlQgkK'
    'B2NvbnRlbnQ=');

@$core.Deprecated('Use imagePartDescriptor instead')
const ImagePart$json = {
  '1': 'ImagePart',
  '2': [
    {
      '1': 'content_reference',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.MessageContentReference',
      '10': 'contentReference'
    },
  ],
};

/// Descriptor for `ImagePart`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List imagePartDescriptor = $convert.base64Decode(
    'CglJbWFnZVBhcnQSWwoRY29udGVudF9yZWZlcmVuY2UYASABKAsyLi5waS5jbGllbnQucHJvdG'
    '9jb2wudjAuTWVzc2FnZUNvbnRlbnRSZWZlcmVuY2VSEGNvbnRlbnRSZWZlcmVuY2U=');

@$core.Deprecated('Use toolCallPartDescriptor instead')
const ToolCallPart$json = {
  '1': 'ToolCallPart',
  '2': [
    {'1': 'tool_call_id', '3': 1, '4': 1, '5': 9, '10': 'toolCallId'},
    {'1': 'tool_name', '3': 2, '4': 1, '5': 9, '10': 'toolName'},
    {
      '1': 'safe_arguments',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.SafeValue',
      '10': 'safeArguments'
    },
  ],
};

/// Descriptor for `ToolCallPart`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List toolCallPartDescriptor = $convert.base64Decode(
    'CgxUb29sQ2FsbFBhcnQSIAoMdG9vbF9jYWxsX2lkGAEgASgJUgp0b29sQ2FsbElkEhsKCXRvb2'
    'xfbmFtZRgCIAEoCVIIdG9vbE5hbWUSRwoOc2FmZV9hcmd1bWVudHMYAyABKAsyIC5waS5jbGll'
    'bnQucHJvdG9jb2wudjAuU2FmZVZhbHVlUg1zYWZlQXJndW1lbnRz');

@$core.Deprecated('Use unsupportedPartDescriptor instead')
const UnsupportedPart$json = {
  '1': 'UnsupportedPart',
  '2': [
    {'1': 'source_type', '3': 1, '4': 1, '5': 9, '10': 'sourceType'},
  ],
};

/// Descriptor for `UnsupportedPart`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unsupportedPartDescriptor = $convert.base64Decode(
    'Cg9VbnN1cHBvcnRlZFBhcnQSHwoLc291cmNlX3R5cGUYASABKAlSCnNvdXJjZVR5cGU=');

@$core.Deprecated('Use messageContentReferenceDescriptor instead')
const MessageContentReference$json = {
  '1': 'MessageContentReference',
  '2': [
    {'1': 'content_id', '3': 1, '4': 1, '5': 9, '10': 'contentId'},
    {'1': 'mime_type', '3': 2, '4': 1, '5': 9, '10': 'mimeType'},
    {'1': 'display_name', '3': 3, '4': 1, '5': 9, '10': 'displayName'},
    {'1': 'total_bytes', '3': 4, '4': 1, '5': 4, '10': 'totalBytes'},
    {'1': 'sha256', '3': 5, '4': 1, '5': 12, '10': 'sha256'},
  ],
};

/// Descriptor for `MessageContentReference`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageContentReferenceDescriptor = $convert.base64Decode(
    'ChdNZXNzYWdlQ29udGVudFJlZmVyZW5jZRIdCgpjb250ZW50X2lkGAEgASgJUgljb250ZW50SW'
    'QSGwoJbWltZV90eXBlGAIgASgJUghtaW1lVHlwZRIhCgxkaXNwbGF5X25hbWUYAyABKAlSC2Rp'
    'c3BsYXlOYW1lEh8KC3RvdGFsX2J5dGVzGAQgASgEUgp0b3RhbEJ5dGVzEhYKBnNoYTI1NhgFIA'
    'EoDFIGc2hhMjU2');

@$core.Deprecated('Use messageContentBindingDescriptor instead')
const MessageContentBinding$json = {
  '1': 'MessageContentBinding',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
    {'1': 'entry_id', '3': 2, '4': 1, '5': 9, '10': 'entryId'},
    {'1': 'part_id', '3': 3, '4': 1, '5': 9, '10': 'partId'},
    {'1': 'entry_revision', '3': 4, '4': 1, '5': 4, '10': 'entryRevision'},
    {'1': 'part_revision', '3': 5, '4': 1, '5': 4, '10': 'partRevision'},
    {'1': 'content_id', '3': 6, '4': 1, '5': 9, '10': 'contentId'},
  ],
};

/// Descriptor for `MessageContentBinding`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageContentBindingDescriptor = $convert.base64Decode(
    'ChVNZXNzYWdlQ29udGVudEJpbmRpbmcSHQoKc2Vzc2lvbl9pZBgBIAEoCVIJc2Vzc2lvbklkEh'
    'kKCGVudHJ5X2lkGAIgASgJUgdlbnRyeUlkEhcKB3BhcnRfaWQYAyABKAlSBnBhcnRJZBIlCg5l'
    'bnRyeV9yZXZpc2lvbhgEIAEoBFINZW50cnlSZXZpc2lvbhIjCg1wYXJ0X3JldmlzaW9uGAUgAS'
    'gEUgxwYXJ0UmV2aXNpb24SHQoKY29udGVudF9pZBgGIAEoCVIJY29udGVudElk');

@$core.Deprecated('Use getMessageContentRequestDescriptor instead')
const GetMessageContentRequest$json = {
  '1': 'GetMessageContentRequest',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 4, '10': 'requestId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {
      '1': 'binding',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.MessageContentBinding',
      '10': 'binding'
    },
    {
      '1': 'expected_mime_type',
      '3': 4,
      '4': 1,
      '5': 9,
      '10': 'expectedMimeType'
    },
    {
      '1': 'expected_total_bytes',
      '3': 5,
      '4': 1,
      '5': 4,
      '10': 'expectedTotalBytes'
    },
    {'1': 'expected_sha256', '3': 6, '4': 1, '5': 12, '10': 'expectedSha256'},
  ],
};

/// Descriptor for `GetMessageContentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMessageContentRequestDescriptor = $convert.base64Decode(
    'ChhHZXRNZXNzYWdlQ29udGVudFJlcXVlc3QSHQoKcmVxdWVzdF9pZBgBIAEoBFIJcmVxdWVzdE'
    'lkEh0KCnByb2plY3RfaWQYAiABKAlSCXByb2plY3RJZBJGCgdiaW5kaW5nGAMgASgLMiwucGku'
    'Y2xpZW50LnByb3RvY29sLnYwLk1lc3NhZ2VDb250ZW50QmluZGluZ1IHYmluZGluZxIsChJleH'
    'BlY3RlZF9taW1lX3R5cGUYBCABKAlSEGV4cGVjdGVkTWltZVR5cGUSMAoUZXhwZWN0ZWRfdG90'
    'YWxfYnl0ZXMYBSABKARSEmV4cGVjdGVkVG90YWxCeXRlcxInCg9leHBlY3RlZF9zaGEyNTYYBi'
    'ABKAxSDmV4cGVjdGVkU2hhMjU2');

@$core.Deprecated('Use safeListDescriptor instead')
const SafeList$json = {
  '1': 'SafeList',
  '2': [
    {
      '1': 'values',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.pi.client.protocol.v0.SafeValue',
      '10': 'values'
    },
  ],
};

/// Descriptor for `SafeList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List safeListDescriptor = $convert.base64Decode(
    'CghTYWZlTGlzdBI4CgZ2YWx1ZXMYASADKAsyIC5waS5jbGllbnQucHJvdG9jb2wudjAuU2FmZV'
    'ZhbHVlUgZ2YWx1ZXM=');

@$core.Deprecated('Use safeObjectFieldDescriptor instead')
const SafeObjectField$json = {
  '1': 'SafeObjectField',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.SafeValue',
      '10': 'value'
    },
  ],
};

/// Descriptor for `SafeObjectField`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List safeObjectFieldDescriptor = $convert.base64Decode(
    'Cg9TYWZlT2JqZWN0RmllbGQSEAoDa2V5GAEgASgJUgNrZXkSNgoFdmFsdWUYAiABKAsyIC5waS'
    '5jbGllbnQucHJvdG9jb2wudjAuU2FmZVZhbHVlUgV2YWx1ZQ==');

@$core.Deprecated('Use safeObjectDescriptor instead')
const SafeObject$json = {
  '1': 'SafeObject',
  '2': [
    {
      '1': 'fields',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.pi.client.protocol.v0.SafeObjectField',
      '10': 'fields'
    },
  ],
};

/// Descriptor for `SafeObject`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List safeObjectDescriptor = $convert.base64Decode(
    'CgpTYWZlT2JqZWN0Ej4KBmZpZWxkcxgBIAMoCzImLnBpLmNsaWVudC5wcm90b2NvbC52MC5TYW'
    'ZlT2JqZWN0RmllbGRSBmZpZWxkcw==');

@$core.Deprecated('Use safeValueDescriptor instead')
const SafeValue$json = {
  '1': 'SafeValue',
  '2': [
    {
      '1': 'sentinel',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.pi.client.protocol.v0.SafeValueKind',
      '9': 0,
      '10': 'sentinel'
    },
    {'1': 'bool_value', '3': 2, '4': 1, '5': 8, '9': 0, '10': 'boolValue'},
    {'1': 'int_value', '3': 3, '4': 1, '5': 18, '9': 0, '10': 'intValue'},
    {'1': 'double_value', '3': 4, '4': 1, '5': 1, '9': 0, '10': 'doubleValue'},
    {'1': 'string_value', '3': 5, '4': 1, '5': 9, '9': 0, '10': 'stringValue'},
    {
      '1': 'list_value',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.SafeList',
      '9': 0,
      '10': 'listValue'
    },
    {
      '1': 'object_value',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.SafeObject',
      '9': 0,
      '10': 'objectValue'
    },
  ],
  '8': [
    {'1': 'value'},
  ],
};

/// Descriptor for `SafeValue`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List safeValueDescriptor = $convert.base64Decode(
    'CglTYWZlVmFsdWUSQgoIc2VudGluZWwYASABKA4yJC5waS5jbGllbnQucHJvdG9jb2wudjAuU2'
    'FmZVZhbHVlS2luZEgAUghzZW50aW5lbBIfCgpib29sX3ZhbHVlGAIgASgISABSCWJvb2xWYWx1'
    'ZRIdCglpbnRfdmFsdWUYAyABKBJIAFIIaW50VmFsdWUSIwoMZG91YmxlX3ZhbHVlGAQgASgBSA'
    'BSC2RvdWJsZVZhbHVlEiMKDHN0cmluZ192YWx1ZRgFIAEoCUgAUgtzdHJpbmdWYWx1ZRJACgps'
    'aXN0X3ZhbHVlGAYgASgLMh8ucGkuY2xpZW50LnByb3RvY29sLnYwLlNhZmVMaXN0SABSCWxpc3'
    'RWYWx1ZRJGCgxvYmplY3RfdmFsdWUYByABKAsyIS5waS5jbGllbnQucHJvdG9jb2wudjAuU2Fm'
    'ZU9iamVjdEgAUgtvYmplY3RWYWx1ZUIHCgV2YWx1ZQ==');

@$core.Deprecated('Use toolActivityDescriptor instead')
const ToolActivity$json = {
  '1': 'ToolActivity',
  '2': [
    {'1': 'activity_id', '3': 1, '4': 1, '5': 9, '10': 'activityId'},
    {'1': 'tool_call_id', '3': 2, '4': 1, '5': 9, '10': 'toolCallId'},
    {'1': 'tool_name', '3': 3, '4': 1, '5': 9, '10': 'toolName'},
    {'1': 'source_ordinal', '3': 4, '4': 1, '5': 13, '10': 'sourceOrdinal'},
    {'1': 'revision', '3': 5, '4': 1, '5': 4, '10': 'revision'},
    {
      '1': 'status',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.pi.client.protocol.v0.ToolActivityStatus',
      '10': 'status'
    },
    {
      '1': 'progress_basis_points',
      '3': 7,
      '4': 1,
      '5': 13,
      '9': 0,
      '10': 'progressBasisPoints',
      '17': true
    },
    {
      '1': 'safe_details',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.SafeValue',
      '10': 'safeDetails'
    },
  ],
  '8': [
    {'1': '_progress_basis_points'},
  ],
};

/// Descriptor for `ToolActivity`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List toolActivityDescriptor = $convert.base64Decode(
    'CgxUb29sQWN0aXZpdHkSHwoLYWN0aXZpdHlfaWQYASABKAlSCmFjdGl2aXR5SWQSIAoMdG9vbF'
    '9jYWxsX2lkGAIgASgJUgp0b29sQ2FsbElkEhsKCXRvb2xfbmFtZRgDIAEoCVIIdG9vbE5hbWUS'
    'JQoOc291cmNlX29yZGluYWwYBCABKA1SDXNvdXJjZU9yZGluYWwSGgoIcmV2aXNpb24YBSABKA'
    'RSCHJldmlzaW9uEkEKBnN0YXR1cxgGIAEoDjIpLnBpLmNsaWVudC5wcm90b2NvbC52MC5Ub29s'
    'QWN0aXZpdHlTdGF0dXNSBnN0YXR1cxI3ChVwcm9ncmVzc19iYXNpc19wb2ludHMYByABKA1IAF'
    'ITcHJvZ3Jlc3NCYXNpc1BvaW50c4gBARJDCgxzYWZlX2RldGFpbHMYCCABKAsyIC5waS5jbGll'
    'bnQucHJvdG9jb2wudjAuU2FmZVZhbHVlUgtzYWZlRGV0YWlsc0IYChZfcHJvZ3Jlc3NfYmFzaX'
    'NfcG9pbnRz');

@$core.Deprecated('Use usageMetricsDescriptor instead')
const UsageMetrics$json = {
  '1': 'UsageMetrics',
  '2': [
    {'1': 'input_tokens', '3': 1, '4': 1, '5': 4, '10': 'inputTokens'},
    {'1': 'output_tokens', '3': 2, '4': 1, '5': 4, '10': 'outputTokens'},
    {'1': 'cache_read_tokens', '3': 3, '4': 1, '5': 4, '10': 'cacheReadTokens'},
    {
      '1': 'cache_write_tokens',
      '3': 4,
      '4': 1,
      '5': 4,
      '10': 'cacheWriteTokens'
    },
    {'1': 'total_tokens', '3': 5, '4': 1, '5': 4, '10': 'totalTokens'},
  ],
};

/// Descriptor for `UsageMetrics`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List usageMetricsDescriptor = $convert.base64Decode(
    'CgxVc2FnZU1ldHJpY3MSIQoMaW5wdXRfdG9rZW5zGAEgASgEUgtpbnB1dFRva2VucxIjCg1vdX'
    'RwdXRfdG9rZW5zGAIgASgEUgxvdXRwdXRUb2tlbnMSKgoRY2FjaGVfcmVhZF90b2tlbnMYAyAB'
    'KARSD2NhY2hlUmVhZFRva2VucxIsChJjYWNoZV93cml0ZV90b2tlbnMYBCABKARSEGNhY2hlV3'
    'JpdGVUb2tlbnMSIQoMdG90YWxfdG9rZW5zGAUgASgEUgt0b3RhbFRva2Vucw==');

@$core.Deprecated('Use moneyAmountDescriptor instead')
const MoneyAmount$json = {
  '1': 'MoneyAmount',
  '2': [
    {'1': 'currency_code', '3': 1, '4': 1, '5': 9, '10': 'currencyCode'},
    {'1': 'decimal_amount', '3': 2, '4': 1, '5': 9, '10': 'decimalAmount'},
  ],
};

/// Descriptor for `MoneyAmount`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List moneyAmountDescriptor = $convert.base64Decode(
    'CgtNb25leUFtb3VudBIjCg1jdXJyZW5jeV9jb2RlGAEgASgJUgxjdXJyZW5jeUNvZGUSJQoOZG'
    'VjaW1hbF9hbW91bnQYAiABKAlSDWRlY2ltYWxBbW91bnQ=');

@$core.Deprecated('Use contextMetricsDescriptor instead')
const ContextMetrics$json = {
  '1': 'ContextMetrics',
  '2': [
    {'1': 'tokens', '3': 1, '4': 1, '5': 4, '9': 0, '10': 'tokens', '17': true},
    {'1': 'context_window', '3': 2, '4': 1, '5': 4, '10': 'contextWindow'},
    {
      '1': 'percent_decimal',
      '3': 3,
      '4': 1,
      '5': 9,
      '9': 1,
      '10': 'percentDecimal',
      '17': true
    },
  ],
  '8': [
    {'1': '_tokens'},
    {'1': '_percent_decimal'},
  ],
};

/// Descriptor for `ContextMetrics`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List contextMetricsDescriptor = $convert.base64Decode(
    'Cg5Db250ZXh0TWV0cmljcxIbCgZ0b2tlbnMYASABKARIAFIGdG9rZW5ziAEBEiUKDmNvbnRleH'
    'Rfd2luZG93GAIgASgEUg1jb250ZXh0V2luZG93EiwKD3BlcmNlbnRfZGVjaW1hbBgDIAEoCUgB'
    'Ug5wZXJjZW50RGVjaW1hbIgBAUIJCgdfdG9rZW5zQhIKEF9wZXJjZW50X2RlY2ltYWw=');

@$core.Deprecated('Use conversationMetricsDescriptor instead')
const ConversationMetrics$json = {
  '1': 'ConversationMetrics',
  '2': [
    {
      '1': 'usage',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.UsageMetrics',
      '10': 'usage'
    },
    {
      '1': 'cost',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.MoneyAmount',
      '10': 'cost'
    },
    {
      '1': 'context',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.ContextMetrics',
      '10': 'context'
    },
  ],
};

/// Descriptor for `ConversationMetrics`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationMetricsDescriptor = $convert.base64Decode(
    'ChNDb252ZXJzYXRpb25NZXRyaWNzEjkKBXVzYWdlGAEgASgLMiMucGkuY2xpZW50LnByb3RvY2'
    '9sLnYwLlVzYWdlTWV0cmljc1IFdXNhZ2USNgoEY29zdBgCIAEoCzIiLnBpLmNsaWVudC5wcm90'
    'b2NvbC52MC5Nb25leUFtb3VudFIEY29zdBI/Cgdjb250ZXh0GAMgASgLMiUucGkuY2xpZW50Ln'
    'Byb3RvY29sLnYwLkNvbnRleHRNZXRyaWNzUgdjb250ZXh0');

@$core.Deprecated('Use getSessionStatsRequestDescriptor instead')
const GetSessionStatsRequest$json = {
  '1': 'GetSessionStatsRequest',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 4, '10': 'requestId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'session_id', '3': 3, '4': 1, '5': 9, '10': 'sessionId'},
  ],
};

/// Descriptor for `GetSessionStatsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSessionStatsRequestDescriptor = $convert.base64Decode(
    'ChZHZXRTZXNzaW9uU3RhdHNSZXF1ZXN0Eh0KCnJlcXVlc3RfaWQYASABKARSCXJlcXVlc3RJZB'
    'IdCgpwcm9qZWN0X2lkGAIgASgJUglwcm9qZWN0SWQSHQoKc2Vzc2lvbl9pZBgDIAEoCVIJc2Vz'
    'c2lvbklk');

@$core.Deprecated('Use sessionSafeProjectionSnapshotDescriptor instead')
const SessionSafeProjectionSnapshot$json = {
  '1': 'SessionSafeProjectionSnapshot',
  '2': [
    {'1': 'session_file_name', '3': 1, '4': 1, '5': 9, '10': 'sessionFileName'},
    {'1': 'session_id', '3': 2, '4': 1, '5': 9, '10': 'sessionId'},
    {'1': 'project_id', '3': 3, '4': 1, '5': 9, '10': 'projectId'},
    {
      '1': 'canonical_project_directory',
      '3': 4,
      '4': 1,
      '5': 9,
      '10': 'canonicalProjectDirectory'
    },
    {'1': 'worktree_id', '3': 5, '4': 1, '5': 9, '10': 'worktreeId'},
    {'1': 'main_project_id', '3': 6, '4': 1, '5': 9, '10': 'mainProjectId'},
    {'1': 'branch', '3': 7, '4': 1, '5': 9, '10': 'branch'},
    {
      '1': 'is_linked_worktree',
      '3': 8,
      '4': 1,
      '5': 8,
      '10': 'isLinkedWorktree'
    },
    {'1': 'is_detached_head', '3': 9, '4': 1, '5': 8, '10': 'isDetachedHead'},
  ],
};

/// Descriptor for `SessionSafeProjectionSnapshot`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sessionSafeProjectionSnapshotDescriptor = $convert.base64Decode(
    'Ch1TZXNzaW9uU2FmZVByb2plY3Rpb25TbmFwc2hvdBIqChFzZXNzaW9uX2ZpbGVfbmFtZRgBIA'
    'EoCVIPc2Vzc2lvbkZpbGVOYW1lEh0KCnNlc3Npb25faWQYAiABKAlSCXNlc3Npb25JZBIdCgpw'
    'cm9qZWN0X2lkGAMgASgJUglwcm9qZWN0SWQSPgobY2Fub25pY2FsX3Byb2plY3RfZGlyZWN0b3'
    'J5GAQgASgJUhljYW5vbmljYWxQcm9qZWN0RGlyZWN0b3J5Eh8KC3dvcmt0cmVlX2lkGAUgASgJ'
    'Ugp3b3JrdHJlZUlkEiYKD21haW5fcHJvamVjdF9pZBgGIAEoCVINbWFpblByb2plY3RJZBIWCg'
    'ZicmFuY2gYByABKAlSBmJyYW5jaBIsChJpc19saW5rZWRfd29ya3RyZWUYCCABKAhSEGlzTGlu'
    'a2VkV29ya3RyZWUSKAoQaXNfZGV0YWNoZWRfaGVhZBgJIAEoCFIOaXNEZXRhY2hlZEhlYWQ=');

@$core.Deprecated('Use sessionStatsSnapshotDescriptor instead')
const SessionStatsSnapshot$json = {
  '1': 'SessionStatsSnapshot',
  '2': [
    {
      '1': 'projection',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.SessionSafeProjectionSnapshot',
      '10': 'projection'
    },
    {'1': 'user_messages', '3': 2, '4': 1, '5': 4, '10': 'userMessages'},
    {
      '1': 'assistant_messages',
      '3': 3,
      '4': 1,
      '5': 4,
      '10': 'assistantMessages'
    },
    {'1': 'tool_calls', '3': 4, '4': 1, '5': 4, '10': 'toolCalls'},
    {'1': 'tool_results', '3': 5, '4': 1, '5': 4, '10': 'toolResults'},
    {'1': 'total_messages', '3': 6, '4': 1, '5': 4, '10': 'totalMessages'},
    {'1': 'input_tokens', '3': 7, '4': 1, '5': 4, '10': 'inputTokens'},
    {'1': 'output_tokens', '3': 8, '4': 1, '5': 4, '10': 'outputTokens'},
    {'1': 'cache_read_tokens', '3': 9, '4': 1, '5': 4, '10': 'cacheReadTokens'},
    {
      '1': 'cache_write_tokens',
      '3': 10,
      '4': 1,
      '5': 4,
      '10': 'cacheWriteTokens'
    },
    {'1': 'total_tokens', '3': 11, '4': 1, '5': 4, '10': 'totalTokens'},
    {'1': 'cost', '3': 12, '4': 1, '5': 1, '10': 'cost'},
    {
      '1': 'has_context_usage',
      '3': 13,
      '4': 1,
      '5': 8,
      '10': 'hasContextUsage'
    },
    {'1': 'context_tokens', '3': 14, '4': 1, '5': 4, '10': 'contextTokens'},
    {'1': 'context_window', '3': 15, '4': 1, '5': 4, '10': 'contextWindow'},
    {'1': 'context_percent', '3': 16, '4': 1, '5': 1, '10': 'contextPercent'},
    {
      '1': 'active_time_millis',
      '3': 17,
      '4': 1,
      '5': 4,
      '10': 'activeTimeMillis'
    },
    {
      '1': 'context_tokens_known',
      '3': 18,
      '4': 1,
      '5': 8,
      '10': 'contextTokensKnown'
    },
  ],
};

/// Descriptor for `SessionStatsSnapshot`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sessionStatsSnapshotDescriptor = $convert.base64Decode(
    'ChRTZXNzaW9uU3RhdHNTbmFwc2hvdBJUCgpwcm9qZWN0aW9uGAEgASgLMjQucGkuY2xpZW50Ln'
    'Byb3RvY29sLnYwLlNlc3Npb25TYWZlUHJvamVjdGlvblNuYXBzaG90Ugpwcm9qZWN0aW9uEiMK'
    'DXVzZXJfbWVzc2FnZXMYAiABKARSDHVzZXJNZXNzYWdlcxItChJhc3Npc3RhbnRfbWVzc2FnZX'
    'MYAyABKARSEWFzc2lzdGFudE1lc3NhZ2VzEh0KCnRvb2xfY2FsbHMYBCABKARSCXRvb2xDYWxs'
    'cxIhCgx0b29sX3Jlc3VsdHMYBSABKARSC3Rvb2xSZXN1bHRzEiUKDnRvdGFsX21lc3NhZ2VzGA'
    'YgASgEUg10b3RhbE1lc3NhZ2VzEiEKDGlucHV0X3Rva2VucxgHIAEoBFILaW5wdXRUb2tlbnMS'
    'IwoNb3V0cHV0X3Rva2VucxgIIAEoBFIMb3V0cHV0VG9rZW5zEioKEWNhY2hlX3JlYWRfdG9rZW'
    '5zGAkgASgEUg9jYWNoZVJlYWRUb2tlbnMSLAoSY2FjaGVfd3JpdGVfdG9rZW5zGAogASgEUhBj'
    'YWNoZVdyaXRlVG9rZW5zEiEKDHRvdGFsX3Rva2VucxgLIAEoBFILdG90YWxUb2tlbnMSEgoEY2'
    '9zdBgMIAEoAVIEY29zdBIqChFoYXNfY29udGV4dF91c2FnZRgNIAEoCFIPaGFzQ29udGV4dFVz'
    'YWdlEiUKDmNvbnRleHRfdG9rZW5zGA4gASgEUg1jb250ZXh0VG9rZW5zEiUKDmNvbnRleHRfd2'
    'luZG93GA8gASgEUg1jb250ZXh0V2luZG93EicKD2NvbnRleHRfcGVyY2VudBgQIAEoAVIOY29u'
    'dGV4dFBlcmNlbnQSLAoSYWN0aXZlX3RpbWVfbWlsbGlzGBEgASgEUhBhY3RpdmVUaW1lTWlsbG'
    'lzEjAKFGNvbnRleHRfdG9rZW5zX2tub3duGBIgASgIUhJjb250ZXh0VG9rZW5zS25vd24=');

@$core.Deprecated('Use getSessionStatsResponseDescriptor instead')
const GetSessionStatsResponse$json = {
  '1': 'GetSessionStatsResponse',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 4, '10': 'requestId'},
    {
      '1': 'stats',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.SessionStatsSnapshot',
      '10': 'stats'
    },
  ],
};

/// Descriptor for `GetSessionStatsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSessionStatsResponseDescriptor = $convert.base64Decode(
    'ChdHZXRTZXNzaW9uU3RhdHNSZXNwb25zZRIdCgpyZXF1ZXN0X2lkGAEgASgEUglyZXF1ZXN0SW'
    'QSQQoFc3RhdHMYAiABKAsyKy5waS5jbGllbnQucHJvdG9jb2wudjAuU2Vzc2lvblN0YXRzU25h'
    'cHNob3RSBXN0YXRz');

@$core.Deprecated('Use exportSessionRequestDescriptor instead')
const ExportSessionRequest$json = {
  '1': 'ExportSessionRequest',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 4, '10': 'requestId'},
    {'1': 'project_id', '3': 2, '4': 1, '5': 9, '10': 'projectId'},
    {'1': 'session_id', '3': 3, '4': 1, '5': 9, '10': 'sessionId'},
    {
      '1': 'format',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.pi.client.protocol.v0.SessionExportFormat',
      '10': 'format'
    },
    {
      '1': 'expected_active_branch_revision',
      '3': 5,
      '4': 1,
      '5': 9,
      '10': 'expectedActiveBranchRevision'
    },
    {
      '1': 'expected_tree_revision',
      '3': 6,
      '4': 1,
      '5': 9,
      '10': 'expectedTreeRevision'
    },
  ],
};

/// Descriptor for `ExportSessionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exportSessionRequestDescriptor = $convert.base64Decode(
    'ChRFeHBvcnRTZXNzaW9uUmVxdWVzdBIdCgpyZXF1ZXN0X2lkGAEgASgEUglyZXF1ZXN0SWQSHQ'
    'oKcHJvamVjdF9pZBgCIAEoCVIJcHJvamVjdElkEh0KCnNlc3Npb25faWQYAyABKAlSCXNlc3Np'
    'b25JZBJCCgZmb3JtYXQYBCABKA4yKi5waS5jbGllbnQucHJvdG9jb2wudjAuU2Vzc2lvbkV4cG'
    '9ydEZvcm1hdFIGZm9ybWF0EkUKH2V4cGVjdGVkX2FjdGl2ZV9icmFuY2hfcmV2aXNpb24YBSAB'
    'KAlSHGV4cGVjdGVkQWN0aXZlQnJhbmNoUmV2aXNpb24SNAoWZXhwZWN0ZWRfdHJlZV9yZXZpc2'
    'lvbhgGIAEoCVIUZXhwZWN0ZWRUcmVlUmV2aXNpb24=');

@$core.Deprecated('Use sessionEventStreamEnvelopeDescriptor instead')
const SessionEventStreamEnvelope$json = {
  '1': 'SessionEventStreamEnvelope',
  '2': [
    {'1': 'stream_id', '3': 1, '4': 1, '5': 9, '10': 'streamId'},
    {'1': 'session_id', '3': 2, '4': 1, '5': 9, '10': 'sessionId'},
    {'1': 'event_sequence', '3': 3, '4': 1, '5': 4, '10': 'eventSequence'},
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
    {
      '1': 'entry_upsert',
      '3': 20,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.ConversationEntryUpsertEvent',
      '9': 0,
      '10': 'entryUpsert'
    },
    {
      '1': 'part_delta',
      '3': 21,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.ConversationPartDeltaEvent',
      '9': 0,
      '10': 'partDelta'
    },
    {
      '1': 'entry_finalized',
      '3': 22,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.ConversationEntryFinalizedEvent',
      '9': 0,
      '10': 'entryFinalized'
    },
    {
      '1': 'tool_activity',
      '3': 23,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.ConversationToolActivityEvent',
      '9': 0,
      '10': 'toolActivity'
    },
    {
      '1': 'metrics',
      '3': 24,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.ConversationMetricsEvent',
      '9': 0,
      '10': 'metrics'
    },
  ],
  '8': [
    {'1': 'event'},
  ],
  '9': [
    {'1': 4, '2': 12},
    {'1': 15, '2': 20},
  ],
};

/// Descriptor for `SessionEventStreamEnvelope`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sessionEventStreamEnvelopeDescriptor = $convert.base64Decode(
    'ChpTZXNzaW9uRXZlbnRTdHJlYW1FbnZlbG9wZRIbCglzdHJlYW1faWQYASABKAlSCHN0cmVhbU'
    'lkEh0KCnNlc3Npb25faWQYAiABKAlSCXNlc3Npb25JZBIlCg5ldmVudF9zZXF1ZW5jZRgDIAEo'
    'BFINZXZlbnRTZXF1ZW5jZRJcCg9ydW5uaW5nX2NoYW5nZWQYDCABKAsyMS5waS5jbGllbnQucH'
    'JvdG9jb2wudjAuU2Vzc2lvblJ1bm5pbmdDaGFuZ2VkRXZlbnRIAFIOcnVubmluZ0NoYW5nZWQS'
    'WwoRY29tbWFuZF9jb21wbGV0ZWQYDSABKAsyLC5waS5jbGllbnQucHJvdG9jb2wudjAuQ29tbW'
    'FuZENvbXBsZXRlZEV2ZW50SABSEGNvbW1hbmRDb21wbGV0ZWQSTwoNc3RyZWFtX2Nsb3NlZBgO'
    'IAEoCzIoLnBpLmNsaWVudC5wcm90b2NvbC52MC5TdHJlYW1DbG9zZWRFdmVudEgAUgxzdHJlYW'
    '1DbG9zZWQSWAoMZW50cnlfdXBzZXJ0GBQgASgLMjMucGkuY2xpZW50LnByb3RvY29sLnYwLkNv'
    'bnZlcnNhdGlvbkVudHJ5VXBzZXJ0RXZlbnRIAFILZW50cnlVcHNlcnQSUgoKcGFydF9kZWx0YR'
    'gVIAEoCzIxLnBpLmNsaWVudC5wcm90b2NvbC52MC5Db252ZXJzYXRpb25QYXJ0RGVsdGFFdmVu'
    'dEgAUglwYXJ0RGVsdGESYQoPZW50cnlfZmluYWxpemVkGBYgASgLMjYucGkuY2xpZW50LnByb3'
    'RvY29sLnYwLkNvbnZlcnNhdGlvbkVudHJ5RmluYWxpemVkRXZlbnRIAFIOZW50cnlGaW5hbGl6'
    'ZWQSWwoNdG9vbF9hY3Rpdml0eRgXIAEoCzI0LnBpLmNsaWVudC5wcm90b2NvbC52MC5Db252ZX'
    'JzYXRpb25Ub29sQWN0aXZpdHlFdmVudEgAUgx0b29sQWN0aXZpdHkSSwoHbWV0cmljcxgYIAEo'
    'CzIvLnBpLmNsaWVudC5wcm90b2NvbC52MC5Db252ZXJzYXRpb25NZXRyaWNzRXZlbnRIAFIHbW'
    'V0cmljc0IHCgVldmVudEoECAQQDEoECA8QFA==');

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
  '7': {'3': true},
};

/// Descriptor for `MessageAddedEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageAddedEventDescriptor = $convert.base64Decode(
    'ChFNZXNzYWdlQWRkZWRFdmVudBJACgdtZXNzYWdlGAEgASgLMiYucGkuY2xpZW50LnByb3RvY2'
    '9sLnYwLk1lc3NhZ2VTbmFwc2hvdFIHbWVzc2FnZToCGAE=');

@$core.Deprecated('Use messageDeltaEventDescriptor instead')
const MessageDeltaEvent$json = {
  '1': 'MessageDeltaEvent',
  '2': [
    {'1': 'message_id', '3': 1, '4': 1, '5': 9, '10': 'messageId'},
    {'1': 'delta', '3': 2, '4': 1, '5': 9, '10': 'delta'},
  ],
  '7': {'3': true},
};

/// Descriptor for `MessageDeltaEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageDeltaEventDescriptor = $convert.base64Decode(
    'ChFNZXNzYWdlRGVsdGFFdmVudBIdCgptZXNzYWdlX2lkGAEgASgJUgltZXNzYWdlSWQSFAoFZG'
    'VsdGEYAiABKAlSBWRlbHRhOgIYAQ==');

@$core.Deprecated('Use conversationEntryUpsertEventDescriptor instead')
const ConversationEntryUpsertEvent$json = {
  '1': 'ConversationEntryUpsertEvent',
  '2': [
    {
      '1': 'entry',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.ConversationEntry',
      '10': 'entry'
    },
    {
      '1': 'expected_previous_revision',
      '3': 2,
      '4': 1,
      '5': 4,
      '9': 0,
      '10': 'expectedPreviousRevision',
      '17': true
    },
  ],
  '8': [
    {'1': '_expected_previous_revision'},
  ],
};

/// Descriptor for `ConversationEntryUpsertEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationEntryUpsertEventDescriptor = $convert.base64Decode(
    'ChxDb252ZXJzYXRpb25FbnRyeVVwc2VydEV2ZW50Ej4KBWVudHJ5GAEgASgLMigucGkuY2xpZW'
    '50LnByb3RvY29sLnYwLkNvbnZlcnNhdGlvbkVudHJ5UgVlbnRyeRJBChpleHBlY3RlZF9wcmV2'
    'aW91c19yZXZpc2lvbhgCIAEoBEgAUhhleHBlY3RlZFByZXZpb3VzUmV2aXNpb26IAQFCHQobX2'
    'V4cGVjdGVkX3ByZXZpb3VzX3JldmlzaW9u');

@$core.Deprecated('Use conversationPartDeltaEventDescriptor instead')
const ConversationPartDeltaEvent$json = {
  '1': 'ConversationPartDeltaEvent',
  '2': [
    {'1': 'entry_id', '3': 1, '4': 1, '5': 9, '10': 'entryId'},
    {
      '1': 'expected_entry_revision',
      '3': 2,
      '4': 1,
      '5': 4,
      '10': 'expectedEntryRevision'
    },
    {
      '1': 'resulting_entry_revision',
      '3': 3,
      '4': 1,
      '5': 4,
      '10': 'resultingEntryRevision'
    },
    {'1': 'part_id', '3': 4, '4': 1, '5': 9, '10': 'partId'},
    {
      '1': 'expected_part_revision',
      '3': 5,
      '4': 1,
      '5': 4,
      '10': 'expectedPartRevision'
    },
    {
      '1': 'resulting_part_revision',
      '3': 6,
      '4': 1,
      '5': 4,
      '10': 'resultingPartRevision'
    },
    {'1': 'text_delta', '3': 7, '4': 1, '5': 9, '10': 'textDelta'},
  ],
};

/// Descriptor for `ConversationPartDeltaEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationPartDeltaEventDescriptor = $convert.base64Decode(
    'ChpDb252ZXJzYXRpb25QYXJ0RGVsdGFFdmVudBIZCghlbnRyeV9pZBgBIAEoCVIHZW50cnlJZB'
    'I2ChdleHBlY3RlZF9lbnRyeV9yZXZpc2lvbhgCIAEoBFIVZXhwZWN0ZWRFbnRyeVJldmlzaW9u'
    'EjgKGHJlc3VsdGluZ19lbnRyeV9yZXZpc2lvbhgDIAEoBFIWcmVzdWx0aW5nRW50cnlSZXZpc2'
    'lvbhIXCgdwYXJ0X2lkGAQgASgJUgZwYXJ0SWQSNAoWZXhwZWN0ZWRfcGFydF9yZXZpc2lvbhgF'
    'IAEoBFIUZXhwZWN0ZWRQYXJ0UmV2aXNpb24SNgoXcmVzdWx0aW5nX3BhcnRfcmV2aXNpb24YBi'
    'ABKARSFXJlc3VsdGluZ1BhcnRSZXZpc2lvbhIdCgp0ZXh0X2RlbHRhGAcgASgJUgl0ZXh0RGVs'
    'dGE=');

@$core.Deprecated('Use conversationEntryFinalizedEventDescriptor instead')
const ConversationEntryFinalizedEvent$json = {
  '1': 'ConversationEntryFinalizedEvent',
  '2': [
    {
      '1': 'entry',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.ConversationEntry',
      '10': 'entry'
    },
    {
      '1': 'expected_previous_revision',
      '3': 2,
      '4': 1,
      '5': 4,
      '10': 'expectedPreviousRevision'
    },
  ],
};

/// Descriptor for `ConversationEntryFinalizedEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationEntryFinalizedEventDescriptor =
    $convert.base64Decode(
        'Ch9Db252ZXJzYXRpb25FbnRyeUZpbmFsaXplZEV2ZW50Ej4KBWVudHJ5GAEgASgLMigucGkuY2'
        'xpZW50LnByb3RvY29sLnYwLkNvbnZlcnNhdGlvbkVudHJ5UgVlbnRyeRI8ChpleHBlY3RlZF9w'
        'cmV2aW91c19yZXZpc2lvbhgCIAEoBFIYZXhwZWN0ZWRQcmV2aW91c1JldmlzaW9u');

@$core.Deprecated('Use conversationToolActivityEventDescriptor instead')
const ConversationToolActivityEvent$json = {
  '1': 'ConversationToolActivityEvent',
  '2': [
    {'1': 'entry_id', '3': 1, '4': 1, '5': 9, '10': 'entryId'},
    {
      '1': 'expected_entry_revision',
      '3': 2,
      '4': 1,
      '5': 4,
      '10': 'expectedEntryRevision'
    },
    {
      '1': 'resulting_entry_revision',
      '3': 3,
      '4': 1,
      '5': 4,
      '10': 'resultingEntryRevision'
    },
    {
      '1': 'activity',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.ToolActivity',
      '10': 'activity'
    },
  ],
};

/// Descriptor for `ConversationToolActivityEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationToolActivityEventDescriptor = $convert.base64Decode(
    'Ch1Db252ZXJzYXRpb25Ub29sQWN0aXZpdHlFdmVudBIZCghlbnRyeV9pZBgBIAEoCVIHZW50cn'
    'lJZBI2ChdleHBlY3RlZF9lbnRyeV9yZXZpc2lvbhgCIAEoBFIVZXhwZWN0ZWRFbnRyeVJldmlz'
    'aW9uEjgKGHJlc3VsdGluZ19lbnRyeV9yZXZpc2lvbhgDIAEoBFIWcmVzdWx0aW5nRW50cnlSZX'
    'Zpc2lvbhI/CghhY3Rpdml0eRgEIAEoCzIjLnBpLmNsaWVudC5wcm90b2NvbC52MC5Ub29sQWN0'
    'aXZpdHlSCGFjdGl2aXR5');

@$core.Deprecated('Use conversationMetricsEventDescriptor instead')
const ConversationMetricsEvent$json = {
  '1': 'ConversationMetricsEvent',
  '2': [
    {'1': 'entry_id', '3': 1, '4': 1, '5': 9, '10': 'entryId'},
    {
      '1': 'expected_entry_revision',
      '3': 2,
      '4': 1,
      '5': 4,
      '10': 'expectedEntryRevision'
    },
    {
      '1': 'resulting_entry_revision',
      '3': 3,
      '4': 1,
      '5': 4,
      '10': 'resultingEntryRevision'
    },
    {
      '1': 'metrics',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.ConversationMetrics',
      '10': 'metrics'
    },
  ],
};

/// Descriptor for `ConversationMetricsEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationMetricsEventDescriptor = $convert.base64Decode(
    'ChhDb252ZXJzYXRpb25NZXRyaWNzRXZlbnQSGQoIZW50cnlfaWQYASABKAlSB2VudHJ5SWQSNg'
    'oXZXhwZWN0ZWRfZW50cnlfcmV2aXNpb24YAiABKARSFWV4cGVjdGVkRW50cnlSZXZpc2lvbhI4'
    'ChhyZXN1bHRpbmdfZW50cnlfcmV2aXNpb24YAyABKARSFnJlc3VsdGluZ0VudHJ5UmV2aXNpb2'
    '4SRAoHbWV0cmljcxgEIAEoCzIqLnBpLmNsaWVudC5wcm90b2NvbC52MC5Db252ZXJzYXRpb25N'
    'ZXRyaWNzUgdtZXRyaWNz');

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
    {'1': 'request_id', '3': 9, '4': 1, '5': 4, '10': 'requestId'},
    {
      '1': 'message_content_binding',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.MessageContentBinding',
      '10': 'messageContentBinding'
    },
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
    'c2hhMjU2Eh0KCnJlcXVlc3RfaWQYCSABKARSCXJlcXVlc3RJZBJkChdtZXNzYWdlX2NvbnRlbn'
    'RfYmluZGluZxgKIAEoCzIsLnBpLmNsaWVudC5wcm90b2NvbC52MC5NZXNzYWdlQ29udGVudEJp'
    'bmRpbmdSFW1lc3NhZ2VDb250ZW50QmluZGluZw==');

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
