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

@$core.Deprecated('Use peerRoleDescriptor instead')
const PeerRole$json = {
  '1': 'PeerRole',
  '2': [
    {'1': 'PEER_ROLE_UNSPECIFIED', '2': 0},
    {'1': 'PEER_ROLE_CLIENT', '2': 1},
    {'1': 'PEER_ROLE_NODE', '2': 2},
  ],
};

/// Descriptor for `PeerRole`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List peerRoleDescriptor = $convert.base64Decode(
    'CghQZWVyUm9sZRIZChVQRUVSX1JPTEVfVU5TUEVDSUZJRUQQABIUChBQRUVSX1JPTEVfQ0xJRU'
    '5UEAESEgoOUEVFUl9ST0xFX05PREUQAg==');

@$core.Deprecated('Use capabilityDescriptor instead')
const Capability$json = {
  '1': 'Capability',
  '2': [
    {'1': 'CAPABILITY_UNSPECIFIED', '2': 0},
    {'1': 'CAPABILITY_HEALTH_UNARY', '2': 1},
    {'1': 'CAPABILITY_EVENT_STREAM', '2': 2},
    {'1': 'CAPABILITY_CANCELLATION', '2': 3},
    {'1': 'CAPABILITY_FLOW_CONTROL', '2': 4},
    {'1': 'CAPABILITY_TRANSFER', '2': 5},
  ],
};

/// Descriptor for `Capability`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List capabilityDescriptor = $convert.base64Decode(
    'CgpDYXBhYmlsaXR5EhoKFkNBUEFCSUxJVFlfVU5TUEVDSUZJRUQQABIbChdDQVBBQklMSVRZX0'
    'hFQUxUSF9VTkFSWRABEhsKF0NBUEFCSUxJVFlfRVZFTlRfU1RSRUFNEAISGwoXQ0FQQUJJTElU'
    'WV9DQU5DRUxMQVRJT04QAxIbChdDQVBBQklMSVRZX0ZMT1dfQ09OVFJPTBAEEhcKE0NBUEFCSU'
    'xJVFlfVFJBTlNGRVIQBQ==');

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
    {'1': 'ERROR_CODE_INVALID_ARGUMENT', '2': 1},
    {'1': 'ERROR_CODE_UNAUTHENTICATED', '2': 2},
    {'1': 'ERROR_CODE_PERMISSION_DENIED', '2': 3},
    {'1': 'ERROR_CODE_NOT_FOUND', '2': 4},
    {'1': 'ERROR_CODE_ALREADY_EXISTS', '2': 5},
    {'1': 'ERROR_CODE_CONFLICT', '2': 6},
    {'1': 'ERROR_CODE_FAILED_PRECONDITION', '2': 7},
    {'1': 'ERROR_CODE_RESOURCE_EXHAUSTED', '2': 8},
    {'1': 'ERROR_CODE_CANCELLED', '2': 9},
    {'1': 'ERROR_CODE_DEADLINE_EXCEEDED', '2': 10},
    {'1': 'ERROR_CODE_UNAVAILABLE', '2': 11},
    {'1': 'ERROR_CODE_DATA_LOSS', '2': 12},
    {'1': 'ERROR_CODE_INTERNAL', '2': 13},
    {'1': 'ERROR_CODE_PROTOCOL_VIOLATION', '2': 14},
    {'1': 'ERROR_CODE_UNSUPPORTED_VERSION', '2': 15},
  ],
};

/// Descriptor for `ErrorCode`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List errorCodeDescriptor = $convert.base64Decode(
    'CglFcnJvckNvZGUSGgoWRVJST1JfQ09ERV9VTlNQRUNJRklFRBAAEh8KG0VSUk9SX0NPREVfSU'
    '5WQUxJRF9BUkdVTUVOVBABEh4KGkVSUk9SX0NPREVfVU5BVVRIRU5USUNBVEVEEAISIAocRVJS'
    'T1JfQ09ERV9QRVJNSVNTSU9OX0RFTklFRBADEhgKFEVSUk9SX0NPREVfTk9UX0ZPVU5EEAQSHQ'
    'oZRVJST1JfQ09ERV9BTFJFQURZX0VYSVNUUxAFEhcKE0VSUk9SX0NPREVfQ09ORkxJQ1QQBhIi'
    'Ch5FUlJPUl9DT0RFX0ZBSUxFRF9QUkVDT05ESVRJT04QBxIhCh1FUlJPUl9DT0RFX1JFU09VUk'
    'NFX0VYSEFVU1RFRBAIEhgKFEVSUk9SX0NPREVfQ0FOQ0VMTEVEEAkSIAocRVJST1JfQ09ERV9E'
    'RUFETElORV9FWENFRURFRBAKEhoKFkVSUk9SX0NPREVfVU5BVkFJTEFCTEUQCxIYChRFUlJPUl'
    '9DT0RFX0RBVEFfTE9TUxAMEhcKE0VSUk9SX0NPREVfSU5URVJOQUwQDRIhCh1FUlJPUl9DT0RF'
    'X1BST1RPQ09MX1ZJT0xBVElPThAOEiIKHkVSUk9SX0NPREVfVU5TVVBQT1JURURfVkVSU0lPTh'
    'AP');

@$core.Deprecated('Use piTransportFrameDescriptor instead')
const PiTransportFrame$json = {
  '1': 'PiTransportFrame',
  '2': [
    {'1': 'frame_sequence', '3': 1, '4': 1, '5': 4, '10': 'frameSequence'},
    {
      '1': 'bootstrap_hello',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.BootstrapHello',
      '9': 0,
      '10': 'bootstrapHello'
    },
    {
      '1': 'health_request',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.HealthRequest',
      '9': 0,
      '10': 'healthRequest'
    },
    {
      '1': 'health_response',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.HealthResponse',
      '9': 0,
      '10': 'healthResponse'
    },
    {
      '1': 'event_stream',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.EventStreamEnvelope',
      '9': 0,
      '10': 'eventStream'
    },
    {
      '1': 'cancel',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.Cancel',
      '9': 0,
      '10': 'cancel'
    },
    {
      '1': 'window_update',
      '3': 15,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.WindowUpdate',
      '9': 0,
      '10': 'windowUpdate'
    },
    {
      '1': 'transfer_open',
      '3': 16,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.TransferOpen',
      '9': 0,
      '10': 'transferOpen'
    },
    {
      '1': 'transfer_chunk',
      '3': 17,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.TransferChunk',
      '9': 0,
      '10': 'transferChunk'
    },
    {
      '1': 'transfer_ack',
      '3': 18,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.TransferAck',
      '9': 0,
      '10': 'transferAck'
    },
    {
      '1': 'transfer_complete',
      '3': 19,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.TransferComplete',
      '9': 0,
      '10': 'transferComplete'
    },
    {
      '1': 'transfer_abort',
      '3': 20,
      '4': 1,
      '5': 11,
      '6': '.pi.client.protocol.v0.TransferAbort',
      '9': 0,
      '10': 'transferAbort'
    },
    {
      '1': 'error',
      '3': 21,
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
    {'1': 22, '2': 32},
  ],
};

/// Descriptor for `PiTransportFrame`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List piTransportFrameDescriptor = $convert.base64Decode(
    'ChBQaVRyYW5zcG9ydEZyYW1lEiUKDmZyYW1lX3NlcXVlbmNlGAEgASgEUg1mcmFtZVNlcXVlbm'
    'NlElAKD2Jvb3RzdHJhcF9oZWxsbxgKIAEoCzIlLnBpLmNsaWVudC5wcm90b2NvbC52MC5Cb290'
    'c3RyYXBIZWxsb0gAUg5ib290c3RyYXBIZWxsbxJNCg5oZWFsdGhfcmVxdWVzdBgLIAEoCzIkLn'
    'BpLmNsaWVudC5wcm90b2NvbC52MC5IZWFsdGhSZXF1ZXN0SABSDWhlYWx0aFJlcXVlc3QSUAoP'
    'aGVhbHRoX3Jlc3BvbnNlGAwgASgLMiUucGkuY2xpZW50LnByb3RvY29sLnYwLkhlYWx0aFJlc3'
    'BvbnNlSABSDmhlYWx0aFJlc3BvbnNlEk8KDGV2ZW50X3N0cmVhbRgNIAEoCzIqLnBpLmNsaWVu'
    'dC5wcm90b2NvbC52MC5FdmVudFN0cmVhbUVudmVsb3BlSABSC2V2ZW50U3RyZWFtEjcKBmNhbm'
    'NlbBgOIAEoCzIdLnBpLmNsaWVudC5wcm90b2NvbC52MC5DYW5jZWxIAFIGY2FuY2VsEkoKDXdp'
    'bmRvd191cGRhdGUYDyABKAsyIy5waS5jbGllbnQucHJvdG9jb2wudjAuV2luZG93VXBkYXRlSA'
    'BSDHdpbmRvd1VwZGF0ZRJKCg10cmFuc2Zlcl9vcGVuGBAgASgLMiMucGkuY2xpZW50LnByb3Rv'
    'Y29sLnYwLlRyYW5zZmVyT3BlbkgAUgx0cmFuc2Zlck9wZW4STQoOdHJhbnNmZXJfY2h1bmsYES'
    'ABKAsyJC5waS5jbGllbnQucHJvdG9jb2wudjAuVHJhbnNmZXJDaHVua0gAUg10cmFuc2ZlckNo'
    'dW5rEkcKDHRyYW5zZmVyX2FjaxgSIAEoCzIiLnBpLmNsaWVudC5wcm90b2NvbC52MC5UcmFuc2'
    'ZlckFja0gAUgt0cmFuc2ZlckFjaxJWChF0cmFuc2Zlcl9jb21wbGV0ZRgTIAEoCzInLnBpLmNs'
    'aWVudC5wcm90b2NvbC52MC5UcmFuc2ZlckNvbXBsZXRlSABSEHRyYW5zZmVyQ29tcGxldGUSTQ'
    'oOdHJhbnNmZXJfYWJvcnQYFCABKAsyJC5waS5jbGllbnQucHJvdG9jb2wudjAuVHJhbnNmZXJB'
    'Ym9ydEgAUg10cmFuc2ZlckFib3J0EjwKBWVycm9yGBUgASgLMiQucGkuY2xpZW50LnByb3RvY2'
    '9sLnYwLkVycm9yRW52ZWxvcGVIAFIFZXJyb3JCCwoJb3BlcmF0aW9uSgQIAhAKSgQIFhAg');

@$core.Deprecated('Use bootstrapHelloDescriptor instead')
const BootstrapHello$json = {
  '1': 'BootstrapHello',
  '2': [
    {'1': 'connection_id', '3': 1, '4': 1, '5': 9, '10': 'connectionId'},
    {'1': 'peer_id', '3': 2, '4': 1, '5': 9, '10': 'peerId'},
    {
      '1': 'role',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.pi.client.protocol.v0.PeerRole',
      '10': 'role'
    },
    {'1': 'protocol_major', '3': 4, '4': 1, '5': 13, '10': 'protocolMajor'},
    {'1': 'protocol_minor', '3': 5, '4': 1, '5': 13, '10': 'protocolMinor'},
    {
      '1': 'implementation_name',
      '3': 6,
      '4': 1,
      '5': 9,
      '10': 'implementationName'
    },
    {
      '1': 'implementation_version',
      '3': 7,
      '4': 1,
      '5': 9,
      '10': 'implementationVersion'
    },
    {'1': 'max_frame_bytes', '3': 8, '4': 1, '5': 13, '10': 'maxFrameBytes'},
    {
      '1': 'max_transfer_chunk_bytes',
      '3': 9,
      '4': 1,
      '5': 13,
      '10': 'maxTransferChunkBytes'
    },
    {
      '1': 'capabilities',
      '3': 10,
      '4': 3,
      '5': 14,
      '6': '.pi.client.protocol.v0.Capability',
      '10': 'capabilities'
    },
  ],
};

/// Descriptor for `BootstrapHello`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List bootstrapHelloDescriptor = $convert.base64Decode(
    'Cg5Cb290c3RyYXBIZWxsbxIjCg1jb25uZWN0aW9uX2lkGAEgASgJUgxjb25uZWN0aW9uSWQSFw'
    'oHcGVlcl9pZBgCIAEoCVIGcGVlcklkEjMKBHJvbGUYAyABKA4yHy5waS5jbGllbnQucHJvdG9j'
    'b2wudjAuUGVlclJvbGVSBHJvbGUSJQoOcHJvdG9jb2xfbWFqb3IYBCABKA1SDXByb3RvY29sTW'
    'Fqb3ISJQoOcHJvdG9jb2xfbWlub3IYBSABKA1SDXByb3RvY29sTWlub3ISLwoTaW1wbGVtZW50'
    'YXRpb25fbmFtZRgGIAEoCVISaW1wbGVtZW50YXRpb25OYW1lEjUKFmltcGxlbWVudGF0aW9uX3'
    'ZlcnNpb24YByABKAlSFWltcGxlbWVudGF0aW9uVmVyc2lvbhImCg9tYXhfZnJhbWVfYnl0ZXMY'
    'CCABKA1SDW1heEZyYW1lQnl0ZXMSNwoYbWF4X3RyYW5zZmVyX2NodW5rX2J5dGVzGAkgASgNUh'
    'VtYXhUcmFuc2ZlckNodW5rQnl0ZXMSRQoMY2FwYWJpbGl0aWVzGAogAygOMiEucGkuY2xpZW50'
    'LnByb3RvY29sLnYwLkNhcGFiaWxpdHlSDGNhcGFiaWxpdGllcw==');

@$core.Deprecated('Use healthRequestDescriptor instead')
const HealthRequest$json = {
  '1': 'HealthRequest',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 9, '10': 'requestId'},
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
    'Cg1IZWFsdGhSZXF1ZXN0Eh0KCnJlcXVlc3RfaWQYASABKAlSCXJlcXVlc3RJZBIsChJpbmNsdW'
    'RlX2J1aWxkX2luZm8YAiABKAhSEGluY2x1ZGVCdWlsZEluZm8=');

@$core.Deprecated('Use healthResponseDescriptor instead')
const HealthResponse$json = {
  '1': 'HealthResponse',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 9, '10': 'requestId'},
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
    'Cg5IZWFsdGhSZXNwb25zZRIdCgpyZXF1ZXN0X2lkGAEgASgJUglyZXF1ZXN0SWQSOwoGc3RhdH'
    'VzGAIgASgOMiMucGkuY2xpZW50LnByb3RvY29sLnYwLkhlYWx0aFN0YXR1c1IGc3RhdHVzEiEK'
    'DG5vZGVfdmVyc2lvbhgDIAEoCVILbm9kZVZlcnNpb24SIwoNdXB0aW1lX21pbGxpcxgEIAEoBF'
    'IMdXB0aW1lTWlsbGlz');

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
    {'1': 'request_id', '3': 1, '4': 1, '5': 9, '9': 0, '10': 'requestId'},
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
    'CgZDYW5jZWwSHwoKcmVxdWVzdF9pZBgBIAEoCUgAUglyZXF1ZXN0SWQSHQoJc3RyZWFtX2lkGA'
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
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'retryable', '3': 3, '4': 1, '5': 8, '10': 'retryable'},
    {
      '1': 'retry_after_millis',
      '3': 4,
      '4': 1,
      '5': 13,
      '10': 'retryAfterMillis'
    },
  ],
};

/// Descriptor for `StableError`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List stableErrorDescriptor = $convert.base64Decode(
    'CgtTdGFibGVFcnJvchI0CgRjb2RlGAEgASgOMiAucGkuY2xpZW50LnByb3RvY29sLnYwLkVycm'
    '9yQ29kZVIEY29kZRIYCgdtZXNzYWdlGAIgASgJUgdtZXNzYWdlEhwKCXJldHJ5YWJsZRgDIAEo'
    'CFIJcmV0cnlhYmxlEiwKEnJldHJ5X2FmdGVyX21pbGxpcxgEIAEoDVIQcmV0cnlBZnRlck1pbG'
    'xpcw==');

@$core.Deprecated('Use errorEnvelopeDescriptor instead')
const ErrorEnvelope$json = {
  '1': 'ErrorEnvelope',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 9, '9': 0, '10': 'requestId'},
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
    'Cg1FcnJvckVudmVsb3BlEh8KCnJlcXVlc3RfaWQYASABKAlIAFIJcmVxdWVzdElkEh0KCXN0cm'
    'VhbV9pZBgCIAEoCUgAUghzdHJlYW1JZBIhCgt0cmFuc2Zlcl9pZBgDIAEoCUgAUgp0cmFuc2Zl'
    'cklkEjgKBWVycm9yGAQgASgLMiIucGkuY2xpZW50LnByb3RvY29sLnYwLlN0YWJsZUVycm9yUg'
    'VlcnJvckINCgtjb3JyZWxhdGlvbg==');
